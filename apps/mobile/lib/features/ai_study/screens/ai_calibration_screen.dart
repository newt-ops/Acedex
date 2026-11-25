import 'package:flutter/material.dart';
import '../../../core/ads/ads.dart';
import '../../../core/models/user_profile.dart';
import '../models/ai_study_models.dart';
import '../services/ai_study_service.dart';
import '../widgets/ai_calibration_flow.dart';

/// Full-Screen Route for AI Study Plan Calibration Onboarding.
///
/// Renders cleanly without [AcedexHeaderBar] or [AcedexBottomNavBar].
/// Pops back with the generated [AiTopicProgramOverview] once the user completes
/// synthesis and taps "Start Topic Study Program", or `null` if cancelled.
class AiCalibrationScreen extends StatelessWidget {
  final UserProfile? user;
  final AiStudyRepository repository;
  final AcedexAdsRepository? adsRepository;
  final bool canGenerateToday;
  final bool requiresAd;
  final AiCalibrationInput? initialCalibration;

  const AiCalibrationScreen({
    super.key,
    required this.user,
    required this.repository,
    this.adsRepository,
    required this.canGenerateToday,
    required this.requiresAd,
    this.initialCalibration,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: AiCalibrationFlow(
          user: user,
          repository: repository,
          adsRepository: adsRepository,
          canGenerateToday: canGenerateToday,
          requiresAd: requiresAd,
          initialCalibration: initialCalibration,
          onCancel: () => Navigator.of(context).pop(null),
          onProgramReady: (overview) => Navigator.of(context).pop(overview),
        ),
      ),
    );
  }
}
