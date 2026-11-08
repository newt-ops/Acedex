import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'intro_splash_screen.dart';
import 'intro_slides_screen.dart';
import 'onboarding_screen.dart';

/// Flow coordinator managing the introductory lifecycle of Acedex:
/// 1. [IntroSplashScreen]: First launch fade-up brand logo + horizontal loading bar
/// 2. [IntroSlidesScreen]: 3 interactive Figma slides with 3D illustrations & staggered animations
/// 3. [OnboardingScreen]: Guided student setup (Name, Grade, Stream, Daily Target)
class IntroFlowScreen extends ConsumerStatefulWidget {
  const IntroFlowScreen({
    super.key,
    this.onCompleted,
    this.skipSplash = false,
  });

  final VoidCallback? onCompleted;
  final bool skipSplash;

  @override
  ConsumerState<IntroFlowScreen> createState() => _IntroFlowScreenState();
}

enum _FlowPhase {
  splash,
  slides,
  profileSetup,
}

class _IntroFlowScreenState extends ConsumerState<IntroFlowScreen> {
  late _FlowPhase _currentPhase;

  @override
  void initState() {
    super.initState();
    _currentPhase =
        widget.skipSplash ? _FlowPhase.slides : _FlowPhase.splash;
  }

  void _onLoadingComplete() {
    if (mounted) {
      setState(() {
        _currentPhase = _FlowPhase.slides;
      });
    }
  }

  void _onSlidesFinish() {
    if (mounted) {
      setState(() {
        _currentPhase = _FlowPhase.profileSetup;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildPhaseContent(),
    );
  }

  Widget _buildPhaseContent() {
    switch (_currentPhase) {
      case _FlowPhase.splash:
        return IntroSplashScreen(
          key: const ValueKey('intro_splash'),
          onLoadingComplete: _onLoadingComplete,
        );
      case _FlowPhase.slides:
        return IntroSlidesScreen(
          key: const ValueKey('intro_slides'),
          onFinish: _onSlidesFinish,
        );
      case _FlowPhase.profileSetup:
        return OnboardingScreen(
          key: const ValueKey('intro_profile_setup'),
          initialPage: 1, // Start directly at Name & Gender setup
          onCompleted: widget.onCompleted,
        );
    }
  }
}

