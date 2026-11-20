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

  static final RegExp ethiopianPhoneRegex = RegExp(r'^(\+251|0)?[79]\d{8}$');

  /// Normalizes any valid Ethiopian phone string into standard E.164: +2519XXXXXXXX or +2517XXXXXXXX
  static String normalizePhone(String input) {
    final cleaned = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('+251')) {
      return cleaned;
    }
    if (cleaned.startsWith('251')) {
      return '+$cleaned';
    }
    if (cleaned.startsWith('0')) {
      return '+251${cleaned.substring(1)}';
    }
    if (cleaned.startsWith('9') || cleaned.startsWith('7')) {
      return '+251$cleaned';
    }
    return cleaned;
  }

  static bool isValidPhone(String input) {
    final cleaned = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return ethiopianPhoneRegex.hasMatch(cleaned);
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
