import 'package:flutter/material.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';
import '../services/auth_service.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';

class AuthScreen extends StatefulWidget {
  final int initialTab;
  final AuthService? authService;

  const AuthScreen({
    super.key,
    this.initialTab = 0,
    this.authService,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late int _selectedTab; // 0: Sign In, 1: Create Account

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  void _onAuthSuccess(UserProfile user) {
    Navigator.of(context).pushReplacementNamed('/home', arguments: user);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Branding Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(
                              alpha: isDark ? 0.35 : 0.2,
                            ),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedTab == 0
                          ? 'Welcome Back'
                          : 'Create Student Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedTab == 0
                          ? 'Sign in with your phone number and PIN'
                          : 'Join thousands of Ethiopian students preparing for success',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkSubtext
                            : AppColors.lightSubtext,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Apple-Style Segmented Control
              Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentTab(
                        title: 'Sign In',
                        isSelected: _selectedTab == 0,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                    ),
                    Expanded(
                      child: _SegmentTab(
                        title: 'Create Account',
                        isSelected: _selectedTab == 1,
                        onTap: () => setState(() => _selectedTab = 1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Card Container for Form
              AcedexCard(
                variant: AcedexCardVariant.raised,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _selectedTab == 0
                      ? LoginForm(
                          key: const ValueKey('login_form'),
                          authService: widget.authService,
                          onSuccess: _onAuthSuccess,
                          onSwitchToRegister: () =>
                              setState(() => _selectedTab = 1),
                        )
                      : RegisterForm(
                          key: const ValueKey('register_form'),
                          authService: widget.authService,
                          onSuccess: _onAuthSuccess,
                          onSwitchToLogin: () =>
                              setState(() => _selectedTab = 0),
                        ),
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

class _SegmentTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final raisedColor = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    return AcedexBounceable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? raisedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.onSurface
                  : (isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
            ),
          ),
        ),
      ),
    );
  }
}
