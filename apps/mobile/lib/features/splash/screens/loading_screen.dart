import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../models/splash_visual_state.dart';
import '../painters/acedex_logo_painter.dart';
import '../painters/liquid_dome_painter.dart';

/// Acedex Canonical Mobile App First-Time Splash Screen
///
/// Implements a 3-Stage Apple-grade choreography:
/// - Stage 1 (0.0s – 2.2s): Splash lockup with staggered Apple springs for the
///   3-part vector Acedex mark (arch, wave, orb) and geometric "Acedex" wordmark.
/// - Stage 2 (2.2s – 5.6s): Liquid morph from center orb into a full-bleed convex
///   Royal Purple dome with multi-harmonic wave ripples, revealing upper
///   "STUDY FLOW" / "Focus deeply" editorial copy and floating dome emblem with
///   concentric breathing rings.
/// - Stage 3 (5.6s – 7.0s+): Dome gracefully settles to lower ~33% of the viewport,
///   revealing "READY TO MASTER" / "Ace every exam" copy, primary "Get Started" CTA,
///   and secondary "I already have an account" login link.
///
/// Displayed exclusively on first-time app launch.
class LoadingScreen extends StatefulWidget {
  final Duration? duration;
  final VoidCallback? onLoaded;
  final bool autoTransition;

  const LoadingScreen({
    super.key,
    this.duration,
    this.onLoaded,
    this.autoTransition = false,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _waveController;
  Timer? _fallbackTimer;

  static const double _kTotalTimeline = 7.0;

  DateTime? _lastTick;
  double _waveTime = 0.0;

  @override
  void initState() {
    super.initState();

    final animDuration = widget.duration ?? const Duration(milliseconds: 7000);
    _controller = AnimationController(vsync: this, duration: animDuration);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _waveController.addListener(_onWaveTick);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleCompleted();
      }
    });

    _controller.forward();

