import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum AcedexButtonVariant {
  primary,
  secondary,
  danger,
}

class AcedexButton extends StatefulWidget {
  const AcedexButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AcedexButtonVariant.primary,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AcedexButtonVariant variant;
  final Widget? leading;
  final Widget? trailing;
  final bool isLoading;
  final bool isFullWidth;

  @override
  State<AcedexButton> createState() => _AcedexButtonState();
}

class _AcedexButtonState extends State<AcedexButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color backgroundColor;
    Color foregroundColor;
    Border? border;
    List<BoxShadow>? shadows;

    switch (widget.variant) {
      case AcedexButtonVariant.primary:
        backgroundColor = _isPressed
            ? colors.primary.withValues(alpha: 0.90)
            : colors.primary;
        foregroundColor = colors.onPrimary;
        shadows = isEnabled && !_isPressed
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.28),
                  blurRadius: 12.0,
                  offset: const Offset(0, 4),
                ),
              ]
            : null;
        break;
      case AcedexButtonVariant.secondary:
        backgroundColor = _isPressed
            ? Color.alphaBlend(colors.primarySoft.withValues(alpha: 0.30), colors.surface)
            : Color.alphaBlend(colors.primarySoft, colors.surface);
        foregroundColor = colors.primary;
        border = Border.all(
          color: _isPressed
              ? colors.primary
              : colors.primary.withValues(alpha: 0.25),
          width: 1.0,
        );
        shadows = isEnabled && !_isPressed
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ]
            : null;
        break;
      case AcedexButtonVariant.danger:
        backgroundColor = _isPressed
            ? colors.danger.withValues(alpha: 0.90)
            : colors.danger;
        foregroundColor = colors.onDanger;
        shadows = isEnabled && !_isPressed
            ? [
                BoxShadow(
                  color: colors.danger.withValues(alpha: 0.28),
                  blurRadius: 12.0,
                  offset: const Offset(0, 4),
                ),
              ]
            : null;
        break;
    }

    if (!isEnabled) {
      backgroundColor = backgroundColor.withValues(alpha: 0.35);
      foregroundColor = foregroundColor.withValues(alpha: 0.55);
      shadows = null;
    }

    Widget content = widget.isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: AppTheme.space8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                  letterSpacing: -0.2,
                ),
              ),
              if (widget.trailing != null) ...[
                const SizedBox(width: AppTheme.space8),
                widget.trailing!,
              ],
            ],
          );

    return AnimatedScale(
      scale: _isPressed && isEnabled ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: isEnabled ? widget.onPressed : null,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppTheme.minTapTarget,
            minWidth: AppTheme.minTapTarget,
          ),
          width: widget.isFullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space16,
            vertical: AppTheme.space12,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
            border: border,
            boxShadow: shadows,
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}
