import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../numeric_keypad.dart';

/// Distraction-Free Full-Page PIN Keypad Step
///
/// Removes distracting labels and category badges, immersing the student
/// in an Apple-grade, focused 6-digit PIN creation and auto-confirmation flow.
class StepPinKeypad extends StatefulWidget {
  final ValueChanged<String> onPinConfirmed;
  final VoidCallback onBack;

  const StepPinKeypad({
    super.key,
    required this.onPinConfirmed,
    required this.onBack,
  });

  @override
  State<StepPinKeypad> createState() => _StepPinKeypadState();
}

class _StepPinKeypadState extends State<StepPinKeypad>
    with SingleTickerProviderStateMixin {
  String _currentPin = '';
  String _firstPin = '';
  bool _isConfirming = false;
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
    _shakeAnimation = Tween<double>(begin: 0.0, end: 12.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_currentPin.length >= 6) return;

    HapticFeedback.selectionClick();

    setState(() {
      _currentPin += digit;
      _errorMessage = null;
    });

    if (_currentPin.length == 6) {
      _handleCompleteSixDigits();
    }
  }

  void _onDelete() {
    if (_currentPin.isEmpty) return;

    HapticFeedback.selectionClick();

    setState(() {
      _currentPin = _currentPin.substring(0, _currentPin.length - 1);
      _errorMessage = null;
    });
  }

  Future<void> _handleCompleteSixDigits() async {
    if (!_isConfirming) {
      // Pass 1 Complete: Transition to Pass 2
      await Future.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;

      setState(() {
        _firstPin = _currentPin;
        _currentPin = '';
        _isConfirming = true;
      });
    } else {
      // Pass 2 Complete: Verification
      if (_currentPin == _firstPin) {
        // Match! Haptic impact and auto-advance
        HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 180));
        if (!mounted) return;
        widget.onPinConfirmed(_currentPin);
      } else {
        // Mismatch! Shake boxes and reset
        HapticFeedback.heavyImpact();
        _shakeController.forward(from: 0.0);
        setState(() {
          _errorMessage = 'PINs did not match. Please set your PIN again.';
          _currentPin = '';
          _firstPin = '';
          _isConfirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final softAccent =
        isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final errorColor = isDark ? AppColors.darkError : AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 1),

          // Central Security Lock Badge
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: softAccent,
              shape: BoxShape.circle,
              border: Border.all(
                color: accent.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            alignment: Alignment.center,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedSquareLock02,
              color: accent,
              size: 26,
            ),
          ),
          const SizedBox(height: 16),

          // Dynamic Focused Title
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _isConfirming ? 'Confirm your PIN' : 'Create your PIN',
              key: ValueKey(_isConfirming),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Minimal Subtitle
          Text(
            _isConfirming
                ? 'Re-enter your 6 digits to verify'
                : 'Your 6-digit PIN keeps your account secure',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            ),
          ),

          const SizedBox(height: 32),

          // 6-Digit PIN Squircle Cells with Shake Animation
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                final isFilled = index < _currentPin.length;
                final isCurrent = index == _currentPin.length;

                return Container(
                  width: 44,
                  height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: isFilled ? softAccent : surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _errorMessage != null
                          ? errorColor
                          : isCurrent
                              ? accent
                              : isFilled
                                  ? accent.withValues(alpha: 0.6)
                                  : line,
                      width: (isCurrent || isFilled) ? 1.8 : 1.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isFilled
                      ? Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                );
              }),
            ),
          ),

          const SizedBox(height: 14),

          // Error Message Area
          SizedBox(
            height: 24,
            child: _errorMessage != null
                ? Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: errorColor,
                    ),
                  )
                : null,
          ),

          const Spacer(flex: 2),

          // Full Custom Numeric Keypad
          NumericKeypad(
            onDigit: _onDigit,
            onDelete: _onDelete,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
