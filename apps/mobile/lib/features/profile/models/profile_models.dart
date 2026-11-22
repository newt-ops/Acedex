/// Profile & Candidate Credential Data Models
class EueeSubjectRegistration {
  final String name;
  final String code;
  final String date;
  final String duration;

  const EueeSubjectRegistration({
    required this.name,
    required this.code,
    required this.date,
    required this.duration,
  });
}

/// Export format metadata
enum ExportFormat {
  pdf('pdf', 'Official PDF', 'OFFICIAL PDF • A4 VERIFIED CERTIFICATE', '318 KB', 'pdf'),
  png('png', 'High-Res PNG', 'HIGH-RES PASS PNG • 2160×1350 PX', '642 KB', 'png'),
  wallet('wallet', 'Wallet Pass', 'APPLE WALLET PASS • .PKPASS', '124 KB', 'pkpass');

  final String key;
  final String label;
  final String badge;
  final String size;
  final String ext;

  const ExportFormat(this.key, this.label, this.badge, this.size, this.ext);
}

/// Candidate Record State
class ProfileCandidateRecord {
  String name;
  String phone;
  String gender;
  String grade;
  String stream;
  final String candidateId;
  final String admissionNo;
  final String examCenter;
  final String hall;
  final String seatNo;
  final String examWindow;

  ProfileCandidateRecord({
    required this.name,
    required this.phone,
    required this.gender,
    required this.grade,
    required this.stream,
    required this.candidateId,
    required this.admissionNo,
    required this.examCenter,
    required this.hall,
    required this.seatNo,
    required this.examWindow,
  });

  ProfileCandidateRecord copyWith({
    String? name,
    String? phone,
    String? gender,
    String? grade,
    String? stream,
  }) {
    return ProfileCandidateRecord(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      grade: grade ?? this.grade,
      stream: stream ?? this.stream,
      candidateId: candidateId,
      admissionNo: admissionNo,
      examCenter: examCenter,
      hall: hall,
      seatNo: seatNo,
      examWindow: examWindow,
    );
  }
}

/// Static datasets for Profile Screen
abstract class ProfileData {
  static const Map<String, List<EueeSubjectRegistration>> subjectsByStream = {
    'Natural Science': [
      EueeSubjectRegistration(name: 'Physics', code: 'PHYS-12', date: 'Hamle 14 • 08:30', duration: '2h 30m'),
      EueeSubjectRegistration(name: 'Mathematics', code: 'MATH-12', date: 'Hamle 15 • 08:30', duration: '3h 00m'),
      EueeSubjectRegistration(name: 'Chemistry', code: 'CHEM-12', date: 'Hamle 16 • 08:30', duration: '2h 30m'),
      EueeSubjectRegistration(name: 'Biology', code: 'BIOL-12', date: 'Hamle 17 • 08:30', duration: '2h 30m'),
      EueeSubjectRegistration(name: 'English', code: 'ENGL-12', date: 'Hamle 18 • 08:30', duration: '2h 00m'),
      EueeSubjectRegistration(name: 'Scholastic Aptitude', code: 'SAPT-12', date: 'Hamle 18 • 14:00', duration: '2h 00m'),
    ],
    'Social Science': [
      EueeSubjectRegistration(name: 'History', code: 'HIST-12', date: 'Hamle 14 • 08:30', duration: '2h 30m'),
      EueeSubjectRegistration(name: 'Social Mathematics', code: 'MATH-12S', date: 'Hamle 15 • 08:30', duration: '3h 00m'),
      EueeSubjectRegistration(name: 'Geography', code: 'GEOG-12', date: 'Hamle 16 • 08:30', duration: '2h 30m'),
      EueeSubjectRegistration(name: 'Economics', code: 'ECON-12', date: 'Hamle 17 • 08:30', duration: '2h 30m'),
      EueeSubjectRegistration(name: 'English', code: 'ENGL-12', date: 'Hamle 18 • 08:30', duration: '2h 00m'),
      EueeSubjectRegistration(name: 'Scholastic Aptitude', code: 'SAPT-12', date: 'Hamle 18 • 14:00', duration: '2h 00m'),
    ],
  };

  static ProfileCandidateRecord defaultRecord() {
    return ProfileCandidateRecord(
      name: 'Aymen Mubarek',
      phone: '+251 913 951 112',
      gender: 'Male',
      grade: 'Grade 12',
      stream: 'Natural Science',
      candidateId: 'ACX-26-1194',
      admissionNo: 'ET-AA-26-084912',
      examCenter: 'Bole Preparatory Center',
      hall: 'Hall B-04',
      seatNo: 'S-114',
      examWindow: 'Hamle 14 – 18 • Morning (08:30 EAT)',
    );
  }
}
