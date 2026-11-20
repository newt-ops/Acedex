import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';

/// Tactile Apple-Style On-Screen Numeric Keypad
///
/// 3x4 grid for seamless, distraction-free PIN input with spring depression physics.
class NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onClear;

  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3'], surfaceColor, textColor, accent),
          const SizedBox(height: 12),
          _buildRow(['4', '5', '6'], surfaceColor, textColor, accent),
          const SizedBox(height: 12),
          _buildRow(['7', '8', '9'], surfaceColor, textColor, accent),
          const SizedBox(height: 12),
          _buildBottomRow(surfaceColor, textColor, accent),
        ],
      ),
    );
  }

  Widget _buildRow(
    List<String> digits,
    Color surfaceColor,
    Color textColor,
    Color accent,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) {
        return _KeypadButton(
          label: digit,
          surfaceColor: surfaceColor,
          textColor: textColor,
          onTap: () => onDigit(digit),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow(
    Color surfaceColor,
    Color textColor,
    Color accent,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Left Spacer / Optional Clear
        const SizedBox(
          width: 76,
          height: 60,
        ),

        // '0' Digit
        _KeypadButton(
          label: '0',
          surfaceColor: surfaceColor,
          textColor: textColor,
          onTap: () => onDigit('0'),
        ),

        // Backspace Button
        SizedBox(
          width: 76,
          height: 60,
          child: AcedexBounceable(
            scaleFactor: 0.92,
            onTap: onDelete,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: textColor.withValues(alpha: 0.8),
                size: 26,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String label;
  final Color surfaceColor;
  final Color textColor;
  final VoidCallback onTap;

  const _KeypadButton({
    required this.label,
    required this.surfaceColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 60,
      child: AcedexBounceable(
        scaleFactor: 0.92,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: textColor.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }
}
