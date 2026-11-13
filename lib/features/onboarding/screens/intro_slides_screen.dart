import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// 3-Slide Interactive Intro Screen matching the updated UI design:
/// - Split-canvas visual architecture: Top pastel lilac hero backdrop + bottom curved content panel
/// - 3 minimalist top pagination dots
/// - Staggered slide-up animations for 3D character illustrations, headlines, and subtitles
/// - Asymmetric action row: "Skip" text button on the left, 60x60 squircle FAB on the right
/// - Smooth hand swiping gestures (PageView with BouncingScrollPhysics)
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
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        backgroundColor: isDark ? const Color(0xFF130D0F) : Colors.white,
        body: Stack(
          children: [
            // 1. PageView containing the 3 slide screens
            PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                _IntroSlidePage(
                  key: const ValueKey('slide_page_0'),
                  isActive: _currentPage == 0,
                  backdropColor: isDark
                      ? const Color(0xFF2E1E34)
                      : const Color(0xFFC9A0DC),
                  imageAsset: 'assets/images/intro/slide_1_offline.png',
                  headlineSpans: [
                    TextSpan(
                      text: 'Master ',
                      style: TextStyle(color: colors.primary),
                    ),
                    TextSpan(
                      text: 'Every Subject,\n100% ',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFF3EEF5)
                            : const Color(0xFF1D1722),
                      ),
                    ),
                    TextSpan(
                      text: 'Offline',
                      style: TextStyle(color: colors.primary),
                    ),
                  ],
                  subtitle:
                      'The complete Ethiopian Grade 9–12 syllabus,\nready to study anywhere—even offline.',
                  onSkip: widget.onFinish,
                  onNext: _onNext,
                  isLastPage: false,
                ),
                _IntroSlidePage(
                  key: const ValueKey('slide_page_1'),
                  isActive: _currentPage == 1,
                  backdropColor: isDark
                      ? const Color(0xFF2A1930)
                      : const Color(0xFFC49ED8),
                  imageAsset: 'assets/images/intro/slide_2_mastery.png',
                  headlineSpans: [
                    TextSpan(
                      text: 'Structured ',
                      style: TextStyle(color: colors.primary),
                    ),
                    TextSpan(
                      text: 'Mastery,\nUnmatched ',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFF3EEF5)
                            : const Color(0xFF1D1722),
                      ),
                    ),
                    TextSpan(
                      text: 'Focus',
                      style: TextStyle(color: colors.primary),
                    ),
                  ],
                  subtitle:
                      'Break chapters into clear subtopics, track progress,\nand stay focused with built-in study timers.',
                  onSkip: widget.onFinish,
                  onNext: _onNext,
                  isLastPage: false,
                ),
                _IntroSlidePage(
                  key: const ValueKey('slide_page_2'),
                  isActive: _currentPage == 2,
                  backdropColor: isDark
                      ? const Color(0xFF322039)
                      : const Color(0xFFD7B4E3),
                  imageAsset: 'assets/images/intro/slide_3_streaks.png',
                  headlineSpans: [
                    TextSpan(
                      text: 'Build ',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFF3EEF5)
                            : const Color(0xFF1D1722),
                      ),
                    ),
                    TextSpan(
                      text: 'Daily ',
                      style: TextStyle(color: colors.primary),
                    ),
                    TextSpan(
                      text: 'Streaks,\nConquer the ',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFF3EEF5)
                            : const Color(0xFF1D1722),
                      ),
                    ),
                    TextSpan(
                      text: 'EUEE',
                      style: TextStyle(color: colors.primary),
                    ),
                  ],
                  subtitle:
                      'Keep your streak alive with freezes, track your hours,\nand approach the EUEE with confidence.',
                  onSkip: widget.onFinish,
                  onNext: _onNext,
                  isLastPage: true,
                ),
              ],
            ),

            // 2. Persistent Top Centered Pagination Dots
            Positioned(
              top: MediaQuery.of(context).padding.top + AppTheme.space16,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      width: 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? colors.primary
                            : (isDark
                                ? const Color(0xFF483950)
                                : const Color(0xFFF1E8F5)),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual slide page with split two-tier layout (pastel backdrop + bottom curved content panel)
class _IntroSlidePage extends StatefulWidget {
  const _IntroSlidePage({
    super.key,
    required this.isActive,
    required this.backdropColor,
    required this.imageAsset,
    required this.headlineSpans,
    required this.subtitle,
    required this.onSkip,
    required this.onNext,
    required this.isLastPage,
  });

  final bool isActive;
  final Color backdropColor;
  final String imageAsset;
  final List<TextSpan> headlineSpans;
  final String subtitle;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final bool isLastPage;

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
      curve: const Interval(0.20, 0.95, curve: Curves.easeOutCubic),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelBg = isDark ? const Color(0xFF1A141D) : const Color(0xFFF9F7FC);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight;
        final topSectionHeight = totalHeight * 0.54;
        final bottomSectionHeight = totalHeight - topSectionHeight;

        return Stack(
          children: [
            // 1. Top Section: Pastel Hero Backdrop
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topSectionHeight + 40, // overlap behind the curved card
              child: Container(
                color: widget.backdropColor,
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 30,
                  bottom: 20,
                  left: AppTheme.space24,
                  right: AppTheme.space24,
                ),
                child: SlideTransition(
                  position: _imageSlideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Image.asset(
                      widget.imageAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Bottom Section: Curved Content Card
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: bottomSectionHeight + 30,
              child: Container(
                decoration: BoxDecoration(
                  color: panelBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30.0),
                  ),
                ),
                padding: EdgeInsets.only(
                  left: AppTheme.space24,
                  right: AppTheme.space24,
                  top: AppTheme.space32,
                  bottom:
                      MediaQuery.of(context).padding.bottom + AppTheme.space20,
                ),
                child: Column(
                  children: [
                    // Headline (Two-Tone Bold)
                    SlideTransition(
                      position: _headlineSlideAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              height: 1.22,
                              color: isDark
                                  ? const Color(0xFFF3EEF5)
                                  : const Color(0xFF1D1722),
                            ),
                            children: widget.headlineSpans,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.space12),

                    // Subtitle
                    SlideTransition(
                      position: _subtitleSlideAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark
                                ? const Color(0xFFA398A7)
                                : const Color(0xFF756B7A),
                            height: 1.42,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Asymmetric Bottom Action Row (Skip on left, 60x60 Squircle FAB on right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Skip text action
                        GestureDetector(
                          onTap: widget.onSkip,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.space12,
                              horizontal: AppTheme.space4,
                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFFA398A7)
                                    : const Color(0xFF756B7A),
                              ),
                            ),
                          ),
                        ),

                        // 60x60 Rounded Squircle Action Button
                        _SquircleActionButton(
                          key: const ValueKey('intro_action_button'),
                          color: colors.primary,
                          onPressed: widget.onNext,
                          tooltip: widget.isLastPage ? 'Get Started' : 'Next',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 60x60 rounded squircle action button matching Figma rectangle (radii: 20px)
class _SquircleActionButton extends StatefulWidget {
  const _SquircleActionButton({
    super.key,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  State<_SquircleActionButton> createState() => _SquircleActionButtonState();
}

class _SquircleActionButtonState extends State<_SquircleActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.tooltip,
      child: AnimatedScale(
        scale: _isPressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onPressed,
          child: Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: const Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
