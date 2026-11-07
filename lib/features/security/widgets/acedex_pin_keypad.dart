import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';

class AcedexPinKeypad extends StatelessWidget {
  const AcedexPinKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspace,
    this.bottomLeftWidget,
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspace;
  final Widget? bottomLeftWidget;

  static const Map<String, String> _subtitles = {
    '1': '',
    '2': 'ABC',
    '3': 'DEF',
    '4': 'GHI',
    '5': 'JKL',
    '6': 'MNO',
    '7': 'PQRS',
    '8': 'TUV',
    '9': 'WXYZ',
    '0': '+',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(context, ['1', '2', '3']),
        const SizedBox(height: 16),
        _buildRow(context, ['4', '5', '6']),
        const SizedBox(height: 16),
        _buildRow(context, ['7', '8', '9']),
        const SizedBox(height: 16),
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
          subtitle: _subtitles[digits[0]] ?? '',
          onPressed: () => onDigitPressed(digits[0]),
        ),
        const SizedBox(width: 28),
        _PinKeyButton(
          digit: digits[1],
          subtitle: _subtitles[digits[1]] ?? '',
          onPressed: () => onDigitPressed(digits[1]),
        ),
        const SizedBox(width: 28),
        _PinKeyButton(
          digit: digits[2],
          subtitle: _subtitles[digits[2]] ?? '',
          onPressed: () => onDigitPressed(digits[2]),
        ),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    final colors = context.appColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Center(child: bottomLeftWidget ?? const SizedBox.shrink()),
        ),
        const SizedBox(width: 28),
        _PinKeyButton(
          digit: '0',
          subtitle: _subtitles['0'] ?? '',
          onPressed: () => onDigitPressed('0'),
        ),
        const SizedBox(width: 28),
        SizedBox(
          width: 72,
          height: 72,
          child: _KeypadActionButton(
            icon: HugeIcons.strokeRoundedDelete02,
            color: colors.textPrimary,
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
    required this.subtitle,
    required this.onPressed,
  });

  final String digit;
  final String subtitle;
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
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isPressed ? colors.primarySoft : colors.surface,
            border: Border.all(
              color: _isPressed ? colors.primary : colors.border,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.digit,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w600,
                  color: _isPressed ? colors.primary : colors.textPrimary,
                  height: 1.0,
                ),
              ),
              if (widget.subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
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
  });

  final List<List<dynamic>> icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  State<_KeypadActionButton> createState() => _KeypadActionButtonState();
}

class _KeypadActionButtonState extends State<_KeypadActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        child: Center(
          child: HugeIcon(
            icon: widget.icon,
            color: widget.color,
            size: 26,
          ),
        ),
      ),
    );
  }
}
