import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';
import 'api_exception.dart';
import '../storage/auth_storage.dart';

class ApiClient {
  static final ApiClient instance = ApiClient();

  final http.Client _client;
  final String baseUrl;

  ApiClient({http.Client? client, this.baseUrl = ApiEndpoints.baseUrl})
    : _client = client ?? http.Client();

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await AuthStorage.instance.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      final response = await _client
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e, stack) {
      debugPrint('[ApiClient POST Error] $path: $e\n$stack');
      throw const ApiException(
        'Unable to connect to Acedex. Please check your internet connection.',
      );
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{'Accept': 'application/json'};

    if (requiresAuth) {
      final token = await AuthStorage.instance.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e, stack) {
      debugPrint('[ApiClient GET Error] $path: $e\n$stack');
      throw const ApiException(
        'Unable to connect to Acedex. Please check your internet connection.',
      );
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
