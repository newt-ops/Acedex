import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PinBoxesIndicator extends StatelessWidget {
  const PinBoxesIndicator({
    super.key,
    required this.pinLength,
    this.maxDigits = 4,
    this.isSuccess = false,
    this.isError = false,
    this.shakeAnimation,
  });

  final int pinLength;
  final int maxDigits;
  final bool isSuccess;
  final bool isError;
  final Animation<double>? shakeAnimation;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Widget boxesRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxDigits, (index) {
        final isFilled = index < pinLength;

        Color borderColor;
        Color dotColor;

        if (isError) {
          borderColor = colors.danger;
          dotColor = colors.danger;
        } else if (isSuccess) {
          borderColor = colors.success;
          dotColor = colors.success;
        } else if (isFilled) {
          borderColor = colors.primary;
          dotColor = colors.primary;
        } else {
          borderColor = colors.border;
          dotColor = Colors.transparent;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 7.0),
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Center(
            child: AnimatedScale(
              scale: (isFilled || isSuccess) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              child: Container(
                width: 9.0,
                height: 9.0,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
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
        child: boxesRow,
      );
    }

    return boxesRow;
  }
}
