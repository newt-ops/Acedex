import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/buttons/acedex_button.dart';
import '../../../../core/ui/inputs/acedex_text_field.dart';

class StepName extends StatefulWidget {
  final String initialName;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onContinue;

  const StepName({
    super.key,
    required this.initialName,
    required this.onNameChanged,
    required this.onContinue,
  });

  @override
  State<StepName> createState() => _StepNameState();
}

class _StepNameState extends State<StepName> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid => _controller.text.trim().length >= 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Category Badge
          Text(
            'ABOUT YOU',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),

          // Main Title
          Text(
            "What's your name?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          Text(
            "Tell us what you'd like us to call you.",
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: subtext,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 32),

          // Name Input Field
          AcedexTextField(
            controller: _controller,
            hint: 'Full name',
            autofocus: true,
            prefixIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              color: accent,
              size: 20,
            ),
            onChanged: (val) {
              widget.onNameChanged(val);
              setState(() {});
            },
            onSubmitted: (_) {
              if (_isValid) widget.onContinue();
            },
          ),
          const SizedBox(height: 10),

          const Spacer(),

          // Continue Button
          AcedexButton(
            label: 'Continue',
            variant: AcedexButtonVariant.primary,
            size: AcedexButtonSize.lg,
            isFullWidth: true,
            trailingIcon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: Colors.white,
              size: 18,
            ),
            onPressed: _isValid ? widget.onContinue : null,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
