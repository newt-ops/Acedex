import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/acedex_button.dart';
import '../../../core/widgets/acedex_input.dart';
import '../../../core/widgets/acedex_toast.dart';
import '../auth_controller.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    this.onSkip,
  });

  final VoidCallback? onLoginSuccess;
  final VoidCallback? onSkip;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      AcedexToast.show(
        context,
        title: 'Please fill in all fields',
        status: AcedexToastStatus.warning,
      );
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .signInWithEmail(email, password);

    if (mounted) {
      if (success) {
        AcedexToast.success(
          context,
          title: 'Welcome Back!',
          message: 'Signed in successfully.',
        );
        widget.onLoginSuccess?.call();
      } else {
        final err = ref.read(authControllerProvider).errorMessage;
        AcedexToast.danger(
          context,
          title: 'Sign In Failed',
          message: err ?? 'Invalid credentials.',
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final success =
        await ref.read(authControllerProvider.notifier).signInWithGoogle();
    if (mounted && success) {
      widget.onLoginSuccess?.call();
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      AcedexToast.show(
        context,
        title: 'Enter your email first',
        message: 'We will send you a password reset link.',
        status: AcedexToastStatus.info,
      );
      return;
    }

    final sent =
        await ref.read(authControllerProvider.notifier).resetPassword(email);
    if (mounted) {
      if (sent) {
        AcedexToast.success(
          context,
          title: 'Reset Link Sent',
          message: 'Check your email inbox.',
        );
      } else {
        AcedexToast.danger(
          context,
          title: 'Error',
          message: 'Failed to send reset link.',
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppTheme.space24),
                // App Logo
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedGraduationScroll,
                        color: colors.primary,
                        size: 38,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.space20),
                Text(
                  'Acedex',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.space8),
                Text(
                  'Sign in to sync your Ethiopian curriculum progress and streak consistency across devices.',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.space32),

                // Form Inputs
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
                  hintText: 'Enter your password',
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
                const SizedBox(height: AppTheme.space8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.space16),

                // Sign In Button
                AcedexButton(
                  label: 'Sign In',
                  variant: AcedexButtonVariant.primary,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleSignIn,
                ),
                const SizedBox(height: AppTheme.space12),

                // Google Sign In
                AcedexButton(
                  label: 'Continue with Google',
                  variant: AcedexButtonVariant.secondary,
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedGoogle,
                    color: colors.textPrimary,
                    size: 20,
                  ),
                  onPressed: isLoading ? null : _handleGoogleSignIn,
                ),
                const SizedBox(height: AppTheme.space24),

                // Navigation to Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SignUpScreen(
                              onSignUpSuccess: widget.onLoginSuccess,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space16),

                // Skip / Continue Offline
                if (widget.onSkip != null)
                  TextButton(
                    onPressed: widget.onSkip,
                    child: Text(
                      'Continue Offline (Guest Mode)',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
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
