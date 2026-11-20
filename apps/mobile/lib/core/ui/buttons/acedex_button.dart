import 'package:flutter/material.dart';
import '../animations/bounceable.dart';

enum AcedexButtonVariant {
  primary,
  soft,
  surface,
  destructive,
  outline,
  ghost,
}

enum AcedexButtonSize {
  sm,
  md,
  lg,
}

/// Apple-Style Tactile Button Component
///
/// Features elastic bounce-on-press feedback, high-contrast Teal theme mapping,
/// built-in loading spinner, and flexible sizing.
class AcedexButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AcedexButtonVariant variant;
  final AcedexButtonSize size;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool isFullWidth;

  const AcedexButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AcedexButtonVariant.primary,
    this.size = AcedexButtonSize.md,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    // Resolve Sizing Metrics
    final double height;
    final double fontSize;
    final double horizontalPadding;
    final double iconSpacing;
    final double borderRadius;

    switch (size) {
      case AcedexButtonSize.sm:
        height = 38.0;
        fontSize = 13.5;
        horizontalPadding = 14.0;
        iconSpacing = 6.0;
        borderRadius = 10.0;
        break;
      case AcedexButtonSize.md:
        height = 48.0;
        fontSize = 15.0;
        horizontalPadding = 18.0;
        iconSpacing = 8.0;
        borderRadius = 13.0;
        break;
      case AcedexButtonSize.lg:
        height = 56.0;
        fontSize = 16.5;
        horizontalPadding = 24.0;
        iconSpacing = 10.0;
        borderRadius = 15.0;
        break;
    }

    // Resolve Colors based on Teal design system
    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AcedexButtonVariant.primary:
        backgroundColor = theme.colorScheme.primary;
        foregroundColor = theme.colorScheme.onPrimary;
        break;
      case AcedexButtonVariant.soft:
        backgroundColor = theme.colorScheme.primaryContainer;
        foregroundColor = theme.colorScheme.primary;
        break;
      case AcedexButtonVariant.surface:
        backgroundColor = theme.colorScheme.surface;
        foregroundColor = theme.colorScheme.onSurface;
        borderSide = BorderSide(color: theme.colorScheme.outline, width: 1.0);
        break;
      case AcedexButtonVariant.destructive:
        backgroundColor = theme.colorScheme.error;
        foregroundColor = theme.colorScheme.onError;
        break;
      case AcedexButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = theme.colorScheme.primary;
        borderSide = BorderSide(color: theme.colorScheme.primary, width: 1.5);
        break;
      case AcedexButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = theme.colorScheme.primary;
        break;
    }

    if (!isEnabled) {
      backgroundColor = backgroundColor.withValues(alpha: 0.45);
      foregroundColor = foregroundColor.withValues(alpha: 0.45);
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: fontSize + 2,
            height: fontSize + 2,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else ...[
          if (leadingIcon != null) ...[
            IconTheme(
              data: IconThemeData(color: foregroundColor, size: fontSize + 3),
              child: leadingIcon!,
            ),
            SizedBox(width: iconSpacing),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
                letterSpacing: -0.1,
              ),
            ),
          ),
          if (trailingIcon != null) ...[
            SizedBox(width: iconSpacing),
            IconTheme(
              data: IconThemeData(color: foregroundColor, size: fontSize + 3),
              child: trailingIcon!,
            ),
          ],
        ],
      ],
    );

    return AcedexBounceable(
      onTap: isEnabled ? onPressed : null,
      scaleFactor: 0.96,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderSide != BorderSide.none ? Border.fromBorderSide(borderSide) : null,
        ),
        child: content,
      ),
    );
  }
}
