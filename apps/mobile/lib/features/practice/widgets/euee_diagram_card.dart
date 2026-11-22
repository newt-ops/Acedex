import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/practice_models.dart';

/// Renders authentic vector diagrams for EUEE physics, math, chemistry, and biology questions
class EueeDiagramCard extends StatelessWidget {
  final EueeDiagramType diagramType;

  const EueeDiagramCard({super.key, required this.diagramType});

  @override
  Widget build(BuildContext context) {
    if (diagramType == EueeDiagramType.none) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final accent = isDark ? AppColors.accentDark : AppColors.royalPurple;
    final accentSoft =
        isDark ? accent.withValues(alpha: 0.18) : AppColors.royalPurpleSoft;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Container(
      width: double.infinity,
      height: 90,
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lineColor),
      ),
      child: CustomPaint(
        painter: _EueeDiagramPainter(
          diagramType: diagramType,
          accent: accent,
          accentSoft: accentSoft,
          textColor: textColor,
          subtextColor: subtextColor,
        ),
      ),
    );
  }
}

class _EueeDiagramPainter extends CustomPainter {
  final EueeDiagramType diagramType;
  final Color accent;
  final Color accentSoft;
  final Color textColor;
  final Color subtextColor;

  _EueeDiagramPainter({
    required this.diagramType,
    required this.accent,
    required this.accentSoft,
    required this.textColor,
    required this.subtextColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (diagramType) {
      case EueeDiagramType.coilFlux:
        _drawCoilFlux(canvas, size);
        break;
      case EueeDiagramType.integralArea:
        _drawIntegralArea(canvas, size);
        break;
      case EueeDiagramType.galvanicCell:
        _drawGalvanicCell(canvas, size);
        break;
      case EueeDiagramType.replicationFork:
        _drawReplicationFork(canvas, size);
        break;
      case EueeDiagramType.none:
        break;
    }
  }

  void _drawCoilFlux(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final coilCenterX = size.width * 0.32;

    // Field lines
    final fieldPaint = Paint()
      ..color = subtextColor
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final yOffsets = [centerY - 18, centerY, centerY + 18];
    for (final y in yOffsets) {
      canvas.drawLine(
        Offset(size.width * 0.08, y),
        Offset(size.width * 0.65, y),
        fieldPaint,
      );
      // Arrow head
      final arrowPath = Path()
        ..moveTo(size.width * 0.62, y - 3.5)
        ..lineTo(size.width * 0.66, y)
        ..lineTo(size.width * 0.62, y + 3.5);
      canvas.drawPath(arrowPath, fieldPaint);
    }

    // Coil 1 (Fill & Stroke)
    final coilRect = Rect.fromCenter(
      center: Offset(coilCenterX, centerY),
      width: 44,
      height: 60,
    );
    canvas.drawOval(
      coilRect,
      Paint()
        ..color = accentSoft
        ..style = PaintingStyle.fill,
    );
    canvas.drawOval(
      coilRect,
      Paint()
        ..color = accent
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );

    // Coil 2 (Offset dash)
    final coilRect2 = Rect.fromCenter(
      center: Offset(coilCenterX + 8, centerY),
      width: 44,
      height: 60,
    );
    canvas.drawOval(
      coilRect2,
      Paint()
        ..color = accent.withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // Labels
    _drawText(
      canvas,
      text: 'B(t) decreasing',
      offset: Offset(size.width * 0.68, centerY - 14),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
    _drawText(
      canvas,
      text: 'N = 50 turns',
      offset: Offset(size.width * 0.68, centerY + 2),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: accent,
      ),
    );
  }

  void _drawIntegralArea(Canvas canvas, Size size) {
    final originX = size.width * 0.18;
    final originY = size.height * 0.82;
    final maxX = size.width * 0.58;

    final axisPaint = Paint()
      ..color = subtextColor
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    // Axes
    canvas.drawLine(
      Offset(originX - 10, originY),
      Offset(maxX + 20, originY),
      axisPaint,
    );
    canvas.drawLine(
      Offset(originX, originY + 6),
      Offset(originX, 10),
      axisPaint,
    );

    // Shaded Area under Curve (x=0 to x=2)
    final x2 = originX + 70;
    final curvePath = Path()..moveTo(originX, originY);
    curvePath.quadraticBezierTo(
      originX + 35,
      originY - 12,
      x2,
      originY - 48,
    );
    curvePath.lineTo(x2, originY);
    curvePath.close();

    canvas.drawPath(
      curvePath,
      Paint()
        ..color = accentSoft
        ..style = PaintingStyle.fill,
    );

    // Curve outline
    final strokePath = Path()..moveTo(originX, originY);
    strokePath.quadraticBezierTo(
      originX + 35,
      originY - 12,
      x2,
      originY - 48,
    );
    canvas.drawPath(
      strokePath,
      Paint()
        ..color = accent
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );

    // Vertical boundary line at x=2
    canvas.drawLine(
      Offset(x2, originY),
      Offset(x2, originY - 48),
      Paint()
        ..color = accent
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke,
    );

    // Limit ticks
    _drawText(
      canvas,
      text: '0',
      offset: Offset(originX - 3, originY + 2),
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: subtextColor,
      ),
    );
    _drawText(
      canvas,
      text: '2',
      offset: Offset(x2 - 2, originY + 2),
      style: TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        color: accent,
      ),
    );

    // Equations
    _drawText(
      canvas,
      text: 'f(x) = 3x² + 2x',
      offset: Offset(size.width * 0.65, size.height * 0.22),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
    _drawText(
      canvas,
      text: 'Area = F(2) − F(0)',
      offset: Offset(size.width * 0.65, size.height * 0.48),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: accent,
      ),
    );
  }

