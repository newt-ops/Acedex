import 'package:flutter/material.dart';

class OnboardingItem {
  final String title;
  final String subtitle;
  final String badgeText;
  final IconData icon;

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
      icon: Icons.menu_book_rounded,
    ),
    OnboardingItem(
      badgeText: 'National Exam Ready',
      title: 'Simulate the EUEE',
      subtitle:
          'Practice with authentic past entrance examinations under realistic exam conditions, timers, and scoring models.',
      icon: Icons.timer_outlined,
    ),
    OnboardingItem(
      badgeText: 'Proven Results',
      title: 'Track Your Growth',
      subtitle:
          'Keep your daily study streak alive, conquer difficult chapters, and enter exam day with unshakeable confidence.',
      icon: Icons.auto_graph_rounded,
    ),
  ];
}
