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
  static void show(
    BuildContext context, {
    required String title,
    String? message,
    AcedexToastStatus status = AcedexToastStatus.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AcedexToastWidget(
        title: title,
        message: message,
        status: status,
        onDismiss: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        },
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _AcedexToastWidget extends StatefulWidget {
  const _AcedexToastWidget({
    required this.title,
    this.message,
    required this.status,
    required this.onDismiss,
  });

  final String title;
  final String? message;
  final AcedexToastStatus status;
  final VoidCallback onDismiss;

  @override
  State<_AcedexToastWidget> createState() => _AcedexToastWidgetState();
}

class _AcedexToastWidgetState extends State<_AcedexToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space16,
                  vertical: AppTheme.space12,
                ),
                decoration: BoxDecoration(
                  color: colors.statusTint(statusColor),
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(
                    color: colors.statusBorder(statusColor),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: iconData,
                      color: statusColor,
                      size: 22.0,
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
                              fontWeight: FontWeight.w600,
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
    );
  }
}

