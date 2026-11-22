import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/models/student_avatar.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';
import '../../onboarding/models/student_registration_draft.dart';
import '../../onboarding/widgets/student_id_card.dart';

/// Clean Apple-Style Candidate Profile Screen (Tab 4: Profile)
class ProfileScreen extends StatelessWidget {
  final UserProfile? user;
  final VoidCallback onSignOut;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    final displayName = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : 'Student';
    final gradeLabel = user?.gradeLabel ?? 'Grade 12 • Natural Science';

    final draft = StudentRegistrationDraft(
      fullName: displayName,
      phoneNumber: user?.phone ?? '',
      gender: user?.gender ?? 'male',
      grade: user?.grade ?? 12,
      stream: user?.stream ?? 'natural',
      customCandidateId: user?.acedexId,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Headline
          Text(
            'Candidate Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your verified digital student credential and account details.',
            style: TextStyle(
              fontSize: 13.5,
              color: subtextColor,
            ),
          ),

          const SizedBox(height: 20),

          // 3D Flippable Student ID Pass with Vector QR Code
          StudentIdCard(draft: draft),

          const SizedBox(height: 20),

          // Profile Photo & Avatar Quick-Edit Card
          AcedexCard(
            variant: AcedexCardVariant.flat,
            onTap: () {
              ProfilePhotoModal.show(context, user: user);
            },
            child: Row(
              children: [
                ValueListenableBuilder<StudentAvatar>(
                  valueListenable: AuthStorage.instance.avatarNotifier,
                  builder: (context, avatar, _) {
                    return StudentAvatarWidget(
                      avatar: avatar,
                      size: 46,
                      initials: displayName,
                    );
                  },
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change Profile Photo',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      ValueListenableBuilder<StudentAvatar>(
                        valueListenable: AuthStorage.instance.avatarNotifier,
                        builder: (context, avatar, _) {
                          return Text(
                            avatar.label,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: subtextColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCamera01,
                  color: isDark ? const Color(0xFFB866CF) : AppColors.royalPurple,
                  size: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Account Details Card
          AcedexCard(
            variant: AcedexCardVariant.flat,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACCOUNT DETAILS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: subtextColor,
                  ),
                ),
                const SizedBox(height: 12),
                _ProfileInfoRow(label: 'Full Name', value: displayName),
                if (user?.phone != null && user!.phone!.isNotEmpty)
                  _ProfileInfoRow(label: 'Phone Number', value: user!.phone!),
                _ProfileInfoRow(label: 'Curriculum Track', value: gradeLabel),
                if (user?.acedexId != null && user!.acedexId.isNotEmpty)
                  _ProfileInfoRow(label: 'Candidate ID', value: user!.acedexId),
                _ProfileInfoRow(
                  label: 'Status',
                  value: 'Active / Verified',
                  valueColor: const Color(0xFF16A34A),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Theme Selector Card
          AcedexCard(
            variant: AcedexCardVariant.flat,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Theme Appearance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const AcedexThemeToggle(),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sign Out Button
          AcedexButton(
            label: 'Sign Out',
            variant: AcedexButtonVariant.outline,
            size: AcedexButtonSize.md,
            leadingIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedLogout01,
              color: isDark ? AppColors.darkText : AppColors.lightText,
              size: 18,
            ),
            isFullWidth: true,
            onPressed: onSignOut,
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ProfileInfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

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
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
