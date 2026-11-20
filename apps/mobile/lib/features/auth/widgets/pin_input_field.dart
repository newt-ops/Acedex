import 'package:flutter/material.dart';
import '../../../core/ui/ui.dart';

class PinInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String label;
  final String hintText;
  final bool enabled;

  const PinInputField({
    super.key,
    required this.controller,
    this.onChanged,
    this.errorText,
    this.label = '6-Digit Security PIN',
    this.hintText = 'Enter 6 digits',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AcedexTextField(
      controller: controller,
      label: label,
      hint: hintText,
      keyboardType: TextInputType.number,
      isPassword: true,
      enabled: enabled,
      errorText: errorText,
      prefixIcon: Icon(
        Icons.lock_outline_rounded,
        size: 20,
        color: theme.colorScheme.primary,
      ),
      onChanged: onChanged,
    );
  }
}
