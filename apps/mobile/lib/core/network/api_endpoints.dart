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
  static String curriculumSubjects({int? grade, String? stream}) {
    final query = <String>[];
    if (grade != null) query.add('grade=$grade');
    if (stream != null && stream.isNotEmpty) query.add('stream=$stream');
    final q = query.isNotEmpty ? '?${query.join('&')}' : '';
    return '/api/v1/curriculum/subjects$q';
  }
  static String curriculumUnits({int grade = 12, required String subject}) =>
      '/api/v1/curriculum/units?grade=$grade&subject=$subject';
  static String unitNotes(String unitId) => '/api/v1/curriculum/units/$unitId/notes';
  static String unitAssessment(String unitId) => '/api/v1/curriculum/units/$unitId/assessment';
  static String unitQuestions(String unitId) => '/api/v1/curriculum/units/$unitId/questions';
  static String completeUnit(String unitId) => '/api/v1/study/units/$unitId/complete';
  static String updateUnitStatus(String unitId) => '/api/v1/study/units/$unitId/status';

  // Rewarded Ads & Monetization
  static const String adsConfig = '/api/v1/ads/config';
  static const String adsStatus = '/api/v1/ads/status';
  static const String adsSessionStart = '/api/v1/ads/session/start';
  static const String adsRewardClaim = '/api/v1/ads/reward/claim';

  // AI Cross-Grade Topic Study & Gemini Planner
  static const String topicProgram = '/api/v1/topics/program';
  static String subjectTopicModules(String subjectCode) =>
      '/api/v1/topics/subjects/${subjectCode.toUpperCase()}/modules';
  static String topicModuleProgress(String moduleId) =>
      '/api/v1/topics/modules/$moduleId/progress';
}
