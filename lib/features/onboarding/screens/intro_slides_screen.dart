import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/acedex_button.dart';

/// 3-Slide Interactive Intro Screen adhering to the Acedex design system:
/// - Full-screen immersive display with transparent system bars
/// - Consistent typography, icon sizing, and layout matching app standards
/// - Hand swipe gesture (left/right PageView) + standard AcedexButton
/// - Top bar with back navigation, segmented step indicator, and Skip button
/// - Staggered slide-up animations for 3D illustration, headline, and subtitle
class IntroSlidesScreen extends StatefulWidget {
  const IntroSlidesScreen({
    super.key,
    required this.onFinish,
    this.initialPage = 0,
  });

  final VoidCallback onFinish;
  final int initialPage;

  @override
  State<IntroSlidesScreen> createState() => _IntroSlidesScreenState();
}

class _IntroSlidesScreenState extends State<IntroSlidesScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    HapticFeedback.selectionClick();
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onFinish();
    }
  }

  void _onPrevious() {
    HapticFeedback.selectionClick();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            children: [
              // Full-screen Top Bar
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + AppTheme.space8,
                  left: AppTheme.space16,
                  right: AppTheme.space16,
                  bottom: AppTheme.space4,
                ),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      IconButton(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          color: colors.textPrimary,
                          size: 22,
                        ),
                        onPressed: _onPrevious,
                      )
                    else
                      const SizedBox(width: 48),
                    const SizedBox(width: AppTheme.space8),
                    Expanded(
                      child: _StepIndicatorLines(
                        currentPage: _currentPage,
                        totalSteps: 3,
                        activeColor: colors.primary,
                        inactiveColor: isDark
                            ? const Color(0xFF383239)
                            : const Color(0xFFE5DEE6),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space8),
                    TextButton(
                      onPressed: widget.onFinish,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PageView with hand swipe enabled
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    _IntroSlidePage(
                      isActive: _currentPage == 0,
                      imageAsset: 'assets/images/intro/slide_1_offline.png',
                      headlineSpans: [
                        TextSpan(
                          text: 'Master ',
                          style: TextStyle(color: colors.primary),
                        ),
                        TextSpan(
                          text: 'Every Subject,\n100% ',
                          style: TextStyle(color: colors.textPrimary),
                        ),
                        TextSpan(
                          text: 'Offline',
                          style: TextStyle(color: colors.primary),
                        ),
                      ],
                      subtitle:
                          'The complete Ethiopian Grade 9–12 syllabus in your pocket. Study all units and subtopics anywhere, anytime—zero data required.',
                    ),
                    _IntroSlidePage(
                      isActive: _currentPage == 1,
                      imageAsset: 'assets/images/intro/slide_2_mastery.png',
                      headlineSpans: [
                        TextSpan(
                          text: 'Structured ',
                          style: TextStyle(color: colors.primary),
                        ),
                        TextSpan(
                          text: 'Mastery,\nUnmatched ',
                          style: TextStyle(color: colors.textPrimary),
                        ),
                        TextSpan(
                          text: 'Focus',
                          style: TextStyle(color: colors.primary),
                        ),
                      ],
                      subtitle:
                          'Break down heavy chapters into digestible subtopics. Track your progression from first read to total mastery with built-in focus timers.',
                    ),
                    _IntroSlidePage(
                      isActive: _currentPage == 2,
                      imageAsset: 'assets/images/intro/slide_3_streaks.png',
                      headlineSpans: [
                        TextSpan(
                          text: 'Build ',
                          style: TextStyle(color: colors.textPrimary),
                        ),
                        TextSpan(
                          text: 'Daily ',
                          style: TextStyle(color: colors.primary),
                        ),
                        TextSpan(
                          text: 'Streaks,\nConquer the ',
                          style: TextStyle(color: colors.textPrimary),
                        ),
                        TextSpan(
                          text: 'EUEE',
                          style: TextStyle(color: colors.primary),
                        ),
                      ],
                      subtitle:
                          'Build unstoppable daily study momentum with streak freezes, conquer your target hours, and walk into national exams with total confidence.',
                    ),
                  ],
                ),
              ),

              // Bottom Action Button using canonical AcedexButton
              Padding(
                padding: EdgeInsets.only(
                  left: AppTheme.space24,
                  right: AppTheme.space24,
                  bottom:
                      MediaQuery.of(context).padding.bottom + AppTheme.space20,
                  top: AppTheme.space8,
                ),
                child: AcedexButton(
                  label: _currentPage == 2 ? 'Get Started' : 'Next',
                  variant: AcedexButtonVariant.primary,
                  trailing: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    color: colors.onPrimary,
                    size: 20,
                  ),
                  onPressed: _onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Top segmented progress lines (1, 2, 3)
class _StepIndicatorLines extends StatelessWidget {
  const _StepIndicatorLines({
    required this.currentPage,
    required this.totalSteps,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int currentPage;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentPage;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            height: 3.0,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 3.0,
              right: index == totalSteps - 1 ? 0 : 3.0,
            ),
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
        );
      }),
    );
  }
}

/// Individual slide page with refined, app-consistent typography and balanced icon/illustration sizing
class _IntroSlidePage extends StatefulWidget {
  const _IntroSlidePage({
    required this.isActive,
    required this.imageAsset,
    required this.headlineSpans,
    required this.subtitle,
  });

  final bool isActive;
  final String imageAsset;
  final List<TextSpan> headlineSpans;
  final String subtitle;

  @override
  State<_IntroSlidePage> createState() => _IntroSlidePageState();
}

class _IntroSlidePageState extends State<_IntroSlidePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _imageSlideAnim;
  late final Animation<Offset> _headlineSlideAnim;
  late final Animation<Offset> _subtitleSlideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    // Staggered slide-up curves
    _imageSlideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    ));

    _headlineSlideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.16),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.12, 0.80, curve: Curves.easeOutCubic),
    ));

    _subtitleSlideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.20),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.22, 0.95, curve: Curves.easeOutCubic),
    ));

    if (widget.isActive) {
      _animController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _IntroSlidePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        // Balanced hero illustration height conforming to app proportions
        final imageHeight = (availableHeight * 0.30).clamp(160.0, 210.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
          child: Column(
            children: [
              const Spacer(flex: 1),
              // 1. 3D Character Illustration (Slide Up)
              SlideTransition(
                position: _imageSlideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SizedBox(
                    height: imageHeight,
                    child: Image.asset(widget.imageAsset, fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space20),

              // 2. Headline with Two-Tone Styling (App Standard 24px)
              SlideTransition(
                position: _headlineSlideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        height: 1.28,
                        color: colors.textPrimary,
                      ),
                      children: widget.headlineSpans,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space12),

              // 3. Subtitle (App Standard 14.5px)
              SlideTransition(
                position: _subtitleSlideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space8,
                    ),
                    child: Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: colors.textSecondary,
                        height: 1.45,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        );
      },
    );
  }
}
