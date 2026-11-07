import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';

class AcedexPinKeypad extends StatelessWidget {
  const AcedexPinKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspace,
    this.onFingerprintPressed,
    this.bottomLeftWidget,
    this.showKeyBorders = false,
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onFingerprintPressed;
  final Widget? bottomLeftWidget;
  final bool showKeyBorders;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(context, ['1', '2', '3']),
        const SizedBox(height: 18),
        _buildRow(context, ['4', '5', '6']),
        const SizedBox(height: 18),
        _buildRow(context, ['7', '8', '9']),
        const SizedBox(height: 18),
        _buildBottomRow(context),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PinKeyButton(
          digit: digits[0],
          showBorder: showKeyBorders,
          onPressed: () => onDigitPressed(digits[0]),
        ),
        const SizedBox(width: 32),
        _PinKeyButton(
          digit: digits[1],
          showBorder: showKeyBorders,
          onPressed: () => onDigitPressed(digits[1]),
        ),
        const SizedBox(width: 32),
        _PinKeyButton(
          digit: digits[2],
          showBorder: showKeyBorders,
          onPressed: () => onDigitPressed(digits[2]),
        ),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    final colors = context.appColors;

    Widget leftAction;
    if (bottomLeftWidget != null) {
      leftAction = bottomLeftWidget!;
    } else if (onFingerprintPressed != null) {
      leftAction = _KeypadActionButton(
        icon: HugeIcons.strokeRoundedFingerprintPattern,
        color: colors.textPrimary,
        size: 28,
        onPressed: onFingerprintPressed!,
      );
    } else {
      leftAction = const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Center(child: leftAction),
        ),
        const SizedBox(width: 32),
        _PinKeyButton(
          digit: '0',
          showBorder: showKeyBorders,
          onPressed: () => onDigitPressed('0'),
        ),
        const SizedBox(width: 32),
        SizedBox(
          width: 72,
          height: 72,
          child: _KeypadActionButton(
            icon: HugeIcons.strokeRoundedArrowLeft02,
            color: colors.textPrimary,
            size: 28,
            onPressed: onBackspace,
          ),
        ),
      ],
    );
  }
}

class _PinKeyButton extends StatefulWidget {
  const _PinKeyButton({
    required this.digit,
    required this.showBorder,
    required this.onPressed,
  });

  final String digit;
  final bool showBorder;
  final VoidCallback onPressed;

  @override
  State<_PinKeyButton> createState() => _PinKeyButtonState();
}

class _PinKeyButtonState extends State<_PinKeyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 72,
          height: 72,
          decoration: widget.showBorder
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isPressed ? colors.primarySoft : colors.surface,
                  border: Border.all(
                    color: _isPressed ? colors.primary : colors.border,
                    width: 1.0,
                  ),
                )
              : BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isPressed
                      ? colors.primarySoft
                      : Colors.transparent,
                ),
          child: Center(
            child: Text(
              widget.digit,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: _isPressed ? colors.primary : colors.textPrimary,
                height: 1.0,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeypadActionButton extends StatefulWidget {
  const _KeypadActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.size = 26.0,
  });

  final List<List<dynamic>> icon;
  final Color color;
  final VoidCallback onPressed;
  final double size;

  @override
  State<_KeypadActionButton> createState() => _KeypadActionButtonState();
}

class _KeypadActionButtonState extends State<_KeypadActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isPressed ? colors.primarySoft : Colors.transparent,
          ),
          child: Center(
            child: HugeIcon(
              icon: widget.icon,
              color: _isPressed ? colors.primary : widget.color,
              size: widget.size,
            ),
          ),
        ),
      ),
    );
  }
}
