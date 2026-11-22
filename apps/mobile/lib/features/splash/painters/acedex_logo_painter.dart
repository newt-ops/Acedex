import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/splash_visual_state.dart';

/// Exact 3-Part Vector Acedex Logo Painter (Arch, Wave, Orb in 200x200 Coordinate Space)
class AcedexLogoPainter extends CustomPainter {
  final double archSpring;
  final double waveSpring;
  final double orbSpring;
  final bool showOrb;
  final Color color;

  const AcedexLogoPainter({
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
      final tx = SplashChoreographyEvaluator.lerp(18.0, 0.0, archSpring);
      final ty = SplashChoreographyEvaluator.lerp(-16.0, 0.0, archSpring);
      final s = SplashChoreographyEvaluator.lerp(0.84, 1.0, archSpring);

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
      final tx = SplashChoreographyEvaluator.lerp(-16.0, 0.0, waveSpring);
      final ty = SplashChoreographyEvaluator.lerp(16.0, 0.0, waveSpring);
      final s = SplashChoreographyEvaluator.lerp(0.84, 1.0, waveSpring);

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
  bool shouldRepaint(covariant AcedexLogoPainter old) {
    return old.archSpring != archSpring ||
        old.waveSpring != waveSpring ||
        old.orbSpring != orbSpring ||
        old.showOrb != showOrb ||
        old.color != color;
  }
}
