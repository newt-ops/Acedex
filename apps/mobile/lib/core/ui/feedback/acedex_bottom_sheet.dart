import 'dart:ui';
import 'package:flutter/material.dart';

/// Apple iOS-Style Frosted Glass Bottom Modal Sheet
///
/// Features a top drag indicator handle, backdrop blur, squircle top radii (24px),
/// and spring drag-to-dismiss physics.
Future<T?> showAcedexBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  String? title,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1B1B1F).withValues(alpha: 0.96)
                : const Color(0xFFFFFFFF).withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
            border: Border.all(
              color: theme.colorScheme.outline,
              width: 1.0,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                // Apple drag handle pill
                Container(
                  width: 36,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                if (title != null) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Flexible(child: child),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      );
    },
  );
}
