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

    switch (widget.variant) {
      case AcedexButtonVariant.primary:
        backgroundColor = colors.primary;
        foregroundColor = colors.onPrimary;
        break;
      case AcedexButtonVariant.secondary:
        backgroundColor = colors.primarySoft;
        foregroundColor = colors.primary;
        break;
      case AcedexButtonVariant.danger:
        backgroundColor = colors.danger;
        foregroundColor = colors.onDanger;
        break;
    }

    if (!isEnabled) {
      backgroundColor = backgroundColor.withValues(alpha: 0.4);
      foregroundColor = foregroundColor.withValues(alpha: 0.6);
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
      curve: Curves.easeInOut,
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
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}

