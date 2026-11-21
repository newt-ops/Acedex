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
  late int _streakCount;
  late bool _hasUnread;

  // Streak bounce & +1 float animation controllers
  late final AnimationController _streakBounceController;
  late final AnimationController _plusOneController;
  late final Animation<double> _plusOneOffsetAnimation;
  late final Animation<double> _plusOneOpacityAnimation;

  // Notification bell pendulum ring animation controller
  late final AnimationController _bellRingController;
  late final Animation<double> _bellAngleAnimation;

  @override
  void initState() {
    super.initState();
    _streakCount = widget.initialStreak;
    _hasUnread = widget.initialHasUnread;

    // Initialize avatar from AuthStorage if not already loaded
    AuthStorage.instance.getAvatar();

    // Streak spring bounce
    _streakBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    // Floating +1 pill animation
    _plusOneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _plusOneOffsetAnimation = Tween<double>(begin: 4.0, end: -28.0).animate(
      CurvedAnimation(
        parent: _plusOneController,
        curve: Curves.easeOutCubic,
      ),
    );
    _plusOneOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_plusOneController);

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
    _streakBounceController.dispose();
    _plusOneController.dispose();
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

  void _onStreakTapped() {
    HapticFeedback.lightImpact();
    setState(() {
      _streakCount += 1;
    });

    _streakBounceController.forward(from: 0.0);
    _plusOneController.forward(from: 0.0);
    widget.onStreakTap?.call();
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
                  // Tactile Streak Pill Button with Floating "+1" Badge
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Floating "+1" Royal Purple Pill Badge
                      AnimatedBuilder(
                        animation: _plusOneController,
                        builder: (context, child) {
                          if (!_plusOneController.isAnimating) {
                            return const SizedBox.shrink();
                          }
                          return Positioned(
                            top: _plusOneOffsetAnimation.value,
                            child: Opacity(
                              opacity: _plusOneOpacityAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.royalPurple,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.royalPurple.withValues(alpha: 0.36),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '+1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Streak Pill Button
                      AcedexBounceable(
                        onTap: _onStreakTapped,
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 11),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: lineColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const HugeIcon(
                                icon: HugeIcons.strokeRoundedFire,
                                color: Color(0xFFF59E0B),
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '$_streakCount',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
