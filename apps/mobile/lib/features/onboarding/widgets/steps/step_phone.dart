import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/buttons/acedex_button.dart';
import '../../../../core/ui/inputs/acedex_text_field.dart';
import '../../../auth/services/auth_service.dart';

class StepPhone extends StatefulWidget {
  final String initialPhone;
  final ValueChanged<String> onPhoneChanged;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const StepPhone({
    super.key,
    required this.initialPhone,
    required this.onPhoneChanged,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<StepPhone> createState() => _StepPhoneState();
}

class _StepPhoneState extends State<StepPhone> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Strip +251 prefix if present for clean local display in field
    var display = widget.initialPhone;
    if (display.startsWith('+251')) {
      display = display.substring(4);
    } else if (display.startsWith('251')) {
      display = display.substring(3);
    } else if (display.startsWith('0')) {
      display = display.substring(1);
    }
    _controller = TextEditingController(text: display);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid {
    final raw = _controller.text.trim();
    return AuthService.isValidPhone('+251$raw') ||
        AuthService.isValidPhone(raw);
  }

  void _submit() {
    if (_isValid) {
      final clean = AuthService.normalizePhone('+251${_controller.text.trim()}');
      widget.onPhoneChanged(clean);
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Category Badge
          Text(
            'YOUR ACCOUNT',
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
            "What's your phone number?",
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
            "We'll use this to set up your student account.",
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: subtext,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 32),

          // Ethiopian Phone Input Row with +251 prefix
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // +251 Prefix Box
              Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: line, width: 1.2),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedSmartPhone01,
                      color: accent,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+251',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Phone digits
              Expanded(
                child: AcedexTextField(
                  controller: _controller,
                  hint: '9XXXXXXXX',
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  onChanged: (val) {
                    final normalized = AuthService.normalizePhone('+251$val');
                    widget.onPhoneChanged(normalized);
                    setState(() {});
                  },
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Helper Example
          Text(
            'Enter the number you use most.',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: subtext.withValues(alpha: 0.8),
            ),
          ),

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
            onPressed: _isValid ? _submit : null,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
