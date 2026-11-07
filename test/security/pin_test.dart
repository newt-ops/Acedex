import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:acedex/features/security/pin_service.dart';
import 'package:acedex/features/security/pin_provider.dart';

void main() {
  group('PIN Security & Keypad Logic Tests', () {
    late PinService pinService;
    late PinNotifier pinNotifier;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      pinService = PinService(const FlutterSecureStorage());
      pinNotifier = PinNotifier(pinService);
    });

    test('Initial state is unlocked and PIN disabled', () async {
      await pinNotifier.initialize();
      expect(pinNotifier.state.isPinEnabled, isFalse);
      expect(pinNotifier.state.isLocked, isFalse);
    });

    test('Setting PIN enables lock and verifies correctly', () async {
      await pinNotifier.enablePin('1234');
      expect(pinNotifier.state.isPinEnabled, isTrue);
      expect(pinNotifier.state.isLocked, isFalse);

      final hasPin = await pinService.hasPin();
      expect(hasPin, isTrue);

      final isCorrect = await pinNotifier.verifyAndUnlock('1234');
      expect(isCorrect, isTrue);

      final isWrong = await pinNotifier.verifyAndUnlock('9999');
      expect(isWrong, isFalse);
    });

    test('App backgrounding and resumption locks app if PIN enabled', () async {
      await pinNotifier.enablePin('4321');
      expect(pinNotifier.state.isLocked, isFalse);

      // User pauses app
      pinNotifier.onAppPaused();
      expect(pinNotifier.state.isLocked, isTrue);

      // User returns
      pinNotifier.onAppResumed();
      expect(pinNotifier.state.isLocked, isTrue);

      // Wrong PIN fails to unlock
      final wrongUnlock = await pinNotifier.verifyAndUnlock('0000');
      expect(wrongUnlock, isFalse);
      expect(pinNotifier.state.isLocked, isTrue);

      // Correct PIN unlocks
      final correctUnlock = await pinNotifier.verifyAndUnlock('4321');
      expect(correctUnlock, isTrue);
      expect(pinNotifier.state.isLocked, isFalse);
    });

    test('Disabling PIN clears lock state and storage', () async {
      await pinNotifier.enablePin('7777');
      expect(pinNotifier.state.isPinEnabled, isTrue);

      await pinNotifier.disablePin();
      expect(pinNotifier.state.isPinEnabled, isFalse);
      expect(pinNotifier.state.isLocked, isFalse);

      final hasPin = await pinService.hasPin();
      expect(hasPin, isFalse);
    });
  });
}
