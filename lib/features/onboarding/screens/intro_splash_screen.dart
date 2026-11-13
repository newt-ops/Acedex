import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Full-screen Splash & Loading screen matching updated UI design:
/// - Brand logo header with smooth fade-up animation
/// - Ambient card spotlight with "Your study space, ready when you are."
/// - Minimalist circular loading spinner
/// - Bottom progress row: "SETTING UP YOUR STUDY SPACE" with dynamic percentage
/// - 5px rounded horizontal loading bar
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

    // 1. Logo and Card Fade-Up Controller (700ms)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
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

    // Canvas background
    final bgColor = isDark ? const Color(0xFF130D0F) : Colors.white;

    // Ambient spotlight background
    final ambientColor =
        isDark ? const Color(0xFF221726) : const Color(0xFFFCF8FD);

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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
            child: Column(
              children: [
                const Spacer(flex: 3),

                // 1. Brand Logo with Fade-Up Transition
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 280,
                        maxHeight: 88,
                      ),
                      child: Image.asset(
                        logoAsset,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.space24),

                // 2. Ambient Spotlight Card with Study Space Message
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 340),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.space32,
                        horizontal: AppTheme.space20,
                      ),
                      decoration: BoxDecoration(
                        color: ambientColor,
                        borderRadius: BorderRadius.circular(140.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Your study space,\nready when you are.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21.0,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                              letterSpacing: -0.4,
                              color: isDark
                                  ? const Color(0xFFF3EEF5)
                                  : const Color(0xFF211824),
                            ),
                          ),
                          const SizedBox(height: AppTheme.space8),
                          Text(
                            'Preparing your offline learning library',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark
                                  ? const Color(0xFFA398A7)
                                  : const Color(0xFF766A79),
                            ),
                          ),
                          const SizedBox(height: AppTheme.space24),
                          // Subtle 30x30 Circular Spinner
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colors.primary,
                              ),
                              backgroundColor: colors.primary.withValues(
                                alpha: isDark ? 0.20 : 0.12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 4),

                // 3. Bottom Progress Section (Status row + 5px Progress Bar)
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, _) {
                    final progressValue = _progressAnimation.value.clamp(0.0, 1.0);
                    final percentageText = '${(progressValue * 100).toInt()}%';

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status text and percentage
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SETTING UP YOUR STUDY SPACE',
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.1,
                                color: isDark
                                    ? const Color(0xFFA398A7)
                                    : const Color(0xFF766A79),
                              ),
                            ),
                            Text(
                              percentageText,
                              style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.space8),
                        // 5px Rounded Progress Bar
                        Container(
                          width: double.infinity,
                          height: 5.0,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2D2333)
                                : const Color(0xFFEFE9F2),
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progressValue,
                            child: Container(
                              height: 5.0,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(3.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppTheme.space24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
