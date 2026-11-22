import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/splash_visual_state.dart';

/// Continuous Liquid Orb-to-Dome Renderer (Multi-Harmonic Wave Ripples)
class LiquidDomePainter extends CustomPainter {
  final double morph;
  final double orbX;
  final double orbY;
  final double orbR;
  final double yApex;
  final double rippleAmp;
  final double waveTime;
  final Color accentColor;
  final bool isDark;

  const LiquidDomePainter({
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

    final m = SplashChoreographyEvaluator.easeInOutSine(morph.clamp(0.0, 1.0));
    const steps = 112;

    final path = Path();

    for (int i = 0; i <= steps; i++) {
      final u = i / steps;
      final theta = -math.pi + (u / 0.65) * math.pi;
      final cx = orbX + orbR * math.cos(theta);
      final cy = orbY + orbR * math.sin(theta);

      final domePt = _sampleDomePerimeter(
        u % 1.0,
        yApex,
        rippleAmp,
        waveTime,
        size,
      );

      final px = SplashChoreographyEvaluator.lerp(cx, domePt.dx, m);
      final py = SplashChoreographyEvaluator.lerp(cy, domePt.dy, m);

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
    double u,
    double yApex,
    double rippleAmp,
    double phase,
    Size size,
  ) {
    const leftX = -18.0;
    final rightX = size.width + 18.0;
    final bottomY = size.height + 24.0;
    final archDrop = size.height * (36.0 / 812.0);

    if (u <= 0.65) {
      final s = u / 0.65;
      final x = SplashChoreographyEvaluator.lerp(leftX, rightX, s);
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
      return Offset(
        rightX,
        SplashChoreographyEvaluator.lerp(archDropEdge, bottomY, t),
      );
    }
    if (rem < 0.75) {
      final t = (rem - 0.25) / 0.5;
      return Offset(
        SplashChoreographyEvaluator.lerp(rightX, leftX, t),
        bottomY,
      );
    }
    final t = (rem - 0.75) / 0.25;
    return Offset(
      leftX,
      SplashChoreographyEvaluator.lerp(bottomY, archDropEdge, t),
    );
  }

  @override
  bool shouldRepaint(covariant LiquidDomePainter old) {
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
