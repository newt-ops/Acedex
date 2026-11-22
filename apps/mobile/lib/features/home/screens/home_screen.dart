import 'package:flutter/material.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/ui/ui.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../practice/screens/practice_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../progress/screens/progress_screen.dart';
import '../../study/screens/study_screen.dart';

/// Clean Apple-Style Root Home Navigation Shell
class HomeScreen extends StatefulWidget {
  final UserProfile? user;

  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Future<void> _signOut(BuildContext context) async {
    await AuthStorage.instance.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AcedexHeaderBar(
        user: widget.user,
        onProfileTap: () {
          ProfilePhotoModal.show(context, user: widget.user);
        },
        onNotificationTap: () {
          AcedexToast.show(
            context,
            message: 'Notification preferences synced',
            type: AcedexToastType.info,
          );
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(
            user: widget.user,
            onNavigateToStudy: () => _navigateToTab(1),
            onNavigateToPractice: () => _navigateToTab(2),
          ),
          StudyScreen(user: widget.user),
          PracticeScreen(user: widget.user),
          ProgressScreen(user: widget.user),
          ProfileScreen(
            user: widget.user,
            onSignOut: () => _signOut(context),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: AcedexBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _navigateToTab,
          ),
        ),
      ),
    );
  }
}
