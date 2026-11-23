import 'dart:ui';
import 'package:flutter/material.dart';
import '../buttons/acedex_button.dart';

/// Apple iOS-Style Frosted Glass Alert Dialog
///
/// Features hardware-accelerated Gaussian backdrop blur (`BackdropFilter`),
/// spring entrance scale animation, rounded corners, and tactile AcedexButtons.
Future<T?> showAcedexDialog<T>(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String? cancelLabel,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool isDestructive = false,
  Widget? customContent,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss Dialog',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, anim1, anim2) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 340),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1B1B1F).withValues(alpha: 0.94)
                      : const Color(0xFFFFFFFF).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    if (customContent != null) ...[
                      const SizedBox(height: 16),
                      customContent,
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        if (cancelLabel != null) ...[
                          Expanded(
                            child: AcedexButton(
                              label: cancelLabel,
                              variant: AcedexButtonVariant.surface,
                              size: AcedexButtonSize.md,
                              onPressed: () {
                                Navigator.of(context).pop();
                                onCancel?.call();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: AcedexButton(
                            label: confirmLabel,
                            variant: isDestructive
                                ? AcedexButtonVariant.destructive
                                : AcedexButtonVariant.primary,
                            size: AcedexButtonSize.md,
                            onPressed: () {
                              Navigator.of(context).pop();
                              onConfirm?.call();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );
      return ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: anim,
          child: child,
        ),
      );
    },
  );
}

/// Reusable Apple iOS-Style Confirmation Dialog for Acedex
///
/// Specialized reusable confirmation modal dialog for actions such as item deletion,
/// unsaved changes, or stream shifts. Includes optional icon squircle, distinct
/// destructive styling, and returns a `Future<bool>` indicating whether the user
/// confirmed (`true`) or cancelled (`false` / `null`).
Future<bool?> showAcedexConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
  Widget? icon,
  Widget? customContent,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss Confirmation Dialog',
    barrierColor: Colors.black.withValues(alpha: 0.48),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, anim1, anim2) {
      final theme = Theme.of(dialogContext);
      final isDark = theme.brightness == Brightness.dark;
      final destructiveColor = const Color(0xFFEF4444);

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 340),
                padding: const EdgeInsets.fromLTRB(22.0, 24.0, 22.0, 20.0),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1B1B1F).withValues(alpha: 0.94)
                      : const Color(0xFFFFFFFF).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E2E36) : const Color(0xFFE4E4EB),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                      blurRadius: 32,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDestructive
                              ? destructiveColor.withValues(alpha: 0.12)
                              : theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: icon,
                      ),
                      const SizedBox(height: 14),
                    ],
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    if (customContent != null) ...[
                      const SizedBox(height: 14),
                      customContent,
                    ],
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: AcedexButton(
                            label: cancelLabel,
                            variant: AcedexButtonVariant.surface,
                            size: AcedexButtonSize.md,
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AcedexButton(
                            label: confirmLabel,
                            variant: isDestructive
                                ? AcedexButtonVariant.destructive
                                : AcedexButtonVariant.primary,
                            size: AcedexButtonSize.md,
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );
      return ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: anim,
          child: child,
        ),
      );
    },
  );
}
