import 'package:flutter/material.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';
import '../models/onboarding_item.dart';
import '../widgets/onboarding_card.dart';
import '../widgets/onboarding_dots.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _handleComplete({bool goToLogin = false}) async {
    await AuthStorage.instance.setSeenOnboarding(true);
    if (!mounted) return;

    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.of(context).pushReplacementNamed(
        '/auth',
        arguments: {'initialTab': goToLogin ? 0 : 1},
      );
    }
  }

  void _nextPage() {
    if (_currentIndex < OnboardingItem.items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      _handleComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLastPage = _currentIndex == OnboardingItem.items.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          AnimatedOpacity(
            opacity: isLastPage ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: isLastPage,
              child: TextButton(
                onPressed: () => _handleComplete(goToLogin: true),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkSubtext
                        : AppColors.lightSubtext,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Slide Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: _onPageChanged,
                itemCount: OnboardingItem.items.length,
                itemBuilder: (context, index) {
                  return OnboardingCard(item: OnboardingItem.items[index]);
                },
              ),
            ),

            // Bottom Control Area: Dots + Tactile Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OnboardingDots(
                    count: OnboardingItem.items.length,
                    currentIndex: _currentIndex,
                  ),
                  const SizedBox(height: 28),
                  AcedexButton(
                    label: isLastPage ? 'Get Started' : 'Continue',
                    variant: AcedexButtonVariant.primary,
                    size: AcedexButtonSize.lg,
                    isFullWidth: true,
                    onPressed: _nextPage,
                  ),
                  if (isLastPage) ...[
                    const SizedBox(height: 10),
                    AcedexButton(
                      label: 'I already have an account',
                      variant: AcedexButtonVariant.ghost,
                      size: AcedexButtonSize.md,
                      isFullWidth: true,
                      onPressed: () => _handleComplete(goToLogin: true),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