    if (widget.onLoaded != null) {
      _fallbackTimer = Timer(
        widget.duration ?? const Duration(milliseconds: 100),
        () {
          if (mounted && widget.onLoaded != null) {
            widget.onLoaded!();
          }
        },
      );
    }
  }

  void _onWaveTick() {
    final now = DateTime.now();
    if (_lastTick != null) {
      final dt = (now.difference(_lastTick!).inMicroseconds) / 1000000.0;
      _waveTime += dt.clamp(0.0, 0.05) * 1.75;
    } else {
      _waveTime += 0.016 * 1.75;
    }
    _lastTick = now;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _handleCompleted() {
    if (!mounted) return;
    unawaited(AuthStorage.instance.setSeenSplash(true));

    if (widget.onLoaded != null) {
      widget.onLoaded!();
    } else if (widget.autoTransition) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  void _navigateToOnboarding() {
    unawaited(AuthStorage.instance.setSeenSplash(true));
    Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  void _navigateToAuth() {
    unawaited(AuthStorage.instance.setSeenSplash(true));
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final accentSoft =
        isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;
    final onAccent = isDark ? AppColors.darkOnAccent : AppColors.lightOnAccent;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final media = MediaQuery.of(context);
    final size = media.size;

    // Timeline evaluation
    final currentTime = _controller.value * _kTotalTimeline;
    final waveTime = _waveTime > 0 ? _waveTime : (currentTime * 1.75);
    final visualState = SplashChoreographyEvaluator.evaluate(
      time: currentTime,
      waveTime: waveTime,
      screenSize: size,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. High-DPI Canvas for Continuous Liquid Morphing Dome
          CustomPaint(
            size: size,
            painter: LiquidDomePainter(
              morph: visualState.morph,
              orbX: visualState.orbX,
              orbY: visualState.orbY,
              orbR: visualState.orbR,
              yApex: visualState.yApex,
              rippleAmp: visualState.rippleAmp,
              waveTime: waveTime,
              accentColor: accent,
              isDark: isDark,
            ),
          ),

          // 2. Stage 1: Splash Lockup (Staggered Logo Springs + Wordmark)
          if (visualState.splashOpacity > 0.005)
            Opacity(
              opacity: visualState.splashOpacity.clamp(0.0, 1.0),
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Exact 3-Part Vector Mark (60x60)
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CustomPaint(
                          painter: AcedexLogoPainter(
                            archSpring: visualState.archSpring,
                            waveSpring: visualState.waveSpring,
                            orbSpring: visualState.orbSpring,
                            showOrb: visualState.svgOrbOpacity > 0.5,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Bold Geometric Wordmark ("Acedex")
                      Transform.translate(
                        offset: Offset(
                          SplashChoreographyEvaluator.lerp(
                              -12.0, 0.0, visualState.wordmarkSpring),
                          0,
                        ),
                        child: Opacity(
                          opacity: (visualState.wordmarkSpring * 1.35).clamp(
                            0.0,
                            1.0,
                          ),
                          child: Text(
                            'Acedex',
                            style: TextStyle(
                              fontSize: 31,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                              color: text,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 3. Stage 2: Focus Editorial Copy ("Focus deeply")
          if (visualState.focusOpacity > 0.005)
            Positioned(
              top: media.padding.top + 36,
              left: 24,
              right: 24,
              child: Opacity(
                opacity: visualState.focusOpacity.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, visualState.focusSlideY),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pill Badge ("STUDY FLOW")
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accentSoft,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: border, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'STUDY FLOW',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Headline
                      Text(
                        'Focus deeply',
                        style: TextStyle(
                          fontSize: 31,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // Subtitle
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text(
                          'Distraction-free study sessions engineered for deep retention.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                            color: subtext,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 4. Floating On-Accent Emblem + 3 Concentric Focus Rings inside Dome
          if (visualState.emblemOpacity > 0.005)
            Positioned(
              top: visualState.emblemY,
              left: size.width / 2,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Opacity(
                  opacity: visualState.emblemOpacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: visualState.emblemScale,
                    child: SizedBox(
                      width: 190,
                      height: 190,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildPulsingRing(
                            size: 176,
                            strokeWidth: 1.0,
                            opacity: 0.07,
                            color: onAccent,
                            scale: 1 + math.sin(waveTime * 1.8 - 1.6) * 0.11,
                          ),
                          _buildPulsingRing(
                            size: 136,
                            strokeWidth: 1.25,
                            opacity: 0.14,
                            color: onAccent,
                            scale: 1 + math.sin(waveTime * 1.8 - 0.8) * 0.09,
                          ),
                          _buildPulsingRing(
                            size: 96,
                            strokeWidth: 1.5,
                            opacity: 0.25,
                            color: onAccent,
                            scale: 1 + math.sin(waveTime * 1.8) * 0.07,
                          ),
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: onAccent.withValues(alpha: 0.11),
                            ),
                          ),
                          SizedBox(
                            width: 66,
                            height: 66,
                            child: CustomPaint(
                              painter: AcedexLogoPainter(
                                archSpring: 1.0,
                                waveSpring: 1.0,
                                orbSpring: 1.0,
                                showOrb: true,
                                color: onAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 5. Stage 3: Ready / Dome Settle & Tactile CTA
          if (visualState.readyOpacity > 0.005)
            Positioned(
              top: media.padding.top + 48,
              left: 28,
              right: 28,
              child: Opacity(
                opacity: visualState.readyOpacity.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, visualState.readySlideY),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accentSoft,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: border, width: 1),
                        ),
                        child: Text(
                          'READY TO MASTER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Ace every exam',
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text(
                          'Smart flashcards, active recall & daily study streaks.',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                            color: subtext,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                      AcedexBounceable(
                        onTap: visualState.readyOpacity > 0.5
                            ? _navigateToOnboarding
                            : null,
                        child: Container(
                          width: 276,
                          height: 54,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(
                                  alpha: isDark ? 0.40 : 0.32,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: onAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedArrowRight01,
                                color: onAccent,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AcedexBounceable(
                        onTap: visualState.readyOpacity > 0.5
                            ? _navigateToAuth
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'I already have an account',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: subtext,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPulsingRing({
    required double size,
    required double strokeWidth,
    required double opacity,
    required Color color,
    required double scale,
  }) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: opacity),
            width: strokeWidth,
          ),
        ),
      ),
    );
  }
}
