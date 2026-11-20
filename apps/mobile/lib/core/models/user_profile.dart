class UserProfile {
  final String id;
  final String acedexId;
  final String displayName;
  final String? phone;
  final String? email;
  final String? gender;
  final int? grade;
  final String? stream;
  final String role;
  final String status;

  const UserProfile({
    required this.id,
    required this.acedexId,
    required this.displayName,
    this.phone,
    this.email,
    this.gender,
    this.grade,
    this.stream,
    required this.role,
    required this.status,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      acedexId: json['acedexId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Student',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      gender: json['gender'] as String?,
      grade: (json['grade'] as num?)?.toInt(),
      stream: json['stream'] as String?,
      role: json['role'] as String? ?? 'student',
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'acedexId': acedexId,
    'displayName': displayName,
    if (phone != null) 'phone': phone,
    if (email != null) 'email': email,
    if (gender != null) 'gender': gender,
    if (grade != null) 'grade': grade,
    if (stream != null) 'stream': stream,
    'role': role,
    'status': status,
  };

  String get gradeLabel {
    if (grade == null) return 'High School';
    if (stream != null && stream!.isNotEmpty) {
      final formattedStream = stream![0].toUpperCase() + stream!.substring(1);
      return 'Grade $grade • $formattedStream';
    }
    return 'Grade $grade';
  }
}
