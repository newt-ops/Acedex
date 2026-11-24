import 'package:flutter/material.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/ui/ui.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../ai_study/screens/ai_study_screen.dart';
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
  final GlobalKey<AcedexBottomNavBarState> _navBarKey =
      GlobalKey<AcedexBottomNavBarState>();
  int _currentIndex = 0;
  final Set<int> _loadingTabs = {};
  final List<int> _reloadKeys = [0, 0, 0, 0, 0];

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
    if (index == _currentIndex) {
      // Tapping the active footer tab triggers a fresh reload with 3-dot & skeleton
      _reloadTab(index);
      return;
    }

    // Instant tab switch with zero reload and state preservation
    setState(() {
      _currentIndex = index;
    });
  }

  /// Triggers canonical 3-dot footer wave loader + screen skeleton reload
  void _reloadTab(int index) {
    if (_loadingTabs.contains(index)) return;

    // Trigger 3-dots action animation in footer bar elevated notch
    _navBarKey.currentState?.triggerThreeDotAction();

    setState(() {
      _loadingTabs.add(index);
      _reloadKeys[index]++;
    });

    // Graceful smooth skeleton duration then render fresh live data
    Future.delayed(const Duration(milliseconds: 550), () {
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
                    key: ValueKey('screen_0_${_reloadKeys[0]}'),
                    user: widget.user,
                    onNavigateToStudy: () => _navigateToTab(1),
                    onNavigateToAiStudy: () => _navigateToTab(2),
                  ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _loadingTabs.contains(1)
                ? const AcedexStudySkeleton(key: ValueKey('skeleton_1'))
                : StudyScreen(
                    key: ValueKey('screen_1_${_reloadKeys[1]}'),
                    user: widget.user,
                  ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _loadingTabs.contains(2)
                ? const AcedexAiStudySkeleton(key: ValueKey('skeleton_2'))
                : AiStudyScreen(
                    key: ValueKey('screen_2_${_reloadKeys[2]}'),
                    user: widget.user,
                  ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _loadingTabs.contains(3)
                ? const AcedexProgressSkeleton(key: ValueKey('skeleton_3'))
                : ProgressScreen(
                    key: ValueKey('screen_3_${_reloadKeys[3]}'),
                    user: widget.user,
                  ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _loadingTabs.contains(4)
                ? const AcedexProfileSkeleton(key: ValueKey('skeleton_4'))
                : ProfileScreen(
                    key: ValueKey('screen_4_${_reloadKeys[4]}'),
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
            key: _navBarKey,
            currentIndex: _currentIndex,
            onTap: _navigateToTab,
            onActiveCircleTap: () => _reloadTab(_currentIndex),
          ),
        ),
      ),
    );
  }
}
