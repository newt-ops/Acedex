import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/acedex_button.dart';
import '../../../core/widgets/acedex_input.dart';
import '../../../core/widgets/acedex_toast.dart';
import '../../profile/student_provider.dart';
import '../models/onboarding_data.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    super.key,
    this.onCompleted,
    this.initialPage = 0,
  });

  final VoidCallback? onCompleted;
  final int initialPage;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  final TextEditingController _nameController = TextEditingController();

  late int _currentPage;
  final int _totalPages = 5;

  OnboardingData _data = const OnboardingData();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.selectionClick();
    if (_currentPage == 1 && _nameController.text.trim().isEmpty) {
      AcedexToast.show(
        context,
        title: 'Please enter your name',
        status: AcedexToastStatus.warning,
      );
      return;
    }

    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    HapticFeedback.selectionClick();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    setState(() => _isSaving = true);
    final updatedData = _data.copyWith(
      name: _nameController.text.trim().isEmpty
          ? 'Acedex Scholar'
          : _nameController.text.trim(),
    );

    final success = await ref
        .read(studentStateProvider.notifier)
        .saveStudentProfile(onboardingData: updatedData);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        AcedexToast.success(
          context,
          title: 'Welcome to Acedex!',
          message: 'Your study journey is ready.',
        );
        widget.onCompleted?.call();
      } else {
        AcedexToast.danger(
          context,
          title: 'Failed to save profile',
          message: 'Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with back button and animated indicator dots
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space20,
                vertical: AppTheme.space12,
              ),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        color: colors.textPrimary,
                        size: 22,
                      ),
                      onPressed: _previousPage,
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  // Step Indicator Dots
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_totalPages, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? colors.primary
                              : colors.border.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  if (_currentPage < _totalPages - 1)
                    TextButton(
                      onPressed: () {
                        // Jump directly to goals
                        _pageController.animateToPage(
                          _totalPages - 1,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // Page View with 5 steps
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomeStep(colors),
                  _buildNameAndGenderStep(colors),
                  _buildGradeStep(colors),
                  _buildStreamStep(colors),
                  _buildGoalStep(colors),
                ],
              ),
            ),

            // Bottom Continue Action Button
            Padding(
              padding: const EdgeInsets.all(AppTheme.space20),
              child: AcedexButton(
                label: _currentPage == _totalPages - 1
                    ? 'Launch Acedex'
                    : 'Continue',
                isLoading: _isSaving,
                trailing: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  color: colors.onPrimary,
                  size: 20,
                ),
                onPressed: _isSaving ? null : _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: Welcome & Value Proposition
  Widget _buildWelcomeStep(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: colors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedGraduationScroll,
                color: colors.primary,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space24),
          Text(
            'Master Ethiopian Curriculum',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.space12),
          Text(
            'Grade 9 to 12 Natural & Social streams with 3-stage mastery tracking and offline study tools.',
            style: TextStyle(
              fontSize: 15,
              color: colors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.space32),
          _buildFeaturePill(
            colors,
            icon: HugeIcons.strokeRoundedBookOpen01,
            title: '100% Offline First',
            subtitle: 'Study anytime without requiring mobile data.',
          ),
          const SizedBox(height: AppTheme.space12),
          _buildFeaturePill(
            colors,
            icon: HugeIcons.strokeRoundedFire,
            title: 'Consistency Streaks',
            subtitle: 'Build daily habits with rewarded streak freezes.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(
    AppColors colors, {
    required List<List<dynamic>> icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: HugeIcon(icon: icon, color: colors.primary, size: 20),
            ),
          ),
          const SizedBox(width: AppTheme.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.5, color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: Name & Gender
  Widget _buildNameAndGenderStep(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.space20),
          Text(
            'What should we call you?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Text(
            'We customize your study journey and streak milestones.',
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
          ),
          const SizedBox(height: AppTheme.space32),
          AcedexInput(
            controller: _nameController,
            label: 'Your Full Name',
            hintText: 'Newton',
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              color: colors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(height: AppTheme.space24),
          Text(
            'Gender',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.space12),
          Row(
            children: [
              Expanded(
                child: _buildSelectablePill(
                  colors,
                  label: 'Male',
                  isSelected: _data.gender == 'male',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _data = _data.copyWith(gender: 'male'));
                  },
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: _buildSelectablePill(
                  colors,
                  label: 'Female',
                  isSelected: _data.gender == 'female',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _data = _data.copyWith(gender: 'female'));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 3: Grade Selection
  Widget _buildGradeStep(AppColors colors) {
    final grades = [
      {'grade': 9, 'desc': 'Foundations: Common curriculum across all schools'},
      {
        'grade': 10,
        'desc': 'National prep: Common curriculum with core exam focus',
      },
      {
        'grade': 11,
        'desc': 'Specialization: Natural Science vs Social Science',
      },
      {
        'grade': 12,
        'desc': 'University Entrance: Comprehensive EUEE Exam Prep',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.space20),
          Text(
            'Select your Grade',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Text(
            'Acedex loads all units and subtopics for your syllabus.',
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
          ),
          const SizedBox(height: AppTheme.space24),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: grades.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppTheme.space12),
              itemBuilder: (context, index) {
                final item = grades[index];
                final gradeNum = item['grade'] as int;
                final isSelected = _data.grade == gradeNum;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _data = _data.copyWith(grade: gradeNum));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(AppTheme.space16),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primarySoft : colors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(
                        color: isSelected ? colors.primary : colors.border,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primary
                                : colors.surfaceAlt,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$gradeNum',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? colors.onPrimary
                                    : colors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Grade $gradeNum',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['desc'] as String,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                            color: colors.primary,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4: Stream Selection
  Widget _buildStreamStep(AppColors colors) {
    final isCommon = _data.grade == 9 || _data.grade == 10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.space20),
          Text(
            isCommon ? 'Common Curriculum' : 'Choose your Stream',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Text(
            isCommon
                ? 'Grades 9 and 10 study all common core subjects.'
                : 'Select your field of specialization for Grade ${_data.grade}.',
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
          ),
          const SizedBox(height: AppTheme.space24),
          if (isCommon) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.space20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedBookOpen01,
                        color: colors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: AppTheme.space12),
                      Text(
                        'Grade ${_data.grade} Core Subjects',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space12),
                  Text(
                    'Mathematics, English, Physics, Chemistry, Biology, History, Geography, Economics, and Aptitude.',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildStreamCard(
              colors,
              title: 'Natural Science',
              subtitle:
                  'Physics, Chemistry, Biology, Mathematics, English, SAT',
              streamKey: 'natural',
              icon: HugeIcons.strokeRoundedAtom02,
            ),
            const SizedBox(height: AppTheme.space16),
            _buildStreamCard(
              colors,
              title: 'Social Science',
              subtitle:
                  'History, Geography, Economics, Mathematics, English, SAT',
              streamKey: 'social',
              icon: HugeIcons.strokeRoundedGlobe02,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStreamCard(
    AppColors colors, {
    required String title,
    required String subtitle,
    required String streamKey,
    required List<List<dynamic>> icon,
  }) {
    final isSelected = _data.stream == streamKey;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _data = _data.copyWith(stream: streamKey));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppTheme.space20),
        decoration: BoxDecoration(
          color: isSelected ? colors.primarySoft : colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: HugeIcon(
                  icon: icon,
                  color: isSelected ? colors.onPrimary : colors.textPrimary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                color: colors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  // STEP 5: Daily Goal & Streak Welcome
  Widget _buildGoalStep(AppColors colors) {
    final goals = [
      {
        'minutes': 60,
        'label': '1 hour / day',
        'desc': 'Light review & steady rhythm',
      },
      {
        'minutes': 90,
        'label': '1.5 hours / day',
        'desc': 'Consistent daily coverage',
      },
      {
        'minutes': 120,
        'label': '2 hours / day (Recommended)',
        'desc': 'Optimal EUEE score prep',
      },
      {
        'minutes': 180,
        'label': '3 hours / day',
        'desc': 'Deep focus & mastery',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.space20),
          Text(
            'Set your Daily Target',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Text(
            'Consistency unlocks streak freezes and high exam scores.',
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
          ),
          const SizedBox(height: AppTheme.space24),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: goals.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppTheme.space12),
              itemBuilder: (context, index) {
                final item = goals[index];
                final minutes = item['minutes'] as int;
                final isSelected = _data.dailyGoalMinutes == minutes;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(
                      () => _data = _data.copyWith(dailyGoalMinutes: minutes),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(AppTheme.space16),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primarySoft : colors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(
                        color: isSelected ? colors.primary : colors.border,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedClock01,
                          color: isSelected
                              ? colors.primary
                              : colors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(width: AppTheme.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['label'] as String,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['desc'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                            color: colors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedFire,
                  color: colors.warning,
                  size: 24,
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: Text(
                    'Welcome gift: 1 Free Streak Freeze will be added to your account!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectablePill(
    AppColors colors, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppTheme.space16),
        decoration: BoxDecoration(
          color: isSelected ? colors.primarySoft : colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected ? colors.primary : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
