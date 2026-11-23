import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../models/student_avatar.dart';
import '../../models/user_profile.dart';
import '../../storage/auth_storage.dart';
import '../../theme/app_colors.dart';
import '../animations/bounceable.dart';
import '../avatars/student_avatar_widget.dart';
import '../feedback/profile_photo_modal.dart';
import '../../../main.dart';

/// Single Unified Apple iOS Header Bar (68px Height)
///
/// Features:
/// - Exact 68px Apple iOS header bar with frosted glass blur and thin border
/// - Left: 44x44px Circular Profile Avatar with royal purple gradient ring,
///   live green status dot, and camera edit micro-badge. Tapping opens ProfilePhotoModal.
/// - Left: Apple Greeting Stack ("Good morning/afternoon/evening" + "Hi, {Student First Name}")
/// - Right: Tactile Streak Pill ("12") with flame icon, spring bounce & floating "+1" pill badge
/// - Right: 38x38px Circular Notification Bell with unread royal purple dot & pendulum ring animation
class AcedexHeaderBar extends StatefulWidget implements PreferredSizeWidget {
  final UserProfile? user;
  final int initialStreak;
  final bool initialHasUnread;
  final VoidCallback? onProfileTap;
  final VoidCallback? onStreakTap;
  final VoidCallback? onNotificationTap;

