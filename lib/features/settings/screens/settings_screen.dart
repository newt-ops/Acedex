import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/acedex_badge.dart';
import '../../../core/widgets/acedex_header_bar.dart';
import '../../../core/widgets/acedex_toast.dart';
import '../../profile/student_provider.dart';
import '../../security/pin_provider.dart';
import '../../security/screens/pin_setup_screen.dart';
import '../../developer/screens/developer_showcase_screen.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../auth/screens/login_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final currentThemeMode = ref.watch(themeModeProvider);
    final studentAsync = ref.watch(studentStateProvider);
    final student = studentAsync.value;
    final pinState = ref.watch(pinProvider);

    return Scaffold(
      appBar: const AcedexFloatingHeaderBar(
        title: 'Settings & Security',
        subtitle: 'Preferences & Account',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.space16,
          AppTheme.space8,
          AppTheme.space16,
          110.0,
        ),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Student Profile Section
          Text(
            'Student Account',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: colors.border, width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.primarySoft,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedUser,
                          color: colors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student?.name ?? 'Guest Student',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            student != null
                                ? 'Grade ${student.grade} • ${student.stream.toUpperCase()}'
                                : 'No profile configured',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AcedexBadge(
                      label: student != null ? 'Onboarded' : 'Guest',
                      color: student != null ? colors.success : colors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.primary,
                          side: BorderSide(color: colors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                          ),
                          minimumSize: const Size.fromHeight(40),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OnboardingScreen(
                                onCompleted: () => Navigator.of(context).pop(),
                              ),
                            ),
                          );
                        },
                        child: const Text('Update Profile', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.primary,
                          side: BorderSide(color: colors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                          ),
                          minimumSize: const Size.fromHeight(40),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LoginScreen(
                                onLoginSuccess: () => Navigator.of(context).pop(),
                                onSkip: () => Navigator.of(context).pop(),
                              ),
                            ),
                          );
                        },
                        child: const Text('Account Sign In', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space20),

          // 2. App Security Section
          Text(
            'Security & Biometrics',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: colors.border, width: 1.0),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedLockPassword,
                        color: colors.primary,
                        size: 18,
                      ),
                    ),
                  ),
                  title: Text(
                    'App PIN Lock',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    pinState.isPinEnabled ? 'PIN and biometrics active' : 'Disabled',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                  trailing: Switch(
                    value: pinState.isPinEnabled,
                    onChanged: (val) async {
                      if (val) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PinSetupScreen(),
                          ),
                        );
                      } else {
                        await ref.read(pinProvider.notifier).disablePin();
                        if (context.mounted) {
                          AcedexToast.show(
                            context,
                            title: 'PIN Removed',
                            message: 'App lock has been disabled.',
                            status: AcedexToastStatus.info,
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space20),

          // 3. Theme Appearance
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Container(
            padding: const EdgeInsets.all(AppTheme.space12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: colors.border, width: 1.0),
            ),
            child: Row(
              children: [
                _ThemeModeOption(
                  title: 'System',
                  icon: HugeIcons.strokeRoundedComputer,
                  isSelected: currentThemeMode == ThemeMode.system,
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                ),
                const SizedBox(width: AppTheme.space8),
                _ThemeModeOption(
                  title: 'Light',
                  icon: HugeIcons.strokeRoundedSun01,
                  isSelected: currentThemeMode == ThemeMode.light,
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                ),
                const SizedBox(width: AppTheme.space8),
                _ThemeModeOption(
                  title: 'Dark',
                  icon: HugeIcons.strokeRoundedMoon02,
                  isSelected: currentThemeMode == ThemeMode.dark,
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space20),

          // 4. Developer Tools & Lab (Moved here!)
          Text(
            'Developer & Diagnostics',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: colors.border, width: 1.0),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DeveloperShowcaseScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.primarySoft,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCommandLine,
                            color: colors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Developer Test Lab',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Test toasts, dialogs, buttons, DB seeder, and PIN flows',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        color: colors.textSecondary.withValues(alpha: 0.5),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space20),

          // 5. App Info & Developer Appreciation
          Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(
                color: colors.border.withValues(alpha: 0.6),
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedGraduationScroll,
                          color: colors.primary,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Acedex v1.2.0',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            'Built with precision for Ethiopian scholars',
                            style: TextStyle(fontSize: 12, color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space12),
                Text(
                  'Created by Aymen (Newton) • Designed under Apple HIG offline-first principles with Drift SQLite & Supabase.',
                  style: TextStyle(fontSize: 11, color: colors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final List<List<dynamic>> icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: AppTheme.space12),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: icon,
                color: isSelected ? colors.onPrimary : colors.textSecondary,
                size: 18,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? colors.onPrimary : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

