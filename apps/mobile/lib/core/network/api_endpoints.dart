class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://acedex-api.onrender.com';

  static const String loginPhone = '/api/v1/auth/login-phone';
  static const String registerPhone = '/api/v1/auth/register-phone';
  static const String checkPhone = '/api/v1/auth/check-phone';
  static const String me = '/api/v1/auth/me';
  static const String refresh = '/api/v1/auth/refresh';

  // Curriculum & Live Metrics
  static const String examCountdown = '/api/v1/curriculum/exam-countdown';
  static const String curriculumPulse = '/api/v1/curriculum/pulse';
  static String curriculumSubjects({int grade = 12}) => '/api/v1/curriculum/subjects?grade=$grade';
  static String curriculumUnits({int grade = 12, required String subject}) =>
      '/api/v1/curriculum/units?grade=$grade&subject=$subject';
  static String unitAssessment(String unitId) => '/api/v1/curriculum/units/$unitId/assessment';
  static String unitQuestions(String unitId) => '/api/v1/curriculum/units/$unitId/questions';
  static String completeUnit(String unitId) => '/api/v1/study/units/$unitId/complete';
  static String updateUnitStatus(String unitId) => '/api/v1/study/units/$unitId/status';
}
