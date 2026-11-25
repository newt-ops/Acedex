class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const ApiException(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;

  factory ApiException.fromResponse(int statusCode, dynamic body) {
    if (body is Map<String, dynamic> && body['error'] is Map<String, dynamic>) {
      final errorMap = body['error'] as Map<String, dynamic>;
      final msg = errorMap['message']?.toString();
      final code = errorMap['code']?.toString();
      if (msg != null && msg.isNotEmpty) {
        return ApiException(_friendlyMessage(msg, statusCode), statusCode: statusCode, code: code);
      }
    }
    return ApiException(_fallbackMessage(statusCode), statusCode: statusCode);
  }

  static String _friendlyMessage(String original, int statusCode) {
    if (statusCode == 401) {
      final lower = original.toLowerCase();
      if (lower.contains('invalid credentials') ||
          lower.contains('invalid phone number or pin')) {
        return 'Incorrect phone number or PIN. Please try again.';
      }
      if (lower.contains('expired') ||
          lower.contains('refresh') ||
          lower.contains('authorization') ||
          lower.contains('access token') ||
          lower.contains('session')) {
        return 'Your session has expired. Please sign in again.';
      }
      return original;
    }
    if (statusCode == 409) {
      return 'An account with this phone number already exists.';
    }
    if (statusCode >= 500) {
      return 'We are experiencing high demand. Please try again shortly.';
    }
    return original;
  }

  static String _fallbackMessage(int statusCode) {
    if (statusCode == 404) return 'The requested service was not found.';
    if (statusCode >= 500) return 'Unable to reach the server. Please try again shortly.';
    return 'Something went wrong. Please check your information and try again.';
  }
}
