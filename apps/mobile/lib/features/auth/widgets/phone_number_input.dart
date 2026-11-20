import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';

class PhoneNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool enabled;

  const PhoneNumberInput({
    super.key,
    required this.controller,
    this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AcedexTextField(
      controller: controller,
      label: 'Phone Number',
      hint: '0912 345 678',
      keyboardType: TextInputType.phone,
      enabled: enabled,
      errorText: errorText,
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🇪🇹',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Text(
              '+251',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 18,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ],
        ),
      ),
      onChanged: onChanged,
    );
  }
}
