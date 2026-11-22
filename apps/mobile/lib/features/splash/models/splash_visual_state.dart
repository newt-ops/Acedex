import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Evaluated visual metrics for the 3-stage splash animation timeline.
class SplashVisualState {
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

  const SplashVisualState({
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

/// Mathematical evaluator and physics engine for the 3-Stage Apple-grade splash choreography.
class SplashChoreographyEvaluator {
  const SplashChoreographyEvaluator._();

  static SplashVisualState evaluate({
    required double time,
    required double waveTime,
    required Size screenSize,
  }) {
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
      final archSp = iosSpring(time - 0.06, stiffness: 250, damping: 21);
      final waveSp = iosSpring(time - 0.18, stiffness: 250, damping: 21);
      final orbSp = iosSpring(time - 0.30, stiffness: 290, damping: 20);
      final wordSp = iosSpring(time - 0.34, stiffness: 240, damping: 23);

      return SplashVisualState(
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
      final splashFade = 1.0 - smoothstep(0.0, 0.44, localT);

      // Center orb drops downward while swelling and morphing
      final dropT = easeInOutSine(((localT - 0.04) / 0.72).clamp(0.0, 1.0));
      final morphT = ((localT - 0.28) / 0.88).clamp(0.0, 1.0);

      final orbX = lerp(splashOrbOriginX, screenSize.width / 2, dropT);
      final orbY = lerp(
        splashOrbOriginY,
        screenSize.height * (610.0 / 812.0),
        dropT,
      );
      final orbR = lerp(splashOrbOriginR, 34.0, dropT);

      // Dome rises smoothly to fill lower ~64%
      final riseProgress = easeInOutSine(
        ((localT - 0.45) / 1.35).clamp(0.0, 1.0),
      );
      final yApex = lerp(yApexEmerge, yApexFocus, riseProgress);

      // Upper editorial copy enters
      final focusEnter = smoothstep(0.65, 1.25, localT);
      final focusSpring = iosSpring(
        math.max(0.0, localT - 0.65),
        stiffness: 220,
        damping: 24,
      );

      // Floating emblem inside dome
      final emblemEnter = smoothstep(0.85, 1.45, localT);
      final floatBob = math.sin(waveTime * 1.6) * 4.5;
      final emblemY =
          lerp(
            screenSize.height * (565.0 / 812.0),
            screenSize.height * (518.0 / 812.0),
            riseProgress,
          ) +
          floatBob;

      return SplashVisualState(
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
        rippleAmp: smoothstep(0.45, 1.25, localT),
        focusOpacity: focusEnter,
        focusSlideY: lerp(18.0, 0.0, focusSpring.clamp(0.0, 1.05)),
        emblemOpacity: emblemEnter,
        emblemY: emblemY,
        emblemScale: lerp(0.86, 1.0, emblemEnter),
        readyOpacity: 0.0,
        readySlideY: 18.0,
      );
    }

    // Stage 3: Ready / Dome Settle & CTA (5.6s -> settled state)
    // Sits permanently in this state waiting for user interaction (no loop)
    final localT = time - 5.6;

    // Dome glides down smoothly to ~33% lower fill
    final settleProgress = easeInOutSine((localT / 1.25).clamp(0.0, 1.0));
    final yApex = lerp(yApexFocus, yApexReady, settleProgress);

    // Stage 2 copy fades out cleanly during first 0.42s
    final focusExit = 1.0 - smoothstep(0.0, 0.42, localT);

    // Stage 3 copy + CTA enters smoothly (0.42s -> 0.98s)
    final readyEnter = smoothstep(0.42, 0.98, localT);
    final readySpring = iosSpring(
      math.max(0.0, localT - 0.42),
      stiffness: 230,
      damping: 23,
    );

    // Floating emblem glides smoothly down inside the lower dome
    final floatBob = math.sin(waveTime * 1.5) * 3.2;
    final emblemY =
        lerp(
          screenSize.height * (518.0 / 812.0),
          screenSize.height * (678.0 / 812.0),
          settleProgress,
        ) +
        floatBob;
    final emblemScale = lerp(1.0, 0.72, settleProgress);

    return SplashVisualState(
      splashOpacity: 0.0,
      archSpring: 1.0,
      waveSpring: 1.0,
      orbSpring: 1.0,
      wordmarkSpring: 1.0,
      svgOrbOpacity: 0.0,
      morph: 1.0,
      orbX: splashOrbOriginX,
      orbY: screenSize.height * (610.0 / 812.0),
      orbR: 34.0,
      yApex: yApex,
      rippleAmp: 1.0,
      focusOpacity: focusExit,
      focusSlideY: lerp(0.0, -12.0, 1.0 - focusExit),
      emblemOpacity: 1.0,
      emblemY: emblemY,
      emblemScale: emblemScale,
      readyOpacity: readyEnter,
      readySlideY: lerp(18.0, 0.0, readySpring.clamp(0.0, 1.05)),
    );
  }

  // Math & Analytical Apple iOS Damped Spring Physics
  static double lerp(double a, double b, double t) => a + (b - a) * t;

  static double smoothstep(double e0, double e1, double x) {
    final t = ((x - e0) / (e1 - e0)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  static double easeInOutSine(double t) {
    return -(math.cos(math.pi * t.clamp(0.0, 1.0)) - 1) / 2;
  }

  static double iosSpring(
    double t, {
    double stiffness = 260,
    double damping = 22,
    double mass = 1,
  }) {
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
