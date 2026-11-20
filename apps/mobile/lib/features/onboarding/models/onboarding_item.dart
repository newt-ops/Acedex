import 'package:hugeicons/hugeicons.dart';

class OnboardingItem {
  final String title;
  final String subtitle;
  final String badgeText;
  final List<List<dynamic>> icon;

  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.icon,
  });

  static const List<OnboardingItem> items = [
    OnboardingItem(
      badgeText: 'Grades 9 – 12',
      title: 'Master Every Subject',
      subtitle:
          'Access curriculum-aligned questions with verified answer keys, detailed explanations, and complete textbook coverage.',
      icon: HugeIcons.strokeRoundedBookOpen01,
    ),
    OnboardingItem(
      badgeText: 'National Exam Ready',
      title: 'Simulate the EUEE',
      subtitle:
          'Practice with authentic past entrance examinations under realistic exam conditions, timers, and scoring models.',
      icon: HugeIcons.strokeRoundedClock01,
    ),
    OnboardingItem(
      badgeText: 'Proven Results',
      title: 'Track Your Growth',
      subtitle:
          'Keep your daily study streak alive, conquer difficult chapters, and enter exam day with unshakeable confidence.',
      icon: HugeIcons.strokeRoundedAnalytics01,
    ),
  ];
}
