import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AcedexToastType {
  success,
  warning,
  error,
  info,
}

/// Apple Dynamic-Island Style Floating Notification Pill
///
/// Drops from the top edge with spring physics (`Curves.easeOutBack`),
/// delivers haptic feedback, and auto-dismisses smoothly.
class AcedexToast {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    AcedexToastType type = AcedexToastType.info,
    Duration duration = const Duration(milliseconds: 3200),
    VoidCallback? onTap,
  }) {
    _dismissTimer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _AcedexToastWidget(
        message: message,
        title: title,
        type: type,
        onTap: () {
          dismiss();
          onTap?.call();
        },
        onDismiss: dismiss,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    HapticFeedback.lightImpact();

    _dismissTimer = Timer(duration, () {
      dismiss();
    });
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _AcedexToastWidget extends StatefulWidget {
  final String message;
  final String? title;
  final AcedexToastType type;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _AcedexToastWidget({
    required this.message,
    this.title,
    required this.type,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_AcedexToastWidget> createState() => _AcedexToastWidgetState();
}

class _AcedexToastWidgetState extends State<_AcedexToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 260),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color iconColor;
    IconData iconData;

    switch (widget.type) {
      case AcedexToastType.success:
        iconColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
        iconData = Icons.check_circle_rounded;
        break;
      case AcedexToastType.warning:
        iconColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
        iconData = Icons.warning_rounded;
        break;
      case AcedexToastType.error:
        iconColor = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
        iconData = Icons.error_rounded;
        break;
      case AcedexToastType.info:
        iconColor = theme.colorScheme.primary;
        iconData = Icons.info_rounded;
        break;
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Dismissible(
                  key: const Key('acedex_toast_dismiss'),
                  direction: DismissDirection.up,
                  onDismissed: (_) => widget.onDismiss(),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await _handleDismiss();
                        widget.onTap();
                      },
                      borderRadius: BorderRadius.circular(24.0),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 420),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B1B1F) : const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(22.0),
                          border: Border.all(
                            color: theme.colorScheme.outline,
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(iconData, color: iconColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.title != null) ...[
                                    Text(
                                      widget.title!,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                  Text(
                                    widget.message,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
