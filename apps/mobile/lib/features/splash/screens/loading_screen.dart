import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';

/// Acedex Canonical Mobile App Intro / Bootstrap Loading Screen
///
/// Implements a 3-Stage Apple-grade choreography matching the canonical
/// interactive design specification:
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
/// Tap anywhere on screen advances stages immediately.
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _fallbackTimer;

  // Total normal timeline length in seconds matching HTML specification
  static const double _kTotalTimeline = 9.2;

  DateTime? _lastTick;
  double _waveTime = 0.0;

  @override
  void initState() {
    super.initState();

    final animDuration = widget.duration ?? const Duration(milliseconds: 9200);

    _controller = AnimationController(
      vsync: this,
      duration: animDuration,
    );

    _controller.addListener(_onTick);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleCompleted();
      }
    });

    if (widget.onLoaded != null) {
      // In fast-path test environments with an onLoaded callback
      _controller.forward();
      _fallbackTimer = Timer(widget.duration ?? const Duration(milliseconds: 100), () {
        if (mounted && widget.onLoaded != null) {
          widget.onLoaded!();
        }
      });
    } else {
      // Production runtime: continuously runs the full 9.2s multi-stage auto-loop
      _controller.repeat();
    }
  }

  void _onTick() {
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
    super.dispose();
  }

  void _handleCompleted() {
    if (!mounted) return;

    if (widget.onLoaded != null) {
      widget.onLoaded!();
    } else if (widget.autoTransition) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  void _onScreenTapped() {
    final t = _controller.value * _kTotalTimeline;
    if (t < 2.2) {
      // Advance immediately into Stage 2 (Focus deeply)
      _jumpTo(3.4 / _kTotalTimeline);
    } else if (t < 5.6) {
      // Advance immediately into Stage 3 (Ready / Dome Settle & CTA)
      _jumpTo(6.8 / _kTotalTimeline);
    } else {
      // In Stage 3, tapping the screen replays smoothly from Splash
      _jumpTo(0.0);
    }
  }

  void _jumpTo(double value) {
    _controller.value = value;
    if (widget.onLoaded == null) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  void _navigateToAuth() {
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
    final visualState = _evaluateChoreography(currentTime, waveTime, size);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _onScreenTapped,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. High-DPI Canvas for Continuous Liquid Morphing Dome
            CustomPaint(
              size: size,
              painter: _LiquidDomePainter(
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
                            painter: _AcedexLogoPainter(
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
                              _lerp(-12.0, 0.0, visualState.wordmarkSpring), 0),
                          child: Opacity(
                            opacity:
                                (visualState.wordmarkSpring * 1.35).clamp(0.0, 1.0),
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
                              horizontal: 14, vertical: 6),
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
                            // Concentric Breathing Rings
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
                            // Soft Radial Disc Backing
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: onAccent.withValues(alpha: 0.11),
                              ),
                            ),
                            // Crisp On-Accent Acedex Emblem
                            SizedBox(
                              width: 66,
                              height: 66,
                              child: CustomPaint(
                                painter: _AcedexLogoPainter(
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
                        // Pill Badge ("READY TO MASTER")
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
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
                        // Headline
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
                        // Subtitle
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
                        // Primary Tactile Button ("Get Started")
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
                                  color: accent.withValues(alpha: isDark ? 0.40 : 0.32),
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
                        // Secondary Link ("I already have an account")
                        AcedexBounceable(
                          onTap: visualState.readyOpacity > 0.5
                              ? _navigateToAuth
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
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

  // ========================================================================
  // 3-STAGE CHOREOGRAPHY EVALUATOR
  // ========================================================================
  _VisualState _evaluateChoreography(
      double time, double waveTime, Size screenSize) {
    // Stage apex target heights proportional to screen
    final yApexEmerge = screenSize.height * (650.0 / 812.0);
    final yApexFocus = screenSize.height * (286.0 / 812.0);
    final yApexReady = screenSize.height * (544.0 / 812.0);

    // Initial Splash Center Orb coordinate
    // Lockup is centered at (screenWidth / 2, screenHeight / 2 - 8)
    // Logo is 60x60 on the left of lockup:
    final lockupWidth = 60.0 + 12.0 + 105.0; // ~177px
    final lockupLeft = (screenSize.width - lockupWidth) / 2;
    final lockupTop = (screenSize.height - 60.0) / 2 - 8;
    final splashOrbOriginX = lockupLeft + 81.5 * (60.0 / 200.0);
    final splashOrbOriginY = lockupTop + 93.5 * (60.0 / 200.0);
    const splashOrbOriginR = 13.5 * (60.0 / 200.0); // 4.05

    // Stage 1: Splash (0.0s -> 2.2s)
    if (time < 2.2) {
      final archSp = _iosSpring(time - 0.06, stiffness: 250, damping: 21);
      final waveSp = _iosSpring(time - 0.18, stiffness: 250, damping: 21);
      final orbSp = _iosSpring(time - 0.30, stiffness: 290, damping: 20);
      final wordSp = _iosSpring(time - 0.34, stiffness: 240, damping: 23);

      return _VisualState(
        splashOpacity: 1.0,
        archSpring: archSp,
        waveSpring: waveSp,
        orbSpring: orbSp,
        wordmarkSpring: wordSp,
        svgOrbOpacity: 1.0,
        morph: 0.0,
        orbX: splashOrbOriginX,
        orbY: splashOrbOriginY,
        orbR: splashOrbOriginR,
        yApex: yApexEmerge,
        rippleAmp: 0.0,
        focusOpacity: 0.0,
        focusSlideY: 16.0,
        emblemOpacity: 0.0,
        emblemY: screenSize.height * (515.0 / 812.0),
        emblemScale: 0.85,
        readyOpacity: 0.0,
        readySlideY: 18.0,
      );
    }

    // Stage 2: Focus / Dome Rise (2.2s -> 5.6s)
    if (time < 5.6) {
      final localT = time - 2.2;

      // Outer splash pieces fade out smoothly (0.0 -> 0.44s)
      final splashFade = 1.0 - _smoothstep(0.0, 0.44, localT);

      // Center orb drops downward while swelling and morphing
      final dropT = _easeInOutSine(((localT - 0.04) / 0.72).clamp(0.0, 1.0));
      final morphT = ((localT - 0.28) / 0.88).clamp(0.0, 1.0);

      final orbX = _lerp(splashOrbOriginX, screenSize.width / 2, dropT);
      final orbY = _lerp(splashOrbOriginY, screenSize.height * (610.0 / 812.0), dropT);
      final orbR = _lerp(splashOrbOriginR, 34.0, dropT);

      // Dome rises smoothly to fill lower ~64%
      final riseProgress =
          _easeInOutSine(((localT - 0.45) / 1.35).clamp(0.0, 1.0));
      final yApex = _lerp(yApexEmerge, yApexFocus, riseProgress);

      // Upper editorial copy enters
      final focusEnter = _smoothstep(0.65, 1.25, localT);
      final focusSpring =
          _iosSpring(math.max(0.0, localT - 0.65), stiffness: 220, damping: 24);

      // Floating emblem inside dome
      final emblemEnter = _smoothstep(0.85, 1.45, localT);
      final floatBob = math.sin(waveTime * 1.6) * 4.5;
      final emblemY = _lerp(screenSize.height * (565.0 / 812.0),
              screenSize.height * (518.0 / 812.0), riseProgress) +
          floatBob;

      return _VisualState(
        splashOpacity: splashFade,
        archSpring: 1.0,
        waveSpring: 1.0,
        orbSpring: 1.0,
        wordmarkSpring: 1.0,
        svgOrbOpacity: localT < 0.06 ? 1.0 : 0.0,
        morph: morphT,
        orbX: orbX,
        orbY: orbY,
        orbR: orbR,
        yApex: yApex,
        rippleAmp: _smoothstep(0.45, 1.25, localT),
        focusOpacity: focusEnter,
        focusSlideY: _lerp(18.0, 0.0, focusSpring.clamp(0.0, 1.05)),
        emblemOpacity: emblemEnter,
        emblemY: emblemY,
        emblemScale: _lerp(0.86, 1.0, emblemEnter),
        readyOpacity: 0.0,
        readySlideY: 18.0,
      );
    }

    // Stage 3: Ready / Dome Settle & CTA (5.6s -> 9.2s)
    final localT = time - 5.6;

    // Dome glides down smoothly to ~33% lower fill
    final settleProgress = _easeInOutSine((localT / 1.25).clamp(0.0, 1.0));
    final yApex = _lerp(yApexFocus, yApexReady, settleProgress);

    // Stage 2 copy fades out cleanly during first 0.42s
    final focusExit = 1.0 - _smoothstep(0.0, 0.42, localT);

    // Stage 3 copy + CTA enters smoothly (0.42s -> 0.98s)
    final readyEnter = _smoothstep(0.42, 0.98, localT);
    final readySpring =
        _iosSpring(math.max(0.0, localT - 0.42), stiffness: 230, damping: 23);

    // Floating emblem glides smoothly down inside the lower dome
    final floatBob = math.sin(waveTime * 1.5) * 3.2;
    final emblemY = _lerp(screenSize.height * (518.0 / 812.0),
            screenSize.height * (678.0 / 812.0), settleProgress) +
        floatBob;
    final emblemScale = _lerp(1.0, 0.72, settleProgress);

    // Gentle fade out right at the end (3.22s -> 3.60s) so loop back to Splash is seamless
    final loopResetFade = 1.0 - _smoothstep(3.22, 3.60, localT);

    final morphT = _lerp(1.0, 0.0, _smoothstep(3.25, 3.60, localT));
    final orbX = splashOrbOriginX;
    final orbY = _lerp(screenSize.height * (610.0 / 812.0), splashOrbOriginY,
        _smoothstep(3.25, 3.60, localT));
    final orbR = _lerp(34.0, splashOrbOriginR, _smoothstep(3.25, 3.60, localT));

    return _VisualState(
      splashOpacity: 0.0,
      archSpring: 1.0,
      waveSpring: 1.0,
      orbSpring: 1.0,
      wordmarkSpring: 1.0,
      svgOrbOpacity: 0.0,
      morph: morphT,
      orbX: orbX,
      orbY: orbY,
      orbR: orbR,
      yApex: yApex,
      rippleAmp: loopResetFade,
      focusOpacity: focusExit,
      focusSlideY: _lerp(0.0, -12.0, 1.0 - focusExit),
      emblemOpacity: loopResetFade,
      emblemY: emblemY,
      emblemScale: emblemScale,
      readyOpacity: readyEnter * loopResetFade,
      readySlideY: _lerp(18.0, 0.0, readySpring.clamp(0.0, 1.05)),
    );
  }

  // ========================================================================
  // MATH & ANALYTICAL APPLE iOS DAMPED SPRING PHYSICS
  // ========================================================================
  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static double _smoothstep(double e0, double e1, double x) {
    final t = ((x - e0) / (e1 - e0)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  static double _easeInOutSine(double t) {
    return -(math.cos(math.pi * t.clamp(0.0, 1.0)) - 1) / 2;
  }

  static double _iosSpring(double t,
      {double stiffness = 260, double damping = 22, double mass = 1}) {
    if (t <= 0) return 0;
    final omega0 = math.sqrt(stiffness / mass);
    final zeta = damping / (2 * math.sqrt(stiffness * mass));
    if (zeta < 1) {
      final omegaD = omega0 * math.sqrt(1 - zeta * zeta);
      final decay = math.exp(-zeta * omega0 * t);
      return 1 -
          decay *
              (math.cos(omegaD * t) +
                  ((zeta * omega0) / omegaD) * math.sin(omegaD * t));
    }
    final decay = math.exp(-omega0 * t);
    return 1 - decay * (1 + omega0 * t);
  }
}

class _VisualState {
  final double splashOpacity;
  final double archSpring;
  final double waveSpring;
  final double orbSpring;
  final double wordmarkSpring;
  final double svgOrbOpacity;

  final double morph;
  final double orbX;
  final double orbY;
  final double orbR;
  final double yApex;
  final double rippleAmp;

  final double focusOpacity;
  final double focusSlideY;

  final double emblemOpacity;
  final double emblemY;
  final double emblemScale;

  final double readyOpacity;
  final double readySlideY;

  const _VisualState({
    required this.splashOpacity,
    required this.archSpring,
    required this.waveSpring,
    required this.orbSpring,
    required this.wordmarkSpring,
    required this.svgOrbOpacity,
    required this.morph,
    required this.orbX,
    required this.orbY,
    required this.orbR,
    required this.yApex,
    required this.rippleAmp,
    required this.focusOpacity,
    required this.focusSlideY,
    required this.emblemOpacity,
    required this.emblemY,
    required this.emblemScale,
    required this.readyOpacity,
    required this.readySlideY,
  });
}

// ============================================================================
// ACEDEX 3-PART VECTOR LOGO PAINTER (200x200 Coordinate Space)
// ============================================================================
class _AcedexLogoPainter extends CustomPainter {
  final double archSpring;
  final double waveSpring;
  final double orbSpring;
  final bool showOrb;
  final Color color;

  const _AcedexLogoPainter({
    required this.archSpring,
    required this.waveSpring,
    required this.orbSpring,
    required this.showOrb,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Scale from 200x200 viewBox to target size
    final scale = size.width / 200.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 1. Arch Part (a)
    final archAlpha = (archSpring * 1.4).clamp(0.0, 1.0);
    if (archAlpha > 0.01) {
      canvas.save();
      final tx = _LoadingScreenState._lerp(18.0, 0.0, archSpring);
      final ty = _LoadingScreenState._lerp(-16.0, 0.0, archSpring);
      final s = _LoadingScreenState._lerp(0.84, 1.0, archSpring);

      // Pivot around (115, 95)
      canvas.translate(115.0 + tx, 95.0 + ty);
      canvas.scale(s, s);
      canvas.translate(-115.0, -95.0);

      paint.color = color.withValues(alpha: archAlpha);

      final archPath = Path()
        ..moveTo(86.56, 48.27)
        ..arcToPoint(
          const Offset(113.44, 48.27),
          radius: const Radius.circular(15.5),
          clockwise: true,
        )
        ..lineTo(159.44, 128.27)
        ..arcToPoint(
          const Offset(132.56, 143.73),
          radius: const Radius.circular(15.5),
          clockwise: true,
        )
        ..lineTo(98.17, 83.92)
        ..arcToPoint(
          const Offset(77.20, 74.60),
          radius: const Radius.circular(19.35),
          clockwise: false,
        )
        ..cubicTo(80.10, 64.80, 83.20, 55.40, 86.56, 48.27)
        ..close();

      canvas.drawPath(archPath, paint);
      canvas.restore();
    }

    // 2. Wave Part (c)
    final waveAlpha = (waveSpring * 1.4).clamp(0.0, 1.0);
    if (waveAlpha > 0.01) {
      canvas.save();
      final tx = _LoadingScreenState._lerp(-16.0, 0.0, waveSpring);
      final ty = _LoadingScreenState._lerp(16.0, 0.0, waveSpring);
      final s = _LoadingScreenState._lerp(0.84, 1.0, waveSpring);

      // Pivot around (78, 130)
      canvas.translate(78.0 + tx, 130.0 + ty);
      canvas.scale(s, s);
      canvas.translate(-78.0, -130.0);

      paint.color = color.withValues(alpha: waveAlpha);

      final wavePath = Path()
        ..moveTo(66.80, 142.80)
        ..cubicTo(61.20, 149.20, 51.40, 148.60, 46.60, 142.20)
        ..cubicTo(41.80, 135.80, 43.20, 126.40, 50.20, 121.60)
        ..cubicTo(63.50, 112.50, 84.50, 110.50, 101.20, 113.00)
        ..cubicTo(107.20, 114.00, 111.00, 119.40, 110.00, 125.40)
        ..cubicTo(109.00, 131.20, 103.50, 134.60, 97.50, 133.60)
        ..cubicTo(85.00, 131.60, 74.20, 134.00, 66.80, 142.80)
        ..close();

      canvas.drawPath(wavePath, paint);
      canvas.restore();
    }

    // 3. Orb Part (b)
    if (showOrb && orbSpring > 0.001) {
      canvas.save();
      final s = math.max(0.001, orbSpring);

      // Pivot around (81.5, 93.5)
      canvas.translate(81.5, 93.5);
      canvas.scale(s, s);
      canvas.translate(-81.5, -93.5);

      paint.color = color.withValues(alpha: (orbSpring * 1.5).clamp(0.0, 1.0));
      canvas.drawCircle(const Offset(81.5, 93.5), 13.5, paint);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AcedexLogoPainter old) {
    return old.archSpring != archSpring ||
        old.waveSpring != waveSpring ||
        old.orbSpring != orbSpring ||
        old.showOrb != showOrb ||
        old.color != color;
  }
}

// ============================================================================
// CONTINUOUS LIQUID ORB-TO-DOME RENDERER (Multi-Harmonic Wave Ripples)
// ============================================================================
class _LiquidDomePainter extends CustomPainter {
  final double morph;
  final double orbX;
  final double orbY;
  final double orbR;
  final double yApex;
  final double rippleAmp;
  final double waveTime;
  final Color accentColor;
  final bool isDark;

  const _LiquidDomePainter({
    required this.morph,
    required this.orbX,
    required this.orbY,
    required this.orbR,
    required this.yApex,
    required this.rippleAmp,
    required this.waveTime,
    required this.accentColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (morph <= 0.001) return;

    final m = _LoadingScreenState._easeInOutSine(morph.clamp(0.0, 1.0));
    const steps = 112;

    final path = Path();

    for (int i = 0; i <= steps; i++) {
      final u = i / steps;
      final theta = -math.pi + (u / 0.65) * math.pi;
      final cx = orbX + orbR * math.cos(theta);
      final cy = orbY + orbR * math.sin(theta);

      final domePt = _sampleDomePerimeter(u % 1.0, yApex, rippleAmp, waveTime, size);

      final px = _LoadingScreenState._lerp(cx, domePt.dx, m);
      final py = _LoadingScreenState._lerp(cy, domePt.dy, m);

      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }

    path.close();

    // Fill with Canonical Royal Purple
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [accentColor, accentColor],
      ).createShader(Rect.fromLTWH(0, yApex - 10, size.width, size.height));
    canvas.drawPath(path, fillPaint);

    // Liquid surface sheen along the top horizon when dome is formed
    if (m > 0.35) {
      canvas.save();
      canvas.clipPath(path);

      final sheenAlpha = isDark ? 0.28 : 0.24;
      final sheenPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: sheenAlpha),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, yApex - 6, size.width, 52));

      canvas.drawRect(Rect.fromLTWH(0, yApex - 12, size.width, 64), sheenPaint);
      canvas.restore();
    }
  }

  Offset _sampleDomePerimeter(
      double u, double yApex, double rippleAmp, double phase, Size size) {
    const leftX = -18.0;
    final rightX = size.width + 18.0;
    final bottomY = size.height + 24.0;
    final archDrop = size.height * (36.0 / 812.0);

    if (u <= 0.65) {
      final s = u / 0.65;
      final x = _LoadingScreenState._lerp(leftX, rightX, s);
      final normX = 2 * s - 1;
      final archY = yApex + archDrop * (normX * normX);

      // Multi-harmonic liquid wave ripples
      final h1 = math.sin(s * math.pi * 2.1 - phase * 1.55) * 4.4;
      final h2 = math.cos(s * math.pi * 3.7 + phase * 1.15) * 2.1;
      final h3 = math.sin(s * math.pi * 5.6 - phase * 2.25) * 0.95;
      final waveOffset = (h1 + h2 + h3) * rippleAmp;

      return Offset(x, archY + waveOffset);
    }

    // Lower enclosure perimeter (right wall -> bottom -> left wall)
    final archDropEdge = yApex + archDrop;
    final rem = (u - 0.65) / 0.35;
    if (rem < 0.25) {
      final t = rem / 0.25;
      return Offset(rightX, _LoadingScreenState._lerp(archDropEdge, bottomY, t));
    }
    if (rem < 0.75) {
      final t = (rem - 0.25) / 0.5;
      return Offset(_LoadingScreenState._lerp(rightX, leftX, t), bottomY);
    }
    final t = (rem - 0.75) / 0.25;
    return Offset(leftX, _LoadingScreenState._lerp(bottomY, archDropEdge, t));
  }

  @override
  bool shouldRepaint(covariant _LiquidDomePainter old) {
    return old.morph != morph ||
        old.orbX != orbX ||
        old.orbY != orbY ||
        old.orbR != orbR ||
        old.yApex != yApex ||
        old.rippleAmp != rippleAmp ||
        old.waveTime != waveTime ||
        old.accentColor != accentColor ||
        old.isDark != isDark;
  }
}
