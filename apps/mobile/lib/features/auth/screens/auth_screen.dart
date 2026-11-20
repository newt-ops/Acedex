import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/cards/acedex_card.dart';
import '../../../main.dart';
import '../services/auth_service.dart';
import '../widgets/login_form.dart';

/// Apple-Style Login Screen & Authentication Gateway
///
/// Serves as the primary entrypoint for returning candidates to sign in,
/// and provides a direct path to the guided 7-step Onboarding registration.
class AuthScreen extends StatefulWidget {
  final String? initialPhone;
  final AuthService? authService;

  const AuthScreen({
    super.key,
    this.initialPhone,
    this.authService,
    int initialTab = 0, // preserved for backwards compatibility with tests
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  void _onAuthSuccess(UserProfile user) {
    Navigator.of(context).pushReplacementNamed('/home', arguments: user);
  }

  void _goToOnboarding() {
    Navigator.of(context).pushNamed('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;

    // Check for prefilled phone from route arguments (e.g. post-registration)
    final routeArgs = ModalRoute.of(context)?.settings.arguments
        as Map<String, dynamic>?;
    final prefilledPhone =
        widget.initialPhone ?? routeArgs?['prefilledPhone'] as String?;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Acedex',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: accent,
          ),
        ),
        actions: [
          // Theme Toggle Button
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: AcedexBounceable(
              onTap: () => AcedexApp.toggleTheme(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: line, width: 1),
                ),
                child: HugeIcon(
                  icon: isDark
                      ? HugeIcons.strokeRoundedSun02
                      : HugeIcons.strokeRoundedMoon02,
                  color: accent,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Product Branding Crest Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(
                              alpha: isDark ? 0.38 : 0.22,
                            ),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in with your phone number and PIN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppColors.darkSubtext
                            : AppColors.lightSubtext,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Login Form Card
              AcedexCard(
                variant: AcedexCardVariant.raised,
                child: LoginForm(
                  key: const ValueKey('login_form'),
                  initialPhone: prefilledPhone,
                  authService: widget.authService,
                  onSuccess: _onAuthSuccess,
                  onSwitchToRegister: _goToOnboarding,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
