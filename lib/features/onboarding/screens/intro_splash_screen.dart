import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Full-screen Splash & Loading screen that displays the Acedex Gemini brand logo
/// with a smooth fade-up animation and a horizontal loading bar underneath.
class IntroSplashScreen extends StatefulWidget {
  const IntroSplashScreen({
    super.key,
    required this.onLoadingComplete,
    this.duration = const Duration(milliseconds: 2000),
  });

  final VoidCallback onLoadingComplete;
  final Duration duration;

  @override
  State<IntroSplashScreen> createState() => _IntroSplashScreenState();
}

class _IntroSplashScreenState extends State<IntroSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _progressController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Logo Fade-Up Controller (700ms)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.16),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    // 2. Horizontal Progress Bar Controller
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onLoadingComplete();
      }
    });

    // Start animations
    _fadeController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;

    final logoAsset = isDark
        ? 'assets/logo/brand/acedex_logo_gemini_dark.jpg'
        : 'assets/logo/brand/acedex_logo_gemini_light.jpg';

    // Background matches exact corner pixels of brand JPG for seamless blend
    final bgColor = isDark ? const Color(0xFF130D0F) : const Color(0xFFFEFAFB);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // Fade-up logo animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 260,
                      maxHeight: 90,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space24,
                    ),
                    child: Image.asset(
                      logoAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space24),
              // Horizontal loading bar under the logo
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, _) {
                  return Container(
                    width: 200,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: colors.primary
                          .withValues(alpha: isDark ? 0.20 : 0.12),
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                      child: Container(
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}
