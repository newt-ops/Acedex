import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'acedex_button.dart';

class AcedexDialog extends StatelessWidget {
  const AcedexDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.icon,
    this.confirmLabel = 'OK',
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  final String title;
  final String? message;
  final Widget? content;
  final Widget? icon;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    String? message,
    Widget? icon,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => AcedexDialog(
        title: title,
        message: message,
        icon: icon,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final badgeColor = isDestructive ? colors.danger : colors.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space24,
        vertical: AppTheme.space24,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.space24),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(22.0),
              border: Border.all(
                color: colors.border.withValues(alpha: 0.8),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 28.0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: icon ??
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colors.statusTint(badgeColor),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.statusBorder(badgeColor),
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: isDestructive
                                ? HugeIcons.strokeRoundedAlert02
                                : HugeIcons.strokeRoundedInformationCircle,
                            color: badgeColor,
                            size: 26,
                          ),
                        ),
                      ),
                ),
                const SizedBox(height: AppTheme.space16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (message != null) ...[
                  const SizedBox(height: AppTheme.space8),
                  Text(
                    message!,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (content != null) ...[
                  const SizedBox(height: AppTheme.space16),
                  content!,
                ],
                const SizedBox(height: AppTheme.space24),
                Row(
                  children: [
                    if (cancelLabel != null) ...[
                      Expanded(
                        child: AcedexButton(
                          label: cancelLabel!,
                          variant: AcedexButtonVariant.secondary,
                          onPressed: onCancel ?? () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: AppTheme.space12),
                    ],
                    Expanded(
                      child: AcedexButton(
                        label: confirmLabel,
                        variant: isDestructive
                            ? AcedexButtonVariant.danger
                            : AcedexButtonVariant.primary,
                        onPressed: onConfirm ?? () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
