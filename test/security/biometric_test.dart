import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:acedex/features/security/services/biometric_service.dart';

class FakeLocalAuthSuccess extends LocalAuthentication {
  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  Future<bool> get canCheckBiometrics async => true;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async =>
      [BiometricType.fingerprint];

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<dynamic> authMessages = const [],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async =>
      true;
}

class FakeLocalAuthUnsupported extends LocalAuthentication {
  @override
  Future<bool> isDeviceSupported() async => false;

  @override
  Future<bool> get canCheckBiometrics async => false;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => [];

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<dynamic> authMessages = const [],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async =>
      false;
}

class FakeLocalAuthFailed extends LocalAuthentication {
  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  Future<bool> get canCheckBiometrics async => true;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async =>
      [BiometricType.fingerprint];

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<dynamic> authMessages = const [],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async =>
      false;
}

void main() {
  group('BiometricService Tests', () {
    test('isBiometricAvailable returns true when supported and enrolled',
        () async {
      final service = BiometricService(FakeLocalAuthSuccess());
      final available = await service.isBiometricAvailable();
      expect(available, isTrue);

      final biometrics = await service.getAvailableBiometrics();
      expect(biometrics, contains(BiometricType.fingerprint));
    });

    test('isBiometricAvailable returns false when device cannot do it',
        () async {
      final service = BiometricService(FakeLocalAuthUnsupported());
      final available = await service.isBiometricAvailable();
      expect(available, isFalse);

      final biometrics = await service.getAvailableBiometrics();
      expect(biometrics, isEmpty);
    });

    test('authenticate returns true when fingerprint scan succeeds',
        () async {
      final service = BiometricService(FakeLocalAuthSuccess());
      final result = await service.authenticate();
      expect(result, isTrue);
    });

    test('authenticate returns false when fingerprint scan fails or cancelled',
        () async {
      final service = BiometricService(FakeLocalAuthFailed());
      final result = await service.authenticate();
      expect(result, isFalse);
    });

    test('authenticate returns false immediately when unsupported', () async {
      final service = BiometricService(FakeLocalAuthUnsupported());
      final result = await service.authenticate();
      expect(result, isFalse);
    });
  });
}
