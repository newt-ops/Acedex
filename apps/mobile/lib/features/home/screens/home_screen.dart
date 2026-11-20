import 'package:flutter/material.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';

class HomeScreen extends StatelessWidget {
  final UserProfile? user;

  const HomeScreen({super.key, this.user});

  Future<void> _signOut(BuildContext context) async {
    await AuthStorage.instance.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;
    final displayName = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : 'Student';
    final gradeLabel = user?.gradeLabel ?? 'High School';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ACEDEX',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AcedexBadge(
              label: gradeLabel,
              variant: AcedexBadgeVariant.primary,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: Icon(
              Icons.logout_rounded,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              size: 20,
            ),
            onPressed: () => _signOut(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Header
              Text(
                'Hello, $displayName 👋',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ready to master your curriculum questions today?',
                style: TextStyle(
                  fontSize: 15,
                  color:
                      isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                ),
              ),
              const SizedBox(height: 24),

              // Streak & Daily Goals Card
              AcedexCard(
                variant: AcedexCardVariant.raised,
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: (isDark
                                ? AppColors.darkWarning
                                : AppColors.warning)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: isDark
                              ? AppColors.darkWarning
                              : AppColors.warning,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1 Day Streak',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Complete 10 practice questions to extend your streak',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkSubtext
                                  : AppColors.lightSubtext,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Exam Preparation Banner
              AcedexCard(
                variant: AcedexCardVariant.raised,
                onTap: () {
                  AcedexToast.show(
                    context,
                    message: 'Practice engine starting up...',
                    type: AcedexToastType.success,
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 20,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'National Exam Practice',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Timed questions, step-by-step explanations, and real Ethiopian national entrance exam coverage.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isDark
                            ? AppColors.darkSubtext
                            : AppColors.lightSubtext,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AcedexButton(
                      label: 'Start Practice Session',
                      variant: AcedexButtonVariant.primary,
                      size: AcedexButtonSize.md,
                      isFullWidth: true,
                      onPressed: () {
                        AcedexToast.show(
                          context,
                          message: 'Practice engine starting up...',
                          type: AcedexToastType.success,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Account summary
              AcedexCard(
                variant: AcedexCardVariant.flat,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STUDENT PROFILE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark
                            ? AppColors.darkSubtext
                            : AppColors.lightSubtext,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProfileRow(label: 'Name', value: displayName),
                    if (user?.phone != null)
                      _ProfileRow(label: 'Phone', value: user!.phone!),
                    _ProfileRow(label: 'Curriculum', value: gradeLabel),
                    if (user?.acedexId != null && user!.acedexId.isNotEmpty)
                      _ProfileRow(label: 'Acedex ID', value: user!.acedexId),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
