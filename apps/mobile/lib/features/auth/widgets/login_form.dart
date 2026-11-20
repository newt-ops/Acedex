import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';
import '../services/auth_service.dart';

class LoginForm extends StatefulWidget {
  final ValueChanged<UserProfile>? onSuccess;
  final VoidCallback onSwitchToRegister;
  final AuthService? authService;
  final String? initialPhone;
  final ValueChanged<String>? onPhoneSubmitted;

  const LoginForm({
    super.key,
    this.onSuccess,
    required this.onSwitchToRegister,
    this.authService,
    this.initialPhone,
    this.onPhoneSubmitted,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _phoneController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null && widget.initialPhone!.isNotEmpty) {
      var phone = widget.initialPhone!;
      if (phone.startsWith('+251')) {
        phone = phone.substring(4);
      } else if (phone.startsWith('251')) {
        phone = phone.substring(3);
      } else if (phone.startsWith('0')) {
        phone = phone.substring(1);
      }
      _phoneController.text = phone;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _errorMessage = null;
    });

    final raw = _phoneController.text.trim();
    if (raw.isEmpty) {
      setState(() => _errorMessage = 'Please enter your phone number.');
      return;
    }

    final cleanPhone = AuthService.normalizePhone(raw);
    if (!AuthService.isValidPhone(cleanPhone)) {
      setState(() => _errorMessage =
          'Please enter a valid Ethiopian mobile number (e.g. 09... or 07...).');
      return;
    }

    if (widget.onPhoneSubmitted != null) {
      widget.onPhoneSubmitted!(cleanPhone);
    } else {
      Navigator.of(context).pushNamed(
        '/auth/pin',
        arguments: {'phone': cleanPhone},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Error Banner
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkErrorSoft : AppColors.lightErrorSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (isDark ? AppColors.darkError : AppColors.error)
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedAlertCircle,
                  size: 20,
                  color: isDark ? AppColors.darkError : AppColors.error,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkError : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Phone Input Label
        Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        // Phone Input Field with Ethiopian Country Code Container
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: line, width: 1.2),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedCall02,
                    color: accent,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '+251',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AcedexTextField(
                controller: _phoneController,
                hint: '912 345 678',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Supports formats: 09..., 07..., 9..., or 7...',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w400,
            color: subtext,
          ),
        ),
        const SizedBox(height: 24),

        // Continue to PIN Button
        AcedexButton(
          label: 'Continue',
          variant: AcedexButtonVariant.primary,
          size: AcedexButtonSize.lg,
          isFullWidth: true,
          trailingIcon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowRight01,
            size: 18,
            color: Colors.white,
          ),
          onPressed: _submit,
        ),
        const SizedBox(height: 20),

        // Divider
        Row(
          children: [
            Expanded(child: Container(height: 1, color: line)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'NEW TO ACEDEX?',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: subtext,
                ),
              ),
            ),
            Expanded(child: Container(height: 1, color: line)),
          ],
        ),
        const SizedBox(height: 16),

        // Create Account Action
        AcedexButton(
          label: 'Create Account',
          variant: AcedexButtonVariant.surface,
          size: AcedexButtonSize.md,
          isFullWidth: true,
          leadingIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedUserAdd01,
            size: 17,
            color: accent,
          ),
          onPressed: widget.onSwitchToRegister,
        ),
      ],
    );
  }
}
