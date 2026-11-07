class OnboardingData {
  final String name;
  final String gender; // 'male' or 'female'
  final int grade; // 9, 10, 11, 12
  final String stream; // 'natural', 'social', 'common'
  final int dailyGoalMinutes; // 60, 90, 120, 180, 240

  const OnboardingData({
    this.name = '',
    this.gender = 'male',
    this.grade = 11,
    this.stream = 'natural',
    this.dailyGoalMinutes = 120,
  });

  OnboardingData copyWith({
    String? name,
    String? gender,
    int? grade,
    String? stream,
    int? dailyGoalMinutes,
  }) {
    return OnboardingData(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      grade: grade ?? this.grade,
      stream: stream ?? this.stream,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    );
  }
}

