import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PinDotsIndicator extends StatelessWidget {
  const PinDotsIndicator({
    super.key,
    required this.pinLength,
    this.maxDigits = 4,
    this.shakeAnimation,
  });

  final int pinLength;
  final int maxDigits;
  final Animation<double>? shakeAnimation;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Widget dotsRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxDigits, (index) {
        final isFilled = index < pinLength;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          width: isFilled ? 16.0 : 14.0,
          height: isFilled ? 16.0 : 14.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? colors.primary : colors.surfaceAlt,
            border: Border.all(
              color: isFilled ? colors.primary : colors.border,
              width: 1.5,
            ),
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );

    if (shakeAnimation != null) {
      return AnimatedBuilder(
        animation: shakeAnimation!,
        builder: (context, child) {
          final offset = 18.0 * shakeAnimation!.value;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: dotsRow,
      );
    }

    return dotsRow;
  }
}

