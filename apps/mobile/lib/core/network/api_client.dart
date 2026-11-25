import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';
import 'api_exception.dart';
import '../models/auth_tokens.dart';
import '../storage/auth_storage.dart';

class ApiClient {
  static final ApiClient instance = ApiClient();

  final http.Client _client;
  final String baseUrl;
  Future<bool>? _refreshInFlight;

  ApiClient({http.Client? client, this.baseUrl = ApiEndpoints.baseUrl})
    : _client = client ?? http.Client();

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    return _sendWithRetry(
      method: 'POST',
      path: path,
      body: body,
      requiresAuth: requiresAuth,
      timeout: timeout,
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    bool requiresAuth = true,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    return _sendWithRetry(
      method: 'GET',
      path: path,
      requiresAuth: requiresAuth,
      timeout: timeout,
    );
  }

  Future<Map<String, dynamic>> _sendWithRetry({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    required bool requiresAuth,
    required Duration timeout,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    Future<http.Response> executeRequest() async {
      final headers = <String, String>{
        'Accept': 'application/json',
        if (method == 'POST') 'Content-Type': 'application/json',
      };

      if (requiresAuth) {
        final token = await AuthStorage.instance.getToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      if (method == 'POST') {
        return _client
            .post(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(timeout);
      }
      return _client.get(uri, headers: headers).timeout(timeout);
    }

    try {
      var response = await executeRequest();

      if (response.statusCode == 401 &&
          requiresAuth &&
          path != ApiEndpoints.refresh) {
        final refreshed = await _tryRefreshSession(timeout: timeout);
        if (refreshed) {
          response = await executeRequest();
        } else {
          throw const ApiException(
            'Your session has expired. Please sign in again.',
            statusCode: 401,
            code: 'SESSION_EXPIRED',
          );
        }
      }

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e, stack) {
      debugPrint('[ApiClient $method Error] $path: $e\n$stack');
      throw const ApiException(
        'Unable to connect to Acedex. Please check your internet connection.',
      );
    }
  }

  /// Deduplicates concurrent refresh requests so refresh-token rotation
  /// never triggers false token-reuse alerts when parallel API calls expire.
  Future<bool> _tryRefreshSession({required Duration timeout}) {
    final active = _refreshInFlight;
    if (active != null) return active;

    final future = _performRefresh(timeout: timeout);
    _refreshInFlight = future;
    future.whenComplete(() {
      if (identical(_refreshInFlight, future)) {
        _refreshInFlight = null;
      }
    });
    return future;
  }

  Future<bool> _performRefresh({required Duration timeout}) async {
    try {
      final refreshToken = await AuthStorage.instance.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await AuthStorage.instance.expireSession();
        return false;
      }

      final uri = Uri.parse('$baseUrl${ApiEndpoints.refresh}');
      final res = await _client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(timeout);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        await AuthStorage.instance.expireSession();
        return false;
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        await AuthStorage.instance.expireSession();
        return false;
      }

      final data = decoded['data'];
      final tokensMap = data is Map<String, dynamic> ? data['tokens'] : null;
      if (tokensMap is! Map<String, dynamic>) {
        await AuthStorage.instance.expireSession();
        return false;
      }

      final tokens = AuthTokens.fromJson(tokensMap);
      await AuthStorage.instance.saveTokens(tokens);
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw ApiException(
        'Unexpected server response. Please try again.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    }

    throw ApiException.fromResponse(response.statusCode, decoded);
  }
}
