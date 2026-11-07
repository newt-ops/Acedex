import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AcedexBadge extends StatelessWidget {
  const AcedexBadge({
    super.key,
    required this.label,
    required this.color,
    this.leading,
    this.fontSize = 12.0,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppTheme.space8,
      vertical: AppTheme.space4,
    ),
  });

  final String label;
  final Color color;
  final Widget? leading;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.statusTint(color),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: colors.statusBorder(color),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppTheme.space4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

