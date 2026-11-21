import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/progress/acedex_dots_loader.dart';
import '../numeric_keypad.dart';

/// Distraction-Free Full-Page Apple-Style PIN Keypad Step
///
/// Features a centered padlock emblem, 6 spring-popping PIN slots with focus rings,
/// canonical 3-dots wave loader with "Securing your PIN..." upon completion,
/// and a tactile numeric keypad with haptic feedback.
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
  bool _isSecuring = false;
  String _securingStatus = 'Securing your PIN...';
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
    if (_isSecuring || _currentPin.length >= 6) return;

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
    if (_isSecuring || _currentPin.isEmpty) return;

    HapticFeedback.selectionClick();

    setState(() {
      _currentPin = _currentPin.substring(0, _currentPin.length - 1);
      _errorMessage = null;
    });
  }

  Future<void> _handleCompleteSixDigits() async {
    if (!_isConfirming) {
      // Pass 1 Complete: Show wave loader status then transition to Pass 2
      setState(() {
        _isSecuring = true;
        _securingStatus = 'Securing your PIN...';
      });

      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      setState(() {
        _isSecuring = false;
        _firstPin = _currentPin;
        _currentPin = '';
        _isConfirming = true;
      });
    } else {
      // Pass 2 Complete: Verification
      if (_currentPin == _firstPin) {
        setState(() {
          _isSecuring = true;
          _securingStatus = 'Verifying your PIN...';
        });

        HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 650));
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
          _isSecuring = false;
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

          // Central Padlock Security Badge
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

          // 6-Digit PIN Squircle Cells with Shake Animation & Focus Ring
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
                final isCurrent = index == _currentPin.length && !_isSecuring;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
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
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: isDark ? 0.25 : 0.14),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: AnimatedScale(
                    scale: isFilled ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // Status & 3-Dots Wave Securing Area
          SizedBox(
            height: 36,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isSecuring
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AcedexDotsLoader(
                            color: accent,
                            dotSize: 6.0,
                            gap: 4.5,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _securingStatus,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                            ),
                          ),
                        ],
                      )
                    : _errorMessage != null
                        ? Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: errorColor,
                            ),
                          )
                        : const SizedBox.shrink(),
              ),
            ),
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
