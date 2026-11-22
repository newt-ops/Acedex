import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';

/// Cupertino Bottom Sheet: Change 6-Digit PIN Keypad
class PinKeypadSheet extends StatefulWidget {
  final ValueChanged<String> onShowToast;

  const PinKeypadSheet({
    super.key,
    required this.onShowToast,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onShowToast,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => PinKeypadSheet(onShowToast: onShowToast),
    );
  }

  @override
  State<PinKeypadSheet> createState() => _PinKeypadSheetState();
}

class _PinKeypadSheetState extends State<PinKeypadSheet> {
  String _digits = '';
  bool _isSaving = false;

  void _handleDigit(String digit) {
    if (_isSaving || _digits.length >= 6) return;
    setState(() => _digits += digit);

    if (_digits.length == 6) {
      setState(() => _isSaving = true);
      Future.delayed(const Duration(milliseconds: 760), () {
        if (mounted) {
          setState(() {
            _isSaving = false;
            _digits = '';
          });
          Navigator.of(context).pop();
          widget.onShowToast('6-Digit PIN updated');
        }
      });
    }
  }

  void _handleDelete() {
    if (_isSaving || _digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoftColor = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final sheetBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'del'];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: lineColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle & Header
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 8),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: lineColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACCOUNT SECURITY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: accentColor,
                            ),
                          ),
                          Text(
                            'Set New 6-Digit PIN',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      AcedexBounceable(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: lineColor),
                          ),
                          alignment: Alignment.center,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            color: theme.colorScheme.onSurface,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  // 6 Rounded PIN Slots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 6; i++) ...[
                        Container(
                          width: 44,
                          height: 48,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: i < _digits.length ? accentSoftColor : surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: i <= _digits.length ? accentColor : lineColor,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: i < _digits.length
                              ? Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Saving Indicator or Helper Note
                  SizedBox(
                    height: 24,
                    child: _isSaving
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AcedexDotsLoader(
                                color: accentColor,
                                dotSize: 4,
                                gap: 3,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Encrypting new PIN...',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Enter a memorable 6-digit numeric passcode',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: subtextColor,
                            ),
                          ),
                  ),

                  const SizedBox(height: 12),

                  // Cupertino Numeric Keypad (3 columns)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.85,
                    ),
                    itemCount: keys.length,
                    itemBuilder: (context, idx) {
                      final key = keys[idx];
                      if (key.isEmpty) return const SizedBox.shrink();

                      if (key == 'del') {
                        return AcedexBounceable(
                          onTap: _handleDelete,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedDelete02,
                              color: subtextColor,
                              size: 20,
                            ),
                          ),
                        );
                      }

                      return AcedexBounceable(
                        onTap: () => _handleDigit(key),
                        child: Container(
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: lineColor),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            key,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
