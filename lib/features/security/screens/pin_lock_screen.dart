import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/acedex_toast.dart';
import '../biometric_provider.dart';
import '../pin_provider.dart';
import '../widgets/acedex_pin_keypad.dart';
import '../widgets/pin_boxes_indicator.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  String? _errorMessage;
  bool _isSuccess = false;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: -1.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -1.0, end: 1.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigitPressed(String digit) {
    if (_isSuccess) return;

    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _errorMessage = null;
      });

      if (_enteredPin.length == 4) {
        _handleVerification();
      }
    }
  }

  void _onBackspace() {
    if (_isSuccess) return;

    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  Future<void> _handleVerification() async {
    final success = await ref
        .read(pinProvider.notifier)
        .verifyAndUnlock(_enteredPin);

    if (mounted) {
      if (success) {
        HapticFeedback.mediumImpact();
        setState(() {
          _isSuccess = true;
          _errorMessage = null;
        });
        await Future.delayed(const Duration(milliseconds: 280));
      } else {
        HapticFeedback.heavyImpact();
        _shakeController.forward(from: 0.0);
        setState(() {
          _enteredPin = '';
          _errorMessage = 'Incorrect PIN. Please try again.';
        });
      }
    }
  }

  Future<void> _handleBiometricAuth() async {
    if (_isSuccess) return;

    HapticFeedback.lightImpact();
    final biometricService = ref.read(biometricServiceProvider);
    final isAvailable = await biometricService.isBiometricAvailable();

    if (!isAvailable) {
      if (mounted) {
        AcedexToast.show(
          context,
          title: 'Biometrics Unavailable',
          message: 'No fingerprint sensor or enrolled prints found. Please enter your PIN.',
          status: AcedexToastStatus.info,
        );
      }
      return;
    }

    final authenticated = await biometricService.authenticate(
      localizedReason: 'Scan fingerprint to access Acedex',
    );

    if (authenticated && mounted) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isSuccess = true;
        _enteredPin = '••••';
        _errorMessage = null;
      });
      await Future.delayed(const Duration(milliseconds: 320));
      if (mounted) {
        ref.read(pinProvider.notifier).unlock();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // Title matching reference design: "Enter current PIN" in primary plum color
                  Text(
                    'Enter current PIN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  // Squircle Indicator Boxes (Plum dot when entering, Green dots on Confirm)
                  PinBoxesIndicator(
                    pinLength: _enteredPin.length,
                    maxDigits: 4,
                    isSuccess: _isSuccess,
                    isError: _errorMessage != null,
                    shakeAnimation: _shakeAnimation,
                  ),
                  const SizedBox(height: 16),

                  // Error Message
                  SizedBox(
                    height: 20,
                    child: _errorMessage != null
                        ? Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: colors.danger,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 36),

                  // Keypad with Fingerprint and ArrowLeft actions
                  AcedexPinKeypad(
                    onDigitPressed: _onDigitPressed,
                    onBackspace: _onBackspace,
                    onFingerprintPressed: _handleBiometricAuth,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