  void _drawGalvanicCell(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final b1X = size.width * 0.16;
    final b2X = size.width * 0.62;

    // Beaker 1 (Zn)
    final b1Rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(b1X, centerY - 14, 52, 42),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      b1Rect,
      Paint()
        ..color = accentSoft
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      b1Rect,
      Paint()
        ..color = accent
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );

    // Beaker 2 (Cu)
    final b2Rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(b2X, centerY - 14, 52, 42),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      b2Rect,
      Paint()
        ..color = accentSoft
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      b2Rect,
      Paint()
        ..color = accent
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );

    // Wire across top
    final wirePaint = Paint()
      ..color = textColor
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final wirePath = Path()
      ..moveTo(b1X + 26, centerY - 14)
      ..lineTo(b1X + 26, 14)
      ..lineTo(b2X + 26, 14)
      ..lineTo(b2X + 26, centerY - 14);
    canvas.drawPath(wirePath, wirePaint);

    // Voltmeter circle
    final vX = (b1X + 26 + b2X + 26) / 2;
    canvas.drawCircle(
      Offset(vX, 14),
      9,
      Paint()
        ..color = accent
        ..style = PaintingStyle.fill,
    );
    _drawText(
      canvas,
      text: 'V',
      offset: Offset(vX - 4, 8),
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    );

    // Salt Bridge
    final bridgePath = Path()
      ..moveTo(b1X + 42, centerY)
      ..lineTo(vX, centerY - 5)
      ..lineTo(b2X + 10, centerY);
    canvas.drawPath(
      bridgePath,
      Paint()
        ..color = subtextColor
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // Beaker Labels
    _drawText(
      canvas,
      text: 'Zn (−)',
      offset: Offset(b1X + 11, centerY + 8),
      style: TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
    );
    _drawText(
      canvas,
      text: 'Cu (+)',
      offset: Offset(b2X + 11, centerY + 8),
      style: TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
    );
  }

  void _drawReplicationFork(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final forkX = size.width * 0.40;

    final dnaPaint = Paint()
      ..color = accent
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Unopened double helix (left)
    final d1 = Path()
      ..moveTo(size.width * 0.08, centerY - 12)
      ..quadraticBezierTo(
        size.width * 0.24,
        centerY - 12,
        forkX,
        centerY,
      );
    final d2 = Path()
      ..moveTo(size.width * 0.08, centerY + 12)
      ..quadraticBezierTo(
        size.width * 0.24,
        centerY + 12,
        forkX,
        centerY,
      );
    canvas.drawPath(d1, dnaPaint);
    canvas.drawPath(d2, dnaPaint);

    // Fork junction circle
    canvas.drawCircle(
      Offset(forkX, centerY),
      7,
      Paint()
        ..color = accentSoft
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(forkX, centerY),
      7,
      Paint()
        ..color = accent
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );

    // Split branches (right)
    canvas.drawLine(
      Offset(forkX, centerY),
      Offset(size.width * 0.68, centerY - 24),
      dnaPaint,
    );
    canvas.drawLine(
      Offset(forkX, centerY),
      Offset(size.width * 0.68, centerY + 24),
      dnaPaint,
    );

    // Labels
    _drawText(
      canvas,
      text: "5′ → 3′ Leading",
      offset: Offset(size.width * 0.70, centerY - 28),
      style: TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
    );
    _drawText(
      canvas,
      text: "Okazaki Lagging",
      offset: Offset(size.width * 0.70, centerY + 16),
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: subtextColor,
      ),
    );
  }

  void _drawText(
    Canvas canvas, {
    required String text,
    required Offset offset,
    required TextStyle style,
  }) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _EueeDiagramPainter oldDelegate) {
    return oldDelegate.diagramType != diagramType ||
        oldDelegate.accent != accent ||
        oldDelegate.textColor != textColor;
  }
}
