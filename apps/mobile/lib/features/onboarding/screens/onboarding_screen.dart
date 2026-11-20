import 'package:flutter/material.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/ui/feedback/acedex_toast.dart';
import '../../auth/services/auth_service.dart';
import '../models/student_registration_draft.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/registration_success_dialog.dart';
import '../widgets/steps/step_gender.dart';
import '../widgets/steps/step_grade.dart';
import '../widgets/steps/step_name.dart';
import '../widgets/steps/step_phone.dart';
import '../widgets/steps/step_pin_keypad.dart';
import '../widgets/steps/step_review.dart';
import '../widgets/steps/step_stream.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final AuthService? authService;

  const OnboardingScreen({
    super.key,
    this.onComplete,
    this.authService,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  late final AuthService _authService;

  StudentRegistrationDraft _draft = const StudentRegistrationDraft();
  int _currentPage = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    final total = _draft.totalSteps;
    if (_currentPage < total - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _jumpToStep(int targetIndex) {
    // Clamp to valid range
    final target = targetIndex.clamp(0, _draft.totalSteps - 1);
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  void _goToSignIn() {
    Navigator.of(context).pushReplacementNamed(
      '/auth',
      arguments: {'initialTab': 0},
    );
  }

  Future<void> _handleRegistration() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final normalizedPhone = AuthService.normalizePhone(_draft.phoneNumber);

      await _authService.register(
        phone: normalizedPhone,
        pin: _draft.pin,
        fullName: _draft.fullName,
        gender: _draft.gender,
        grade: _draft.grade,
        stream: _draft.stream,
      );

      await AuthStorage.instance.setSeenOnboarding(true);

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      // Show celebratory Congratulatory Success Modal Dialog
      await RegistrationSuccessDialog.show(
        context,
        draft: _draft.copyWith(phoneNumber: normalizedPhone),
        onContinueToLogin: () {
          Navigator.of(context).pop(); // dismiss modal
          if (widget.onComplete != null) {
            widget.onComplete!();
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/auth',
              (route) => false,
              arguments: {'prefilledPhone': normalizedPhone},
            );
          }
        },
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      AcedexToast.show(
        context,
        message: e.message,
        type: AcedexToastType.error,
      );
    } catch (_) {
      if (!mounted) return;
      AcedexToast.show(
        context,
        message: 'Something went wrong. Please check your connection.',
        type: AcedexToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  List<Widget> _buildSteps() {
    return [
      // Step 1: Name
      StepName(
        initialName: _draft.fullName,
        onNameChanged: (val) {
          _draft = _draft.copyWith(fullName: val);
        },
        onContinue: _nextPage,
      ),

      // Step 2: Phone
      StepPhone(
        initialPhone: _draft.phoneNumber,
        authService: _authService,
        onPhoneChanged: (val) {
          _draft = _draft.copyWith(phoneNumber: val);
        },
        onContinue: _nextPage,
        onBack: _previousPage,
      ),

      // Step 3: Gender
      StepGender(
        selectedGender: _draft.gender,
        onGenderChanged: (val) {
          setState(() {
            _draft = _draft.copyWith(gender: val);
          });
        },
        onContinue: _nextPage,
        onBack: _previousPage,
      ),

      // Step 4: Grade
      StepGrade(
        selectedGrade: _draft.grade,
        onGradeChanged: (val) {
          setState(() {
            _draft = _draft.copyWith(grade: val);
          });
        },
        onContinue: _nextPage,
        onBack: _previousPage,
      ),

      // Step 5: Stream (bypassed if Grade 9/10)
      if (_draft.requiresStream)
        StepStream(
          selectedStream: _draft.stream ?? 'natural',
          onStreamChanged: (val) {
            setState(() {
              _draft = _draft.copyWith(stream: val);
            });
          },
          onContinue: _nextPage,
          onBack: _previousPage,
        ),

      // Step 6: Security PIN Keypad (Two-pass confirmation, no continue button)
      StepPinKeypad(
        onPinConfirmed: (pin) {
          _draft = _draft.copyWith(pin: pin);
          _nextPage();
        },
        onBack: _previousPage,
      ),

      // Step 7: Final Review & Student ID Card
      StepReview(
        draft: _draft,
        isSubmitting: _isSubmitting,
        onSubmit: _handleRegistration,
        onEditStep: _jumpToStep,
        onBack: _previousPage,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = _buildSteps();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: Brand/Back + Step Indicator + Segmented Progress Bar
            OnboardingHeader(
              currentStep: _currentPage,
              totalSteps: _draft.totalSteps,
              onBack: _previousPage,
              onSignInTap: _goToSignIn,
            ),

            // Step Content PageView (Swiping disabled: guided via button/keypad)
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: _onPageChanged,
                children: steps,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
