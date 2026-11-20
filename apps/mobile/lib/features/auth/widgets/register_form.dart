import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';
import '../services/auth_service.dart';
import 'phone_number_input.dart';
import 'pin_input_field.dart';
import 'stream_selector.dart';

class RegisterForm extends StatefulWidget {
  final ValueChanged<UserProfile> onSuccess;
  final VoidCallback onSwitchToLogin;
  final AuthService? authService;

  const RegisterForm({
    super.key,
    required this.onSuccess,
    required this.onSwitchToLogin,
    this.authService,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();

  late final AuthService _authService;
  bool _isLoading = false;
  String? _errorMessage;

  String _gender = 'male';
  int _grade = 12;
  String? _stream = 'natural';

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _onGradeSelected(int g) {
    setState(() {
      _grade = g;
      if (_grade >= 11) {
        _stream ??= 'natural';
      } else {
        _stream = null;
      }
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    if (name.isEmpty || name.length < 2) {
      setState(() => _errorMessage = 'Please enter your full name.');
      return;
    }
    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Please enter your phone number.');
      return;
    }
    if (pin.isEmpty || pin.length < 6) {
      setState(() => _errorMessage = 'PIN must be at least 6 digits.');
      return;
    }
    if ((_grade == 11 || _grade == 12) && _stream == null) {
      setState(() =>
          _errorMessage = 'Please choose your study stream (Natural or Social).');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.register(
        fullName: name,
        phone: phone,
        pin: pin,
        gender: _gender,
        grade: _grade,
        stream: _stream,
      );
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

    final primaryColor = theme.colorScheme.primary;
    final accentSoft =
        isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;

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

        // Full Name
        AcedexTextField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'Abebe Kebede',
          keyboardType: TextInputType.name,
          enabled: !_isLoading,
          prefixIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedUser,
            size: 20,
            color: primaryColor,
          ),
          onChanged: (_) {
            if (_errorMessage != null) setState(() => _errorMessage = null);
          },
        ),
        const SizedBox(height: 14),

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
          label: 'Create 6-Digit PIN',
          hintText: 'Choose 6 or more digits',
          enabled: !_isLoading,
          onChanged: (_) {
            if (_errorMessage != null) setState(() => _errorMessage = null);
          },
        ),
        const SizedBox(height: 18),

        // Gender Selector
        Text(
          'GENDER',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ChoiceChip(
                label: 'Male',
                icon: HugeIcons.strokeRoundedMale02,
                isSelected: _gender == 'male',
                onTap: () => setState(() => _gender = 'male'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ChoiceChip(
                label: 'Female',
                icon: HugeIcons.strokeRoundedFemale02,
                isSelected: _gender == 'female',
                onTap: () => setState(() => _gender = 'female'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Grade Selector
        Text(
          'GRADE LEVEL',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [9, 10, 11, 12].map((g) {
            final isSelected = _grade == g;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: AcedexBounceable(
                  onTap: () => _onGradeSelected(g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentSoft
                          : (isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                        width: isSelected ? 1.6 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'G $g',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? primaryColor
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Stream Selector (Animated for Grades 11 & 12)
        StreamSelector(
          visible: _grade >= 11,
          selectedStream: _stream,
          onSelected: (stream) => setState(() => _stream = stream),
        ),
        const SizedBox(height: 26),

        // Submit Button
        AcedexButton(
          label: 'Create Student Account',
          variant: AcedexButtonVariant.primary,
          size: AcedexButtonSize.lg,
          isFullWidth: true,
          isLoading: _isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 16),

        // Switch to Login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already registered?',
              style: TextStyle(
                fontSize: 13.5,
                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              ),
            ),
            const SizedBox(width: 4),
            AcedexBounceable(
              onTap: widget.onSwitchToLogin,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
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

class _ChoiceChip extends StatelessWidget {
  final String label;
  final List<List<dynamic>> icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;
    final accentSoft =
        isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;

    return AcedexBounceable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? accentSoft
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: icon,
              size: 16,
              color: isSelected
                  ? primaryColor
                  : (isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? primaryColor
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
