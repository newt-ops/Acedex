import 'package:flutter/material.dart';
import '../animations/bounceable.dart';

enum AcedexCardVariant {
  flat,
  raised,
}

/// Apple-Style Squircle Tactile Card
///
/// Features smooth rounded corners (16-20px), subtle hairline border or soft elevation,
/// and automatic spring bouncing micro-interactions when interactive (`onTap != null`).
class AcedexCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final AcedexCardVariant variant;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? customBackgroundColor;
  final Color? customBorderColor;

  const AcedexCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.variant = AcedexCardVariant.flat,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 18.0,
    this.customBackgroundColor,
    this.customBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor = customBackgroundColor ??
        (variant == AcedexCardVariant.raised
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface);

    final Color borderColor = customBorderColor ?? theme.colorScheme.outline;

    Widget cardBody = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 0.9),
        boxShadow: variant == AcedexCardVariant.raised
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      return AcedexBounceable(
        onTap: onTap,
        onLongPress: onLongPress,
        scaleFactor: 0.97,
        child: cardBody,
      );
    }

    return cardBody;
  }
}
