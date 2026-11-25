import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acedex/core/models/auth_tokens.dart';
import 'package:acedex/core/network/api_client.dart';
import 'package:acedex/core/network/api_exception.dart';
import 'package:acedex/core/storage/auth_storage.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthStorage.instance.clear();
  });

  group('ApiClient and ApiException Tests', () {
    test('maps 401 unauthorized credentials to student-friendly copy', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'error': {
              'code': 'UNAUTHORIZED',
              'message': 'Invalid credentials',
            },
          }),
          401,
        );
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () async => await apiClient.post('/api/v1/auth/login-phone', body: {}),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Incorrect phone number or PIN. Please try again.',
          ),
        ),
      );
    });

    test('automatically refreshes expired access token and retries authenticated request',
        () async {
      await AuthStorage.instance.saveTokens(
        const AuthTokens(
          accessToken: 'expired_access',
          refreshToken: 'valid_refresh_1',
          expiresIn: 7200,
        ),
      );

      var refreshCalls = 0;
      var walletCalls = 0;
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/refresh') {
          refreshCalls++;
          final payload = jsonDecode(request.body) as Map<String, dynamic>;
          expect(payload['refreshToken'], 'valid_refresh_1');
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'tokens': {
                  'accessToken': 'fresh_access_2',
                  'refreshToken': 'fresh_refresh_2',
                },
              },
            }),
            200,
          );
        }

        if (request.url.path == '/api/v1/economy/wallet') {
          walletCalls++;
          final authHeader = request.headers['Authorization'];
          if (authHeader == 'Bearer expired_access') {
            return http.Response(
              jsonEncode({
                'success': false,
                'error': {
                  'code': 'UNAUTHORIZED',
                  'message': 'Access token expired. Please refresh your session.',
                },
              }),
              401,
            );
          }
          expect(authHeader, 'Bearer fresh_access_2');
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {'balance': 50},
            }),
            200,
          );
        }

        return http.Response('{}', 404);
      });

      final apiClient = ApiClient(client: mockClient);
      final res = await apiClient.get('/api/v1/economy/wallet', requiresAuth: true);

      expect(res['data']['balance'], 50);
      expect(refreshCalls, 1);
      expect(walletCalls, 2);
      expect(await AuthStorage.instance.getToken(), 'fresh_access_2');
      expect(await AuthStorage.instance.getRefreshToken(), 'fresh_refresh_2');
    });

    test('expired refresh token emits session-expired message instead of PIN error',
        () async {
      await AuthStorage.instance.saveTokens(
        const AuthTokens(
          accessToken: 'expired_access',
          refreshToken: 'expired_refresh',
          expiresIn: 7200,
        ),
      );

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'error': {
              'code': 'UNAUTHORIZED',
              'message': 'Refresh token expired. Please log in again.',
            },
          }),
          401,
        );
      });

      final apiClient = ApiClient(client: mockClient);

      await expectLater(
        apiClient.get('/api/v1/economy/wallet', requiresAuth: true),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'SESSION_EXPIRED')
              .having(
                (e) => e.message,
                'message',
                'Your session has expired. Please sign in again.',
              ),
        ),
      );
      expect(AuthStorage.instance.sessionExpiredNotifier.value, isTrue);
    });

    test('maps 409 conflict to student-friendly phone exists copy', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'error': {
              'code': 'CONFLICT',
              'message': 'User already exists',
            },
          }),
          409,
        );
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () async =>
            await apiClient.post('/api/v1/auth/register-phone', body: {}),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'An account with this phone number already exists.',
          ),
        ),
      );
    });

    test('successful 200 response parses json payload', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'userId': 'student_123'},
          }),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final res = await apiClient.post('/test');
      expect(res['success'], true);
      expect(res['data']['userId'], 'student_123');
    });
  });
}
