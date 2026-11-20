import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../numeric_keypad.dart';

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
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final errorColor = isDark ? AppColors.darkError : AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Category Badge
          Text(
            'ACCOUNT SECURITY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),

          // Title with Smooth Cross-Fade
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              _isConfirming ? 'Confirm your PIN' : 'Create your PIN',
              key: ValueKey<bool>(_isConfirming),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _isConfirming
                  ? 'Re-enter your 6-digit PIN to confirm.'
                  : 'Enter six digits using the keypad below.',
              key: ValueKey<bool>(_isConfirming),
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: subtext,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // 6 PIN Squircle Indicator Cells (with horizontal shake on error)
          Center(
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                final offset = _shakeController.isAnimating
                    ? (1 - _shakeController.value) *
                        10 *
                        ((_shakeController.value * 20).toInt() % 2 == 0 ? 1 : -1)
                    : 0.0;
                return Transform.translate(
                  offset: Offset(offset.toDouble(), 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final isFilled = index < _currentPin.length;
                  final isCurrent = index == _currentPin.length;
                  final hasError = _errorMessage != null;

                  return Container(
                    width: 44,
                    height: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasError
                            ? errorColor
                            : (isCurrent
                                ? accent
                                : (isFilled
                                    ? accent.withValues(alpha: 0.6)
                                    : line)),
                        width: (isCurrent || isFilled) ? 2.0 : 1.2,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: isFilled
                        ? Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                            ),
                          )
                        : null,
                  );
                }),
              ),
            ),
          ),

          // Error Message or Helper
          const SizedBox(height: 12),
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _errorMessage != null ? 1.0 : 0.0,
              child: Text(
                _errorMessage ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: errorColor,
                ),
              ),
            ),
          ),

          const Spacer(),

          // Tactile On-Screen Numeric Keypad (NO Continue Button!)
          NumericKeypad(
            onDigit: _onDigit,
            onDelete: _onDelete,
          ),
          const SizedBox(height: 12),

          // Footnote
          Center(
            child: Text(
              'Your PIN keeps your student account secure.',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: subtext.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
