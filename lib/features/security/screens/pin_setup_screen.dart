import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/acedex_toast.dart';
import '../pin_provider.dart';
import '../widgets/acedex_pin_keypad.dart';
import '../widgets/pin_dots_indicator.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen>
    with SingleTickerProviderStateMixin {
  int _step = 1; // 1 = Create, 2 = Confirm
  String _firstPin = '';
  String _confirmPin = '';
  String? _errorMessage;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: -1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -1.0, end: 1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigitPressed(String digit) {
    if (_step == 1) {
      if (_firstPin.length < 4) {
        setState(() {
          _firstPin += digit;
          _errorMessage = null;
        });
        if (_firstPin.length == 4) {
          Future.delayed(const Duration(milliseconds: 180), () {
            if (mounted) setState(() => _step = 2);
          });
        }
      }
    } else {
      if (_confirmPin.length < 4) {
        setState(() {
          _confirmPin += digit;
          _errorMessage = null;
        });
        if (_confirmPin.length == 4) {
          _handleConfirm();
        }
      }
    }
  }

  void _onBackspace() {
    if (_step == 1) {
      if (_firstPin.isNotEmpty) {
        setState(() => _firstPin = _firstPin.substring(0, _firstPin.length - 1));
      }
    } else {
      if (_confirmPin.isNotEmpty) {
        setState(() => _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1));
      } else {
        setState(() {
          _step = 1;
          _firstPin = '';
        });
      }
    }
  }

  Future<void> _handleConfirm() async {
    if (_firstPin == _confirmPin) {
      await ref.read(pinProvider.notifier).enablePin(_firstPin);
      if (mounted) {
        AcedexToast.show(
          context,
          title: 'PIN Lock Enabled',
          message: 'Your Acedex security PIN has been set successfully.',
          status: AcedexToastStatus.success,
        );
        Navigator.of(context).pop(true);
      }
    } else {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0.0);
      setState(() {
        _errorMessage = 'PINs did not match. Please start over.';
        _confirmPin = '';
        _firstPin = '';
        _step = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final currentPin = _step == 1 ? _firstPin : _confirmPin;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(_step == 1 ? 'Create PIN' : 'Confirm PIN'),
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: colors.textPrimary,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: _step == 1
                          ? HugeIcons.strokeRoundedShield01
                          : HugeIcons.strokeRoundedShieldCheck,
                      color: colors.primary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.space16),
                Text(
                  _step == 1 ? 'Set Security PIN' : 'Re-enter your PIN',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.space8),
                Text(
                  _step == 1
                      ? 'Choose a 4-digit PIN you will remember'
                      : 'Re-enter the 4 digits to confirm',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.space24),
                PinDotsIndicator(
                  pinLength: currentPin.length,
                  maxDigits: 4,
                  shakeAnimation: _shakeAnimation,
                ),
                const SizedBox(height: AppTheme.space12),
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
                const SizedBox(height: AppTheme.space24),
                AcedexPinKeypad(
                  onDigitPressed: _onDigitPressed,
                  onBackspace: _onBackspace,
                ),
                const SizedBox(height: AppTheme.space16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
