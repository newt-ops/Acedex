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
  final Set<int> _loadingTabs = {};

  @override
  void initState() {
    super.initState();
    // Brief graceful initial skeleton on Home launch
    _loadingTabs.add(0);
    Future.delayed(const Duration(milliseconds: 320), () {
      if (mounted) {
        setState(() {
          _loadingTabs.remove(0);
        });
      }
    });
  }

  Future<void> _signOut(BuildContext context) async {
    await AuthStorage.instance.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  void _navigateToTab(int index) {
    if (index == _currentIndex && !_loadingTabs.contains(index)) return;
    setState(() {
      _currentIndex = index;
      _loadingTabs.add(index);
    });

    // Brief smooth skeleton loading placeholder when navigating across all 5 screens
    Future.delayed(const Duration(milliseconds: 320), () {
      if (mounted) {
        setState(() {
          _loadingTabs.remove(index);
        });
      }
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _loadingTabs.contains(0)
                ? const AcedexDashboardSkeleton(key: ValueKey('skeleton_0'))
                : DashboardScreen(
                    key: const ValueKey('screen_0'),
                    user: widget.user,
                    onNavigateToStudy: () => _navigateToTab(1),
                    onNavigateToPractice: () => _navigateToTab(2),
                  ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _loadingTabs.contains(1)
                ? const AcedexStudySkeleton(key: ValueKey('skeleton_1'))
                : StudyScreen(
                    key: const ValueKey('screen_1'),
                    user: widget.user,
                  ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _loadingTabs.contains(2)
                ? const AcedexPracticeSkeleton(key: ValueKey('skeleton_2'))
                : PracticeScreen(
                    key: const ValueKey('screen_2'),
                    user: widget.user,
                  ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _loadingTabs.contains(3)
                ? const AcedexProgressSkeleton(key: ValueKey('skeleton_3'))
                : ProgressScreen(
                    key: const ValueKey('screen_3'),
                    user: widget.user,
                  ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _loadingTabs.contains(4)
                ? const AcedexProfileSkeleton(key: ValueKey('skeleton_4'))
                : ProfileScreen(
                    key: const ValueKey('screen_4'),
                    user: widget.user,
                    onSignOut: () => _signOut(context),
                  ),
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
