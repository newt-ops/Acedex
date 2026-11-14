import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/acedex_button.dart';
import '../../../core/widgets/acedex_toast.dart';
import '../../profile/student_provider.dart';
import '../models/onboarding_data.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    super.key,
    this.onCompleted,
    this.onBack,
    this.initialPage = 0,
  });

  final VoidCallback? onCompleted;
  final VoidCallback? onBack;
  final int initialPage;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  final TextEditingController _nameController = TextEditingController();

  late int _currentPage;
  final int _totalPages = 5;

  OnboardingData _data = const OnboardingData(
    grade: 12,
    stream: 'natural',
    gender: 'male',
    dailyGoalMinutes: 120,
  );
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);

    // Pre-fill student name and email from Google auth if available
    final googleUser = SupabaseService.currentUser;
    final meta = googleUser?.userMetadata;
    final googleName = (meta?['full_name'] ?? meta?['name'] ?? '').toString();

    final initialName = googleName.isNotEmpty
        ? googleName
        : (_data.name.isNotEmpty ? _data.name : 'Student Name');

    _nameController.text = initialName;
    _data = _data.copyWith(
      name: initialName,
      stream: (_data.grade == 9 || _data.grade == 10) ? 'common' : _data.stream,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage == 0 && _nameController.text.trim().isEmpty) {
      AcedexToast.show(
        context,
        title: 'Please enter your name',
        status: AcedexToastStatus.warning,
      );
      return;
    }

    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    HapticFeedback.lightImpact();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onBack?.call();
    }
  }

  Future<void> _finishOnboarding() async {
    setState(() => _isSaving = true);
    final updatedData = _data.copyWith(
      name: _nameController.text.trim().isEmpty
          ? 'Acedex Scholar'
          : _nameController.text.trim(),
      stream: (_data.grade == 9 || _data.grade == 10) ? 'common' : _data.stream,
    );

    final success = await ref
        .read(studentStateProvider.notifier)
        .saveStudentProfile(onboardingData: updatedData);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      widget.onCompleted?.call();
    } else {
      AcedexToast.show(
        context,
        title: 'Error Saving Profile',
        message: 'Could not complete profile setup. Please try again.',
        status: AcedexToastStatus.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with 5-segment Pill Progress Indicator
            _buildTopBar(colors),

            // PageView with 5 interactive onboarding steps
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                },
                children: [
                  _buildStep1Identity(colors),
                  _buildStep2Grade(colors),
                  _buildStep3Stream(colors),
                  _buildStep4Goal(colors),
                  _buildStep5Pass(colors),
                ],
              ),
            ),

            // Bottom CTA Area
            _buildBottomCta(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space8,
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: _previousPage,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.space8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    color: colors.textPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: AppTheme.space4),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),

          // 5-segment pill indicator
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_totalPages, (i) {
                  final isActive = i <= _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: 28,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive
                          ? colors.primary
                          : colors.cardBorder.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppTheme.space4),
              Text(
                'Step ${_currentPage + 1} of $_totalPages',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 50),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 1: IDENTITY & PROFILE CONFIRMATION
  // ==========================================
  Widget _buildStep1Identity(AppColors colors) {
    final displayName = _nameController.text.trim();
    final initialLetter = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'S';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space24,
        vertical: AppTheme.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.space8),
          Text(
            'Confirm your profile',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppTheme.space6),
          Text(
            'Personalized from your Google account.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.space28),

          // Centered Circular Avatar Preview with Verified Badge
          Center(
            child: Stack(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initialLetter,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space28),

          // Full Name Input Card
          Text(
            'Full name',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.space6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space16,
              vertical: AppTheme.space4,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.cardBorder),
            ),
            child: TextField(
              controller: _nameController,
              onChanged: (val) => setState(() {}),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space20),

          // Gender Section
          Text(
            'Gender',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Row(
            children: [
              Expanded(
                child: _buildGenderCard(
                  colors: colors,
                  label: 'Male',
                  genderValue: 'male',
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: _buildGenderCard(
                  colors: colors,
                  label: 'Female',
                  genderValue: 'female',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space24),

          // Helper note
          Center(
            child: Text(
              'Used only to personalize your learning plan.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard({
    required AppColors colors,
    required String label,
    required String genderValue,
  }) {
    final isSelected = _data.gender == genderValue;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _data = _data.copyWith(gender: genderValue));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space16,
          vertical: AppTheme.space16,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.primary : colors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              color: isSelected ? colors.primary : colors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: AppTheme.space10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colors.primary : colors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? colors.primary : colors.cardBorder,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 2: GRADE SELECTION
  // ==========================================
  Widget _buildStep2Grade(AppColors colors) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space24,
        vertical: AppTheme.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.space8),
          Text(
            'Which grade are you in?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppTheme.space6),
          Text(
            "We'll tailor your subjects and assessments accordingly.",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.space28),

          // 2x2 Grid of Grade Cards
          Row(
            children: [
              Expanded(
                child: _buildGradeCard(
                  colors: colors,
                  grade: 9,
                  subtitle: 'Build strong foundations',
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: _buildGradeCard(
                  colors: colors,
                  grade: 10,
                  subtitle: 'Expand core skills',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space12),
          Row(
            children: [
              Expanded(
                child: _buildGradeCard(
                  colors: colors,
                  grade: 11,
                  subtitle: 'Choose your stream',
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: _buildGradeCard(
                  colors: colors,
                  grade: 12,
                  subtitle: 'Preparing for the EUEE',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space28),

          Center(
            child: Text(
              'You can update your grade later.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard({
    required AppColors colors,
    required int grade,
    required String subtitle,
  }) {
    final isSelected = _data.grade == grade;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _data = _data.copyWith(
            grade: grade,
            stream: (grade == 9 || grade == 10) ? 'common' : _data.stream,
          );
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 125,
        padding: const EdgeInsets.all(AppTheme.space16),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? colors.primary : colors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grade $grade',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? colors.primary : colors.textPrimary,
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? colors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.cardBorder,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 12)
                      : null,
                ),
              ],
            ),
            const Spacer(),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 3: ACADEMIC STREAM
  // ==========================================
  Widget _buildStep3Stream(AppColors colors) {
    final isSenior = _data.grade >= 11;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space24,
        vertical: AppTheme.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.space8),
          Text(
            'Select your academic stream',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppTheme.space6),
          Text(
            isSenior
                ? 'For Grade ${_data.grade}, choose the path that fits your studies.'
                : 'Grades 9–10 share a common foundation curriculum.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.space24),

          if (isSenior) ...[
            _buildSeniorStreamCard(
              colors: colors,
              streamKey: 'natural',
              title: 'Natural Science Stream',
              subtitle: 'Explore the natural world and its systems.',
              icon: HugeIcons.strokeRoundedAtom02,
              subjects: ['Physics', 'Chemistry', 'Biology', 'Mathematics'],
            ),
            const SizedBox(height: AppTheme.space12),
            _buildSeniorStreamCard(
              colors: colors,
              streamKey: 'social',
              title: 'Social Science Stream',
              subtitle: 'Understand people, places, and economies.',
              icon: HugeIcons.strokeRoundedGlobe02,
              subjects: ['Economics', 'History', 'Geography', 'Mathematics'],
            ),
            const SizedBox(height: AppTheme.space24),
            Center(
              child: Text(
                'You can change your stream later.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ] else ...[
            // Grade 9-10 Common Foundation Card
            Container(
              padding: const EdgeInsets.all(AppTheme.space20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.primary, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.space10),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedLockPassword,
                          color: colors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppTheme.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'General Foundation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppTheme.space2),
                            Text(
                              'Common Stream • Grades 9–10',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space16),
                  Text(
                    'A shared curriculum builds strong core skills before students choose a specialty in Grade 11.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Assigned by grade',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.space24),
            Center(
              child: Text(
                'Your stream opens when you enter Grade 11.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeniorStreamCard({
    required AppColors colors,
    required String streamKey,
    required String title,
    required String subtitle,
    required List<List<dynamic>> icon,
    required List<String> subjects,
  }) {
    final isSelected = _data.stream == streamKey;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _data = _data.copyWith(stream: streamKey));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppTheme.space16),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.primary : colors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.space8),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: HugeIcon(
                    icon: icon,
                    color: colors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? colors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.cardBorder,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 13)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: subjects.map((subj) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.cardBorder.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Text(
                    subj,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 4: DAILY STUDY TARGET
  // ==========================================
  Widget _buildStep4Goal(AppColors colors) {
    final minutes = _data.dailyGoalMinutes;
    final hours = (minutes / 60.0);
    final hoursDisplay = hours == hours.roundToDouble()
        ? hours.toInt().toString()
        : hours.toStringAsFixed(1);

    final goalOptions = [
      {'label': '1h', 'min': 60},
      {'label': '1.5h', 'min': 90},
      {'label': '2h', 'min': 120, 'recommended': true},
      {'label': '3h', 'min': 180},
      {'label': '4h+', 'min': 240},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space24,
        vertical: AppTheme.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.space8),
          Text(
            'Set your daily goal',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppTheme.space6),
          Text(
            'Consistency is the key to conquering the EUEE.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.space32),

          // Big Purple Readout
          Center(
            child: Column(
              children: [
                Text(
                  '$hoursDisplay Hours / Day',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: AppTheme.space4),
                Text(
                  'PERSONAL STUDY TARGET',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space28),

          // Interactive Horizontal Target Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: goalOptions.map((opt) {
              final minVal = opt['min'] as int;
              final label = opt['label'] as String;
              final isRec = opt['recommended'] == true;
              final isSelected = minutes == minVal;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _data = _data.copyWith(dailyGoalMinutes: minVal);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primary : colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.cardBorder,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space4),
                  if (isRec)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Recommended',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 14),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.space28),

          // Motivational Card
          Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.space10),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedIdea01,
                    color: colors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A goal you can keep',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.space2),
                      Text(
                        'Students who maintain a 2-hour daily habit retain 40% more curriculum material.',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.35,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space24),

          Center(
            child: Text(
              'Choose a target that works for your schedule.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 5: THE ACADEMIC PASS (READY TO ACE)
  // ==========================================
  Widget _buildStep5Pass(AppColors colors) {
    final studentName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Student';
    final email = SupabaseService.currentUser?.email ?? 'student@gmail.com';
    final streamLabel = _data.stream == 'natural'
        ? 'Natural Science'
        : _data.stream == 'social'
            ? 'Social Science'
            : 'Common Foundation';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space24,
        vertical: AppTheme.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.space8),
          Text(
            'All set, $studentName!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppTheme.space6),
          Text(
            'Your Acedex study plan is ready to go.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.space24),

          // The High-Finish Boarding Pass Card
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.cardBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Ticket Header
                Container(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'YOUR ACADEMIC PASS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: colors.primary,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF34C759),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppTheme.space4),
                                const Text(
                                  'Connected',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1D1D1F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space10),
                      Text(
                        studentName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Metrics Row
                Padding(
                  padding: const EdgeInsets.all(AppTheme.space20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GRADE & STREAM',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: colors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: AppTheme.space4),
                            Text(
                              'Grade ${_data.grade}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                              ),
                            ),
                            Text(
                              streamLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 48,
                        width: 1,
                        color: colors.cardBorder,
                      ),
                      const SizedBox(width: AppTheme.space16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DAILY TARGET',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: colors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: AppTheme.space4),
                            Text(
                              '${_data.dailyGoalMinutes} min',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                              ),
                            ),
                            Text(
                              'per day',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // EUEE Countdown info
                Padding(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.space8),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedCalendar03,
                          color: colors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppTheme.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EUEE COUNTDOWN',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: colors.textSecondary,
                              ),
                            ),
                            Text(
                              'Ready to track • We\'ll keep your exam goal in sight.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space24),

          Center(
            child: Text(
              'You can update your profile and goals anytime.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BOTTOM CTA
  // ==========================================
  Widget _buildBottomCta(AppColors colors) {
    final isLast = _currentPage == _totalPages - 1;
    final label = isLast ? 'Start Learning' : 'Continue';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space24,
        vertical: AppTheme.space16,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(
            color: colors.cardBorder.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: AcedexButton(
        label: label,
        variant: AcedexButtonVariant.primary,
        isLoading: _isSaving,
        trailing: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
        onPressed: _isSaving ? null : _nextPage,
      ),
    );
  }
}
