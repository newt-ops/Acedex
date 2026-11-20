import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';
import '../services/auth_service.dart';
import 'phone_number_input.dart';
import 'pin_input_field.dart';

class LoginForm extends StatefulWidget {
  final ValueChanged<UserProfile> onSuccess;
  final VoidCallback onSwitchToRegister;
  final AuthService? authService;
  final String? initialPhone;

  const LoginForm({
    super.key,
    required this.onSuccess,
    required this.onSwitchToRegister,
    this.authService,
    this.initialPhone,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();

  late final AuthService _authService;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
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
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
    });

    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Please enter your phone number.');
      return;
    }
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Please enter your 6-digit security PIN.');
      return;
    }
    if (pin.length < 6) {
      setState(() => _errorMessage = 'PIN must be at least 6 digits.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cleanPhone = AuthService.normalizePhone(
        phone.startsWith('+251') ? phone : '+251$phone',
      );
      final user = await _authService.login(phone: cleanPhone, pin: pin);
      if (!mounted) return;
      widget.onSuccess(user);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Unable to connect to Acedex. Please check your internet connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

        // Phone Input
        PhoneNumberInput(
          controller: _phoneController,
          enabled: !_isLoading,
          onChanged: (_) {
            if (_errorMessage != null) setState(() => _errorMessage = null);
          },
        ),
        const SizedBox(height: 14),

        // PIN Input
        PinInputField(
          controller: _pinController,
          enabled: !_isLoading,
          onChanged: (_) {
            if (_errorMessage != null) setState(() => _errorMessage = null);
          },
        ),
        const SizedBox(height: 24),

        // Sign In Button
        AcedexButton(
          label: 'Sign In',
          variant: AcedexButtonVariant.primary,
          size: AcedexButtonSize.lg,
          isFullWidth: true,
          isLoading: _isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 16),

        // Switch to Register
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: TextStyle(
                fontSize: 13.5,
                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              ),
            ),
            const SizedBox(width: 4),
            AcedexBounceable(
              onTap: widget.onSwitchToRegister,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