  const AcedexHeaderBar({
    super.key,
    this.user,
    this.initialStreak = 12,
    this.initialHasUnread = true,
    this.onProfileTap,
    this.onStreakTap,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  State<AcedexHeaderBar> createState() => _AcedexHeaderBarState();
}

class _AcedexHeaderBarState extends State<AcedexHeaderBar>
    with TickerProviderStateMixin {
  late bool _hasUnread;

  // Notification bell pendulum ring animation controller
  late final AnimationController _bellRingController;
  late final Animation<double> _bellAngleAnimation;

  @override
  void initState() {
    super.initState();
    _hasUnread = widget.initialHasUnread;

    // Initialize avatar from AuthStorage if not already loaded
    AuthStorage.instance.getAvatar();

    // Bell pendulum ring animation
    _bellRingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _bellAngleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.28)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.28, end: 0.24)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.24, end: -0.15)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.15, end: 0.08)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.08, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 26,
      ),
    ]).animate(_bellRingController);
  }

  @override
  void dispose() {
    _bellRingController.dispose();
    super.dispose();
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String _getFirstName() {
    final displayName = widget.user?.displayName.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName.split(RegExp(r'\s+')).first;
    }
    return 'Student';
  }

  String _getInitials() {
    final name = widget.user?.displayName.trim();
    if (name == null || name.isEmpty) return 'AM';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  void _showThemeModePopover(BuildContext context) {
    HapticFeedback.selectionClick();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Theme Popover',
      barrierColor: Colors.black.withValues(alpha: 0.32),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final popoverBg = isDark ? const Color(0xFF1B1B20) : Colors.white;
        final border = isDark ? const Color(0xFF2E2E38) : const Color(0xFFE5E5EB);
        final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
        final primaryColor = theme.colorScheme.primary;

        final modes = [
          (
            ThemeMode.system,
            HugeIcons.strokeRoundedLaptop,
            'System Default',
            'Follow device settings',
            isDark ? Colors.white70 : const Color(0xFF4B5563),
          ),
          (
            ThemeMode.light,
            HugeIcons.strokeRoundedSun02,
            'Light Mode',
            'Clean, bright interface',
            const Color(0xFFF59E0B),
          ),
          (
            ThemeMode.dark,
            HugeIcons.strokeRoundedMoon02,
            'Dark Mode',
            'Deep OLED night palette',
            const Color(0xFF38BDF8),
          ),
        ];

        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 54, right: 16),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: popoverBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: border, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ValueListenableBuilder<ThemeMode>(
                    valueListenable: AcedexApp.themeModeNotifier,
                    builder: (context, currentMode, _) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Popover Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'APPEARANCE',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: subtextColor,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    currentMode.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: isDark ? const Color(0xFF282830) : const Color(0xFFEEEEF2),
                          ),
                          // 3 Features List (System, Light, Dark)
                          ...modes.map((item) {
                            final mode = item.$1;
                            final icon = item.$2;
                            final title = item.$3;
                            final subtitle = item.$4;
                            final iconColor = item.$5;
                            final isSelected = currentMode == mode;

                            return InkWell(
                              key: Key('theme_option_${mode.name}'),
                              onTap: () {
                                HapticFeedback.selectionClick();
                                AcedexApp.setThemeMode(mode);
                                Navigator.of(dialogContext).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                color: isSelected
                                    ? primaryColor.withValues(alpha: isDark ? 0.12 : 0.08)
                                    : Colors.transparent,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? iconColor.withValues(alpha: 0.16)
                                            : (isDark ? const Color(0xFF24242C) : const Color(0xFFF1F1F5)),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      alignment: Alignment.center,
                                      child: HugeIcon(
                                        icon: icon,
                                        color: iconColor,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                              color: isSelected ? primaryColor : theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 1.5),
                                          Text(
                                            subtitle,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: subtextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_rounded,
                                        size: 17,
                                        color: primaryColor,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            ),
            alignment: const Alignment(0.85, -0.85),
            child: child,
          ),
        );
      },
    );
  }

  void _onBellTapped() {
    HapticFeedback.lightImpact();
    setState(() {
      _hasUnread = !_hasUnread;
    });

    _bellRingController.forward(from: 0.0);
    widget.onNotificationTap?.call();
  }

  void _openProfileModal() {
    HapticFeedback.selectionClick();
    if (widget.onProfileTap != null) {
      widget.onProfileTap!();
    } else {
      ProfilePhotoModal.show(context, user: widget.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topPadding = MediaQuery.paddingOf(context).top;

    final bgGlass = isDark
        ? const Color(0xFF0E0E11).withValues(alpha: 0.88)
        : Colors.white.withValues(alpha: 0.88);
    final lineColor = isDark ? const Color(0xFF2B2B31) : const Color(0xFFE4E4E8);
    final surfaceColor = isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 68 + topPadding,
          padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
          decoration: BoxDecoration(
            color: bgGlass,
            border: Border(
              bottom: BorderSide(
                color: lineColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===============================================================
              // LEFT GROUP: 44x44 Avatar Button + Greeting Stack
              // ===============================================================
              Expanded(
                child: Row(
                  children: [
                    // 44x44 Circular Profile Avatar Button
                    AcedexBounceable(
                      onTap: _openProfileModal,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Royal Purple Gradient Ring
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF8A2BA3),
                                  Color(0xFFC064D8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.royalPurple.withValues(alpha: 0.34),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0xFF0E0E11) : Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: ValueListenableBuilder<StudentAvatar>(
                                valueListenable: AuthStorage.instance.avatarNotifier,
                                builder: (context, avatar, _) {
                                  return StudentAvatarWidget(
                                    avatar: avatar,
                                    size: 38,
                                    initials: _getInitials(),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Live Green Online Status Dot (Top-Left)
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF16A34A),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF0E0E11) : Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          // Camera Edit Micro-Badge (Bottom-Right)
                          Positioned(
                            bottom: -1,
                            right: -1,
                            child: Container(
                              width: 17,
                              height: 17,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.royalPurple,
                                border: Border.all(
                                  color: isDark ? const Color(0xFF0E0E11) : Colors.white,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.22),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const HugeIcon(
                                icon: HugeIcons.strokeRoundedCamera01,
                                color: Colors.white,
                                size: 9.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Authentic Apple iOS Greeting Stack
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTimeGreeting(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.1,
                              color: subtextColor,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Hi, ${_getFirstName()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ===============================================================
              // RIGHT GROUP: Tactile Streak Pill + Notification Bell
              // ===============================================================
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 3-Mode Appearance / Theme Toggle Button (System, Light, Dark)
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: AcedexApp.themeModeNotifier,
                    builder: (context, currentMode, _) {
                      final (icon, iconColor, tooltip) = switch (currentMode) {
                        ThemeMode.light => (
                            HugeIcons.strokeRoundedSun02,
                            const Color(0xFFF59E0B),
                            'Light Mode'
                          ),
                        ThemeMode.dark => (
                            HugeIcons.strokeRoundedMoon02,
                            const Color(0xFF38BDF8),
                            'Dark Mode'
                          ),
                        ThemeMode.system => (
                            HugeIcons.strokeRoundedLaptop,
                            isDark ? Colors.white70 : const Color(0xFF4B5563),
                            'System Mode'
                          ),
                      };

                      return Tooltip(
                        message: 'Appearance: $tooltip',
                        child: AcedexBounceable(
                          key: const Key('header_theme_toggle_button'),
                          onTap: () {
                            if (widget.onStreakTap != null) {
                              widget.onStreakTap!();
                            }
                            _showThemeModePopover(context);
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: surfaceColor,
                              border: Border.all(color: lineColor),
                            ),
                            alignment: Alignment.center,
                            child: HugeIcon(
                              icon: icon,
                              color: iconColor,
                              size: 17,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 8),

                  // Circular 38x38 Notification Bell Button
                  AcedexBounceable(
                    onTap: _onBellTapped,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: surfaceColor,
                            border: Border.all(color: lineColor),
                          ),
                          alignment: Alignment.center,
                          child: AnimatedBuilder(
                            animation: _bellRingController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _bellAngleAnimation.value,
                                alignment: const Alignment(0, -0.6),
                                child: child,
                              );
                            },
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedNotification01,
                              color: theme.colorScheme.onSurface,
                              size: 18,
                            ),
                          ),
                        ),

                        // Unread Royal Purple Dot
                        if (_hasUnread)
                          Positioned(
                            top: 8,
                            right: 9,
                            child: Container(
                              width: 7.5,
                              height: 7.5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.royalPurple,
                                border: Border.all(
                                  color: surfaceColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
