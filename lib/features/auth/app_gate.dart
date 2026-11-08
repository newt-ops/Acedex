import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../profile/student_provider.dart';
import '../security/pin_provider.dart';
import '../security/screens/pin_lock_screen.dart';
import '../onboarding/screens/intro_flow_screen.dart';
import '../../main.dart';

class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. PIN Lock Priority
    final pinState = ref.watch(pinProvider);
    if (pinState.isLocked) {
      return const PinLockScreen();
    }

    // 2. Onboarding Gate
    final isOnboardingCompleted = ref.watch(isOnboardingCompletedProvider);
    if (!isOnboardingCompleted) {
      return IntroFlowScreen(
        onCompleted: () {
          ref.invalidate(isOnboardingCompletedProvider);
        },
      );
    }

    // 3. Main Application Navigation
    return const MainNavigationShell();
  }
}

