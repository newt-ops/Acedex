import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum AcedexToastStatus {
  info,
  success,
  warning,
  danger,
}

class AcedexToast {
  static _AcedexToastWidgetState? _activeToastState;
  static OverlayEntry? _activeOverlayEntry;

  static void show(
    BuildContext context, {
    required String title,
    String? message,
    AcedexToastStatus status = AcedexToastStatus.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    // If a toast is currently active, slide it out immediately
    if (_activeToastState != null && _activeToastState!.mounted) {
      _activeToastState!.dismissImmediately();
    } else if (_activeOverlayEntry != null && _activeOverlayEntry!.mounted) {
      _activeOverlayEntry!.remove();
      _activeOverlayEntry = null;
    }

    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AcedexToastWidget(
        title: title,
        message: message,
        status: status,
        duration: duration,
        onRemoved: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
          if (_activeOverlayEntry == overlayEntry) {
            _activeOverlayEntry = null;
            _activeToastState = null;
          }
        },
      ),
    );

    _activeOverlayEntry = overlayEntry;
    overlayState.insert(overlayEntry);
  }
}

class _AcedexToastWidget extends StatefulWidget {
  const _AcedexToastWidget({
    required this.title,
    this.message,
    required this.status,
    required this.duration,
    required this.onRemoved,
  });

  final String title;
  final String? message;
  final AcedexToastStatus status;
  final Duration duration;
  final VoidCallback onRemoved;

  @override
  State<_AcedexToastWidget> createState() => _AcedexToastWidgetState();
}

class _AcedexToastWidgetState extends State<_AcedexToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    AcedexToast._activeToastState = this;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 440),
      reverseDuration: const Duration(milliseconds: 280),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );

    _controller.forward();

    _timer = Timer(widget.duration, () {
      dismiss();
    });
  }

  void dismiss() {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _timer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onRemoved();
      }
    });
  }

  void dismissImmediately() {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _timer?.cancel();
    _controller.reverse(from: _controller.value).then((_) {
      if (mounted) {
        widget.onRemoved();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Color statusColor;
    List<List<dynamic>> iconData;

    switch (widget.status) {
      case AcedexToastStatus.info:
        statusColor = colors.info;
        iconData = HugeIcons.strokeRoundedInformationCircle;
        break;
      case AcedexToastStatus.success:
        statusColor = colors.success;
        iconData = HugeIcons.strokeRoundedCheckmarkCircle02;
        break;
      case AcedexToastStatus.warning:
        statusColor = colors.warning;
        iconData = HugeIcons.strokeRoundedAlert02;
        break;
      case AcedexToastStatus.danger:
        statusColor = colors.danger;
        iconData = HugeIcons.strokeRoundedCancelCircle;
        break;
    }

    final topPadding = MediaQuery.of(context).padding.top + AppTheme.space12;

    return Positioned(
      top: topPadding,
      left: AppTheme.space16,
      right: AppTheme.space16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: dismiss,
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! < -4) {
                  dismiss();
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space16,
                      vertical: AppTheme.space12,
                    ),
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        colors.statusTint(statusColor).withValues(alpha: 0.25),
                        colors.surface,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(
                        color: colors.statusBorder(statusColor),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 18.0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: colors.statusTint(statusColor),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.statusBorder(statusColor),
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: HugeIcon(
                              icon: iconData,
                              color: statusColor,
                              size: 20.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.space12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                              if (widget.message != null && widget.message!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.message!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
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
  );
}
}
