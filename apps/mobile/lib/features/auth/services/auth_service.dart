import '../../../core/models/auth_tokens.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/auth_storage.dart';

class AuthService {
  final ApiClient _client;
  final AuthStorage _storage;

  AuthService({
    ApiClient? client,
    AuthStorage? storage,
  })  : _client = client ?? ApiClient(),
        _storage = storage ?? AuthStorage.instance;

  static final RegExp ethiopianPhoneRegex = RegExp(r'^\+251[79]\d{8}$');

  /// Normalizes any valid Ethiopian phone string into standard E.164: +2519XXXXXXXX or +2517XXXXXXXX
  /// Supports raw inputs like 09..., 07..., 9..., 7..., +2510..., +251...
  static String normalizePhone(String input) {
    var cleaned = input.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
    if (cleaned.startsWith('+2510')) {
      cleaned = '+251${cleaned.substring(5)}';
    } else if (cleaned.startsWith('2510')) {
      cleaned = '+251${cleaned.substring(4)}';
    } else if (cleaned.startsWith('+251')) {
      // kept as is
    } else if (cleaned.startsWith('251')) {
      cleaned = '+$cleaned';
    } else if (cleaned.startsWith('0')) {
      cleaned = '+251${cleaned.substring(1)}';
    } else if (cleaned.startsWith('9') || cleaned.startsWith('7')) {
      cleaned = '+251$cleaned';
    }
    return cleaned;
  }

  static bool isValidPhone(String input) {
    if (input.trim().isEmpty) return false;
    final normalized = normalizePhone(input);
    return ethiopianPhoneRegex.hasMatch(normalized);
  }

  /// Checks if a phone number is already registered in Acedex
  Future<bool> checkPhoneRegistered(String phone) async {
    try {
      final cleanPhone = normalizePhone(phone);
      if (!isValidPhone(cleanPhone)) return false;

      final response = await _client.get(
        '${ApiEndpoints.checkPhone}?phone=${Uri.encodeComponent(cleanPhone)}',
      );
      final data = response['data'] as Map<String, dynamic>;
      return data['registered'] == true;
    } catch (_) {
      // Graceful degradation when network/backend check is unavailable
      return false;
    }
  }

  Future<UserProfile> login({
    required String phone,
    required String pin,
  }) async {
    final cleanPhone = normalizePhone(phone);
    if (!isValidPhone(cleanPhone)) {
      throw const ApiException('Please enter a valid Ethiopian phone number.');
    }
    if (pin.length < 6) {
      throw const ApiException('PIN must be at least 6 digits.');
    }

    final response = await _client.post(
      ApiEndpoints.loginPhone,
      body: {
        'phone': cleanPhone,
        'pin': pin,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    final tokens = AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>);
    final user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);

    await _storage.saveTokens(tokens);
    await _storage.saveProfile(user);

    return user;
  }

  Future<UserProfile> register({
    required String phone,
    required String pin,
    required String fullName,
    required String gender,
    required int grade,
    String? stream,
    String? candidateId,
  }) async {
    final cleanPhone = normalizePhone(phone);
    if (!isValidPhone(cleanPhone)) {
      throw const ApiException('Please enter a valid Ethiopian phone number.');
    }
    if (pin.length < 6) {
      throw const ApiException('PIN must be at least 6 digits.');
    }
    if (fullName.trim().length < 2) {
      throw const ApiException('Please enter your full name (at least 2 letters).');
    }
    if ((grade == 11 || grade == 12) && (stream == null || stream.isEmpty)) {
      throw const ApiException('Please select your study stream (Natural or Social Science).');
    }

    final body = <String, dynamic>{
      'phone': cleanPhone,
      'pin': pin,
      'fullName': fullName.trim(),
      'gender': gender.toLowerCase(),
      'grade': grade,
    };
    if (grade >= 11 && stream != null) {
      body['stream'] = stream.toLowerCase();
    }
    if (candidateId != null && candidateId.trim().isNotEmpty) {
      body['candidateId'] = candidateId.trim();
    }

    final response = await _client.post(
      ApiEndpoints.registerPhone,
      body: body,
    );

    final data = response['data'] as Map<String, dynamic>;
    final tokens = AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>);
    final user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);

    await _storage.saveTokens(tokens);
    await _storage.saveProfile(user);

    return user;
  }

  Future<UserProfile?> getProfile() async {
    try {
      final response = await _client.get(
        ApiEndpoints.me,
        requiresAuth: true,
      );
      final data = response['data'] as Map<String, dynamic>;
      final user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);
      await _storage.saveProfile(user);
      return user;
    } catch (_) {
      return await _storage.getProfile();
    }
  }

  Future<void> logout() async {
    await _storage.clear();
  }
}
