/// Avatar presentation mode
enum StudentAvatarType {
  preset,
  custom,
}

/// Student Profile Avatar Model
///
/// Encapsulates local avatar persistence with 5 Quick Studio Presets
/// ('default', 'monogram', 'scholar', 'atom', 'crest') or custom image base64/file.
class StudentAvatar {
  final StudentAvatarType type;
  final String presetId;
  final String? dataBase64;
  final String? filePath;

  const StudentAvatar({
    this.type = StudentAvatarType.preset,
    this.presetId = 'default',
    this.dataBase64,
    this.filePath,
  });

  /// Default silhouette preset
  static const StudentAvatar defaultSilhouette = StudentAvatar(
    type: StudentAvatarType.preset,
    presetId: 'default',
  );

  /// Preset constructor
  const StudentAvatar.preset(String id)
      : type = StudentAvatarType.preset,
        presetId = id,
        dataBase64 = null,
        filePath = null;

  /// Custom image constructor
  const StudentAvatar.custom({this.dataBase64, this.filePath})
      : type = StudentAvatarType.custom,
        presetId = 'custom';

  factory StudentAvatar.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'preset';
    return StudentAvatar(
      type: typeStr == 'custom'
          ? StudentAvatarType.custom
          : StudentAvatarType.preset,
      presetId: json['presetId'] as String? ?? 'default',
      dataBase64: json['dataBase64'] as String?,
      filePath: json['filePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type == StudentAvatarType.custom ? 'custom' : 'preset',
        'presetId': presetId,
        if (dataBase64 != null) 'dataBase64': dataBase64,
        if (filePath != null) 'filePath': filePath,
      };

  String get label {
    if (type == StudentAvatarType.custom) {
      return 'Custom Photo';
    }
    switch (presetId) {
      case 'monogram':
        return 'Royal Monogram';
      case 'scholar':
        return 'Scholar Graduation Cap';
      case 'atom':
        return 'Science Atom Emblem';
      case 'crest':
        return 'Gold Honor Crest';
      case 'default':
      default:
        return 'Default Silhouette';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentAvatar &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          presetId == other.presetId &&
          dataBase64 == other.dataBase64 &&
          filePath == other.filePath;

  @override
  int get hashCode =>
      type.hashCode ^
      presetId.hashCode ^
      (dataBase64?.hashCode ?? 0) ^
      (filePath?.hashCode ?? 0);
}
