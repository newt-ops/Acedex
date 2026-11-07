import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AcedexNavItem {
  const AcedexNavItem({
    required this.icon,
    this.tooltip,
  });

  final List<List<dynamic>> icon;
  final String? tooltip;
}

class AcedexFloatingNavBar extends StatelessWidget {
  const AcedexFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AcedexNavItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppTheme.space24,
        right: AppTheme.space24,
        bottom: bottomInset > 0 ? bottomInset + AppTheme.space8 : AppTheme.space20,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            height: 64.0,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(32.0),
              border: Border.all(
                color: colors.border.withValues(alpha: 0.6),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20.0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                final isSelected = index == currentIndex;
                final item = items[index];

                return _NavBarItemWidget(
                  isSelected: isSelected,
                  icon: item.icon,
                  tooltip: item.tooltip,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap(index);
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItemWidget extends StatefulWidget {
  const _NavBarItemWidget({
    required this.isSelected,
    required this.icon,
    this.tooltip,
    required this.onTap,
  });

  final bool isSelected;
  final List<List<dynamic>> icon;
  final String? tooltip;
  final VoidCallback onTap;

  @override
  State<_NavBarItemWidget> createState() => _NavBarItemWidgetState();
}

class _NavBarItemWidgetState extends State<_NavBarItemWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Tooltip(
          message: widget.tooltip ?? '',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: widget.isSelected ? colors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: HugeIcon(
              icon: widget.icon,
              color: widget.isSelected ? colors.primary : colors.textSecondary,
              size: 24.0,
            ),
          ),
        ),
      ),
    );
  }
}

