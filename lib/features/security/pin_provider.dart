import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pin_service.dart';

final pinServiceProvider = Provider<PinService>((ref) {
  return PinService();
});

class PinState {
  const PinState({
    this.isPinEnabled = false,
    this.isLocked = false,
    this.isInitialized = false,
  });

  final bool isPinEnabled;
  final bool isLocked;
  final bool isInitialized;

  PinState copyWith({
    bool? isPinEnabled,
    bool? isLocked,
    bool? isInitialized,
  }) {
    return PinState(
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      isLocked: isLocked ?? this.isLocked,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

final pinProvider = StateNotifierProvider<PinNotifier, PinState>((ref) {
  final service = ref.watch(pinServiceProvider);
  return PinNotifier(service);
});

class PinNotifier extends StateNotifier<PinState> {
  PinNotifier(this._service) : super(const PinState()) {
    initialize();
  }

  final PinService _service;

  Future<void> initialize() async {
    final enabled = await _service.isPinEnabled();
    final hasPin = await _service.hasPin();
    final shouldLock = enabled && hasPin;
    state = state.copyWith(
      isPinEnabled: shouldLock,
      isLocked: shouldLock,
      isInitialized: true,
    );
  }

  void onAppPaused() {
    if (state.isPinEnabled) {
      state = state.copyWith(isLocked: true);
    }
  }

  void onAppResumed() {
    if (state.isPinEnabled) {
      state = state.copyWith(isLocked: true);
    }
  }

  Future<bool> verifyAndUnlock(String enteredPin) async {
    final isValid = await _service.verifyPin(enteredPin);
    if (isValid) {
      state = state.copyWith(isLocked: false);
      return true;
    }
    return false;
  }

  Future<void> enablePin(String pin) async {
    await _service.setPin(pin);
    state = state.copyWith(
      isPinEnabled: true,
      isLocked: false,
    );
  }

  Future<void> disablePin() async {
    await _service.removePin();
    state = state.copyWith(
      isPinEnabled: false,
      isLocked: false,
    );
  }
}
