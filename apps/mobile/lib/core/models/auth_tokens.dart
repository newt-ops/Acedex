class AuthTokens {
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;

  const AuthTokens({
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 3600,
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    if (refreshToken != null) 'refreshToken': refreshToken,
    'expiresIn': expiresIn,
  };
}
