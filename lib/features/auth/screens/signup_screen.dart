import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/acedex_button.dart';
import '../../../core/widgets/acedex_input.dart';
import '../../../core/widgets/acedex_toast.dart';
import '../auth_controller.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({
    super.key,
    this.onSignUpSuccess,
  });

  final VoidCallback? onSignUpSuccess;

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      AcedexToast.show(
        context,
        title: 'Please fill in all fields',
        status: AcedexToastStatus.warning,
      );
      return;
    }

    if (password != confirmPassword) {
      AcedexToast.show(
        context,
        title: 'Passwords do not match',
        status: AcedexToastStatus.danger,
      );
      return;
    }

    if (password.length < 6) {
      AcedexToast.show(
        context,
        title: 'Password too short',
        message: 'Must be at least 6 characters.',
        status: AcedexToastStatus.warning,
      );
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .signUpWithEmail(email, password, name: name);

    if (mounted) {
      if (success) {
        AcedexToast.success(
          context,
          title: 'Account Created!',
          message: 'Let us customize your curriculum.',
        );
        Navigator.of(context).pop();
        widget.onSignUpSuccess?.call();
      } else {
        final err = ref.read(authControllerProvider).errorMessage;
        AcedexToast.danger(
          context,
          title: 'Sign Up Failed',
          message: err ?? 'Could not create account.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: colors.textPrimary,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join Acedex',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppTheme.space8),
                Text(
                  'Create an account to track your Ethiopian curriculum mastery and study streak.',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.space24),

                AcedexInput(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'e.g. Aymen Newton',
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedUser,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(height: AppTheme.space16),

                AcedexInput(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'student@example.com',
                  keyboardType: TextInputType.emailAddress,
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedMail01,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(height: AppTheme.space16),

                AcedexInput(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'At least 6 characters',
                  obscureText: _obscurePassword,
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedLockPassword,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                  trailing: IconButton(
                    icon: HugeIcon(
                      icon: _obscurePassword
                          ? HugeIcons.strokeRoundedViewOffSlash
                          : HugeIcons.strokeRoundedView,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.space16),

                AcedexInput(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  obscureText: _obscurePassword,
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedLockPassword,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(height: AppTheme.space24),

                AcedexButton(
                  label: 'Create Account',
                  variant: AcedexButtonVariant.primary,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleSignUp,
                ),
                const SizedBox(height: AppTheme.space20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
