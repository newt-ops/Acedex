import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  PinService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _kPinCodeKey = 'acedex_pin_code';
  static const String _kPinEnabledKey = 'acedex_pin_enabled';

  Future<bool> isPinEnabled() async {
    final value = await _storage.read(key: _kPinEnabledKey);
    return value == 'true';
  }

  Future<bool> hasPin() async {
    final pin = await _storage.read(key: _kPinCodeKey);
    return pin != null && pin.length == 4;
  }

  Future<bool> verifyPin(String enteredPin) async {
    final storedPin = await _storage.read(key: _kPinCodeKey);
    return storedPin == enteredPin;
  }

  Future<void> setPin(String pin) async {
    await _storage.write(key: _kPinCodeKey, value: pin);
    await _storage.write(key: _kPinEnabledKey, value: 'true');
  }

  Future<void> setPinEnabled(bool enabled) async {
    await _storage.write(key: _kPinEnabledKey, value: enabled ? 'true' : 'false');
  }

  Future<void> removePin() async {
    await _storage.delete(key: _kPinCodeKey);
    await _storage.delete(key: _kPinEnabledKey);
  }
}
