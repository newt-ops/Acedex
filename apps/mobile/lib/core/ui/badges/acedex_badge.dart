import 'package:flutter/material.dart';

enum AcedexBadgeVariant {
  primary,
  success,
  warning,
  error,
  neutral,
}

/// Apple-Style Compact Pill Badge
class AcedexBadge extends StatelessWidget {
  final String label;
  final AcedexBadgeVariant variant;
  final Widget? icon;
  final VoidCallback? onTap;

  const AcedexBadge({
    super.key,
    required this.label,
    this.variant = AcedexBadgeVariant.primary,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color textColor;

    switch (variant) {
      case AcedexBadgeVariant.primary:
        backgroundColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.primary;
        break;
      case AcedexBadgeVariant.success:
        backgroundColor = isDark ? const Color(0xFF132F21) : const Color(0xFFDCFCE7);
        textColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
        break;
      case AcedexBadgeVariant.warning:
        backgroundColor = isDark ? const Color(0xFF32230D) : const Color(0xFFFEF3C7);
        textColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
        break;
      case AcedexBadgeVariant.error:
        backgroundColor = isDark ? const Color(0xFF351515) : const Color(0xFFFEE2E2);
        textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
        break;
      case AcedexBadgeVariant.neutral:
        backgroundColor = isDark ? const Color(0xFF2B2B31) : const Color(0xFFE4E4E8);
        textColor = theme.colorScheme.onSurfaceVariant;
        break;
    }

    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: textColor, size: 14),
              child: icon!,
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
