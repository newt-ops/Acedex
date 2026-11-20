/// Immutable draft model for the multi-step student registration journey.
class StudentRegistrationDraft {
  final String fullName;
  final String phoneNumber;
  final String gender; // 'male' | 'female'
  final int grade; // 9, 10, 11, 12
  final String? stream; // 'natural' | 'social' | null
  final String pin; // 6 digits

  const StudentRegistrationDraft({
    this.fullName = '',
    this.phoneNumber = '',
    this.gender = 'male',
    this.grade = 12,
    this.stream = 'natural',
    this.pin = '',
  });

  /// Ethiopian curriculum: Grade 9 and 10 follow a unified curriculum.
  /// Grade 11 and 12 specialize into Natural or Social science streams.
  bool get requiresStream => grade >= 11;

  /// Total steps dynamically adjusts to 6 if Grade 9/10, or 7 if Grade 11/12.
  int get totalSteps => requiresStream ? 7 : 6;

  /// Deterministic preview candidate ID e.g. "ACX-26-8941"
  String get candidateId {
    final rawSeed = '$fullName$phoneNumber$grade${stream ?? ''}';
    final hash = rawSeed.hashCode.abs() % 10000;
    return 'ACX-26-${hash.toString().padLeft(4, '0')}';
  }

  /// Formatted academic level summary e.g. "Grade 12 • Natural Science"
  String get academicSummary {
    if (!requiresStream || stream == null || stream!.isEmpty) {
      return 'Grade $grade • General Curriculum';
    }
    final streamLabel =
        stream!.toLowerCase() == 'natural' ? 'Natural Science' : 'Social Science';
    return 'Grade $grade • $streamLabel';
  }

  StudentRegistrationDraft copyWith({
    String? fullName,
    String? phoneNumber,
    String? gender,
    int? grade,
    String? stream,
    String? pin,
  }) {
    final newGrade = grade ?? this.grade;
    final newRequiresStream = newGrade >= 11;

    return StudentRegistrationDraft(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      grade: newGrade,
      stream: newRequiresStream ? (stream ?? this.stream ?? 'natural') : null,
      pin: pin ?? this.pin,
    );
  }
}
