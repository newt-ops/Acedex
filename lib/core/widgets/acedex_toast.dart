import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';

enum AcedexToastStatus {
  info,
  success,
  warning,
  danger,
  error,
}

class AcedexToast {
  static _AcedexToastWidgetState? _activeToastState;
  static OverlayEntry? _activeOverlayEntry;

  /// Show an Apple-style capsule toast HUD notification.
  ///
  /// Matches Apple HIG design:
  /// - Fully rounded stadium capsule shape (`BorderRadius.circular(100)`).
  /// - Top (under Dynamic Island / notch) or bottom presentation with spring bounce physics.
  /// - Animatable Presets with circular filled badge (e.g. "Done / Confirmed").
  /// - Custom icon / widget support (e.g. sun icon / custom image).
  /// - "Only Title" mode (icon-less compact pill).
  /// - Slide-up recoil exit animation and drag-to-dismiss gestures.
  static void show(
    BuildContext context, {
    required String title,
    String? message,
    AcedexToastStatus? status = AcedexToastStatus.info,
    Widget? leading,
    List<List<dynamic>>? customIcon,
    Color? iconColor,
    Color? badgeColor,
    bool showIcon = true,
    bool useCircularBadge = true,
    Duration duration = const Duration(seconds: 3),
    bool isBottom = false,
  }) {
    // If a toast is currently active, slide it out immediately without stacking
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
        leading: leading,
        customIcon: customIcon,
        iconColor: iconColor,
        badgeColor: badgeColor,
        showIcon: showIcon && (status != null || customIcon != null || leading != null),
        useCircularBadge: useCircularBadge && status != null && leading == null && customIcon == null,
        duration: duration,
        isBottom: isBottom,
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

  /// Preset: Success notification (Apple emerald circular badge with white checkmark)
  static void success(
    BuildContext context, {
    required String title,
    String? message,
    bool isBottom = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      title: title,
      message: message,
      status: AcedexToastStatus.success,
      isBottom: isBottom,
      duration: duration,
    );
  }

  /// Preset: Info notification (Apple system blue circular badge with white checkmark)
  static void info(
    BuildContext context, {
    required String title,
    String? message,
    bool isBottom = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      title: title,
      message: message,
      status: AcedexToastStatus.info,
      isBottom: isBottom,
      duration: duration,
    );
  }

  /// Preset: Warning notification (Apple orange circular badge)
  static void warning(
    BuildContext context, {
    required String title,
    String? message,
    bool isBottom = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      title: title,
      message: message,
      status: AcedexToastStatus.warning,
      isBottom: isBottom,
      duration: duration,
    );
  }

  /// Preset: Danger notification (Apple red circular badge)
  static void danger(
    BuildContext context, {
    required String title,
    String? message,
    bool isBottom = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      title: title,
      message: message,
      status: AcedexToastStatus.danger,
      isBottom: isBottom,
      duration: duration,
    );
  }

  /// Preset: Only Title (Compact stadium capsule with text only)
  static void onlyTitle(
    BuildContext context, {
    required String title,
    bool isBottom = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      title: title,
      showIcon: false,
      status: null,
      isBottom: isBottom,
      duration: duration,
    );
  }

  /// Preset: Custom Icon / Image (e.g. Sun icon, Padlock, or custom widget)
  static void custom(
    BuildContext context, {
    required String title,
    String? message,
    Widget? leading,
    List<List<dynamic>>? customIcon,
    Color? iconColor,
    bool isBottom = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      title: title,
      message: message,
      leading: leading,
      customIcon: customIcon,
      iconColor: iconColor,
      status: null,
      useCircularBadge: false,
      isBottom: isBottom,
      duration: duration,
    );
  }
}

class _AcedexToastWidget extends StatefulWidget {
  const _AcedexToastWidget({
    required this.title,
    this.message,
    this.status,
    this.leading,
    this.customIcon,
    this.iconColor,
    this.badgeColor,
    required this.showIcon,
    required this.useCircularBadge,
    required this.duration,
    required this.isBottom,
    required this.onRemoved,
  });

  final String title;
  final String? message;
  final AcedexToastStatus? status;
  final Widget? leading;
  final List<List<dynamic>>? customIcon;
  final Color? iconColor;
  final Color? badgeColor;
  final bool showIcon;
  final bool useCircularBadge;
  final Duration duration;
  final bool isBottom;
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

