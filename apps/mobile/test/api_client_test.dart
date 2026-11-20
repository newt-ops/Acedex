import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:acedex/core/network/api_client.dart';
import 'package:acedex/core/network/api_exception.dart';

void main() {
  group('ApiClient and ApiException Tests', () {
    test('maps 401 unauthorized to student-friendly copy', () async {
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
