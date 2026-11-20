import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Apple-Style Initial App Bootstrap Loading Screen
///
/// Features a gentle breathing crest animation, ambient radial glow,
/// and smooth auto-redirection to the Login screen once initialization completes.
class LoadingScreen extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onLoaded;

  const LoadingScreen({
    super.key,
    this.duration = const Duration(milliseconds: 1200),
    this.onLoaded,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _timer = Timer(widget.duration, _handleTransition);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTransition() {
    if (!mounted) return;

    if (widget.onLoaded != null) {
      widget.onLoaded!();
    } else {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Radial Glow
          Positioned(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: isDark ? 0.22 : 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Central Branding Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulsing Squircle Crest
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: isDark ? 0.45 : 0.28),
                          blurRadius: 28,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'A',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Brand Name
                Text(
                  'Acedex',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                Text(
                  'Ethiopian National Learning Platform',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    color: subtext,
                  ),
                ),
                const SizedBox(height: 48),

                // Subtle iOS-Style Indeterminate Spinner
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  'Preparing your study space...',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: subtext.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