    // Tactile Apple haptic click
    HapticFeedback.lightImpact();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
      reverseDuration: const Duration(milliseconds: 260),
    );

    final startOffset = widget.isBottom ? const Offset(0, 1.35) : const Offset(0, -1.35);

    _offsetAnimation = Tween<Offset>(
      begin: startOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.78,
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
    // Fast recoil transition to make room for incoming notification
    _controller.animateTo(
      0.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInBack,
    ).then((_) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor;
    List<List<dynamic>> defaultIconData;

    switch (widget.status) {
      case AcedexToastStatus.info:
        statusColor = const Color(0xFF007AFF); // Apple System Blue
        defaultIconData = HugeIcons.strokeRoundedCheck;
        break;
      case AcedexToastStatus.success:
        statusColor = const Color(0xFF34C759); // Apple System Green
        defaultIconData = HugeIcons.strokeRoundedCheck;
        break;
      case AcedexToastStatus.warning:
        statusColor = const Color(0xFFFF9500); // Apple System Orange
        defaultIconData = HugeIcons.strokeRoundedAlert02;
        break;
      case AcedexToastStatus.danger:
      case AcedexToastStatus.error:
        statusColor = const Color(0xFFFF3B30); // Apple System Red
        defaultIconData = HugeIcons.strokeRoundedCancel01;
        break;
      case null:
        statusColor = colors.primary;
        defaultIconData = HugeIcons.strokeRoundedCheck;
        break;
    }

    final finalIcon = widget.customIcon ?? defaultIconData;
    final finalIconColor = widget.iconColor ?? statusColor;
    final finalBadgeColor = widget.badgeColor ?? statusColor;

    Widget? leadingWidget;
    if (widget.showIcon) {
      if (widget.leading != null) {
        leadingWidget = widget.leading;
      } else if (widget.useCircularBadge) {
        leadingWidget = Container(
          width: 26.0,
          height: 26.0,
          decoration: BoxDecoration(
            color: finalBadgeColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: HugeIcon(
              icon: finalIcon,
              color: Colors.white,
              size: 15.0,
            ),
          ),
        );
      } else {
        leadingWidget = HugeIcon(
          icon: finalIcon,
          color: finalIconColor,
          size: 22.0,
        );
      }
    }

    final topPadding = MediaQuery.of(context).padding.top + 10.0;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 84.0;
    final hasMessage = widget.message != null && widget.message!.trim().isNotEmpty;
    final hasLeading = leadingWidget != null;

    final capsuleBgColor = isDark
        ? const Color(0xFF1E1A22).withValues(alpha: 0.94)
        : Colors.white.withValues(alpha: 0.96);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.05);

    return Positioned(
      top: widget.isBottom ? null : topPadding,
      bottom: widget.isBottom ? bottomPadding : null,
      left: 0,
      right: 0,
      child: Align(
        alignment: widget.isBottom ? Alignment.bottomCenter : Alignment.topCenter,
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
                    if (widget.isBottom) {
                      if (details.primaryDelta != null && details.primaryDelta! > 4) {
                        dismiss();
                      }
                    } else {
                      if (details.primaryDelta != null && details.primaryDelta! < -4) {
                        dismiss();
                      }
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 120.0,
                          maxWidth: 340.0,
                          minHeight: 44.0,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: hasLeading ? 18.0 : 22.0,
                          vertical: hasMessage ? 10.0 : 10.5,
                        ),
                        decoration: BoxDecoration(
                          color: capsuleBgColor,
                          borderRadius: BorderRadius.circular(100.0),
                          border: Border.all(
                            color: borderColor,
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                              blurRadius: 28.0,
                              offset: const Offset(0, 10),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
                              blurRadius: 8.0,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (leadingWidget != null) ...[
                              leadingWidget,
                              const SizedBox(width: 10.0),
                            ],
                            Flexible(
                              child: hasMessage
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.title,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: colors.textPrimary,
                                            letterSpacing: -0.2,
                                            height: 1.15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2.0),
                                        Text(
                                          widget.message!,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w400,
                                            color: colors.textSecondary,
                                            letterSpacing: -0.1,
                                            height: 1.15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    )
                                  : Text(
                                      widget.title,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                        color: colors.textPrimary,
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
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
