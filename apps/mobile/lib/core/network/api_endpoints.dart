class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://acedex-api.onrender.com';

  static const String loginPhone = '/api/v1/auth/login-phone';
  static const String registerPhone = '/api/v1/auth/register-phone';
  static const String me = '/api/v1/auth/me';
  static const String refresh = '/api/v1/auth/refresh';
}
