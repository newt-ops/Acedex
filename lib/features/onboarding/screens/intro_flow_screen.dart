import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../auth/screens/google_auth_screen.dart';
import 'intro_splash_screen.dart';
import 'intro_slides_screen.dart';
import 'onboarding_screen.dart';

/// Flow coordinator managing the introductory lifecycle of Acedex:
/// 1. [IntroSplashScreen]: First launch fade-up brand logo + horizontal loading bar
/// 2. [IntroSlidesScreen]: 3 interactive Figma slides with 3D illustrations & staggered animations
/// 3. [GoogleAuthScreen]: "Continue with Google" authentication screen
/// 4. [OnboardingScreen]: Guided student setup (Identity/Name, Grade, Stream, Daily Target, Academic Pass)
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
  auth,
  onboarding,
}

class _IntroFlowScreenState extends ConsumerState<IntroFlowScreen> {
  late _FlowPhase _currentPhase;

  @override
  void initState() {
    super.initState();
    _currentPhase = widget.skipSplash ? _FlowPhase.slides : _FlowPhase.splash;
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
        if (SupabaseService.isAuthenticated) {
          _currentPhase = _FlowPhase.onboarding;
        } else {
          _currentPhase = _FlowPhase.auth;
        }
      });
    }
  }

  void _onAuthenticated() {
    if (mounted) {
      setState(() {
        _currentPhase = _FlowPhase.onboarding;
      });
    }
  }

  void _onAuthBack() {
    if (mounted) {
      setState(() {
        _currentPhase = _FlowPhase.slides;
      });
    }
  }

  void _onOnboardingBack() {
    if (mounted) {
      setState(() {
        _currentPhase = _FlowPhase.auth;
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
      case _FlowPhase.auth:
        return GoogleAuthScreen(
          key: const ValueKey('intro_auth'),
          onAuthenticated: _onAuthenticated,
          onBack: _onAuthBack,
        );
      case _FlowPhase.onboarding:
        return OnboardingScreen(
          key: const ValueKey('intro_onboarding'),
          initialPage: 0,
          onCompleted: widget.onCompleted,
          onBack: _onOnboardingBack,
        );
    }
  }
}
