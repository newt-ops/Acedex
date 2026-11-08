import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// 3-Slide Interactive Intro Screen matching the Figma slide design:
/// - Top 3-segment progress indicator lines
/// - Hand swipe gesture (left/right PageView) + Next / Get Started button
/// - Staggered slide-up animations for 3D illustration, headline, subtitle, and button
/// - Two-tone brand plum highlighted headlines
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
    HapticFeedback.lightImpact();
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0E0B0E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppTheme.space12),
            // Top 3-segment progress lines
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
              child: _StepIndicatorLines(
                currentPage: _currentPage,
                totalSteps: 3,
                activeColor: colors.primary,
                inactiveColor: isDark
                    ? const Color(0xFF383239)
                    : const Color(0xFFE1DAE2),
              ),
            ),
            const SizedBox(height: AppTheme.space8),

            // PageView with hand swiping enabled
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
                    buttonLabel: 'Next  ›',
                    onButtonPressed: _onNext,
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
                    buttonLabel: 'Next  ›',
                    onButtonPressed: _onNext,
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
                        'Build unstoppable daily study momentum with streak freezes, conquer your target hours, and walk into national exams with total confidence',
                    buttonLabel: 'Get Started  ›',
                    onButtonPressed: _onNext,
                  ),
                ],
              ),
            ),
          ],
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
          child: Container(
            height: 3.0,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 4.0,
              right: index == totalSteps - 1 ? 0 : 4.0,
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

/// Individual slide page with staggered slide-up animations for each component
class _IntroSlidePage extends StatefulWidget {
  const _IntroSlidePage({
    required this.isActive,
    required this.imageAsset,
    required this.headlineSpans,
    required this.subtitle,
    required this.buttonLabel,
    required this.onButtonPressed,
  });

  final bool isActive;
  final String imageAsset;
  final List<TextSpan> headlineSpans;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onButtonPressed;

  @override
  State<_IntroSlidePage> createState() => _IntroSlidePageState();
}

class _IntroSlidePageState extends State<_IntroSlidePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _imageSlideAnim;
  late final Animation<Offset> _headlineSlideAnim;
  late final Animation<Offset> _subtitleSlideAnim;
  late final Animation<Offset> _buttonSlideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    // Staggered slide-up curves (all sliding up from bottom to top)
    _imageSlideAnim =
        Tween<Offset>(begin: const Offset(0.0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.0, 0.70, curve: Curves.easeOutCubic),
          ),
        );

    _headlineSlideAnim =
        Tween<Offset>(begin: const Offset(0.0, 0.20), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    _subtitleSlideAnim =
        Tween<Offset>(begin: const Offset(0.0, 0.24), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.25, 0.95, curve: Curves.easeOutCubic),
          ),
        );

    _buttonSlideAnim =
        Tween<Offset>(begin: const Offset(0.0, 0.30), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
          ),
        );

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
        final imageHeight = (availableHeight * 0.38).clamp(180.0, 280.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
          child: Column(
            children: [
              const Spacer(flex: 1),
              // 1. 3D Illustration (Slide Up)
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

              // 2. Headline with Two-Tone Styling (Slide Up)
              SlideTransition(
                position: _headlineSlideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 27.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        height: 1.25,
                      ),
                      children: widget.headlineSpans,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space12),

              // 3. Subtitle (Slide Up)
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
                        fontSize: 13.0,
                        color: colors.textSecondary,
                        height: 1.45,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),

              // 4. Bottom Button (Slide Up)
              SlideTransition(
                position: _buttonSlideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SizedBox(
                    width: double.infinity,
                    height: 48.0,
                    child: _PressableButton(
                      label: widget.buttonLabel,
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      onPressed: widget.onButtonPressed,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space24),
            ],
          ),
        );
      },
    );
  }
}

/// Clean button matching Figma design with smooth tactile press scaling and zero glow
class _PressableButton extends StatefulWidget {
  const _PressableButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: widget.foregroundColor,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
