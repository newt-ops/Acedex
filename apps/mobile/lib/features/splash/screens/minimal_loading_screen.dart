import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../painters/acedex_logo_painter.dart';

/// Minimal Returning Loading Screen
///
/// Displayed whenever a returning user enters the app.
/// Seamlessly checks stored credentials, automatically retrieves the registered/logged-in
/// phone number, and redirects directly to the PIN verification screen (/auth/pin).
class MinimalLoadingScreen extends StatefulWidget {
  final Duration? duration;
  final VoidCallback? onLoaded;
  final String? lastPhone;

  const MinimalLoadingScreen({
    super.key,
    this.duration,
    this.onLoaded,
    this.lastPhone,
  });

  @override
  State<MinimalLoadingScreen> createState() => _MinimalLoadingScreenState();
}

class _MinimalLoadingScreenState extends State<MinimalLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.98, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    final delay = widget.duration ?? const Duration(milliseconds: 1400);
    _timer = Timer(delay, _handleComplete);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    if (!mounted) return;

    if (widget.onLoaded != null) {
      widget.onLoaded!();
      return;
    }

    _pulseController.stop();

    final storage = AuthStorage.instance;
    final lastPhone = widget.lastPhone ?? await storage.getLastPhone();

    if (!mounted) return;

    if (lastPhone != null && lastPhone.trim().isNotEmpty) {
      Navigator.of(context).pushReplacementNamed(
        '/auth/pin',
        arguments: {'phone': lastPhone.trim()},
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final accentSoft = isDark
        ? AppColors.darkAccentSoft
        : AppColors.lightAccentSoft;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Breathing Vector Emblem with Ambient Aura
              AnimatedBuilder(
                animation: _pulseScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseScale.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: accentSoft,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: isDark ? 0.28 : 0.16),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: CustomPaint(
                      painter: AcedexLogoPainter(
                        archSpring: 1.0,
                        waveSpring: 1.0,
                        orbSpring: 1.0,
                        showOrb: true,
                        color: accent,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Geometric Brand Wordmark
              Text(
                'Acedex',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                  color: text,
                ),
              ),

              const SizedBox(height: 6),

              // Editorial Micro-Label
              Text(
                'EUEE STUDY ENVIRONMENT',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: subtext,
                ),
              ),

              const SizedBox(height: 32),

              // Apple Horizontal 3-Dots Wave Loader
              AcedexDotsLoader(color: accent, dotSize: 5.5, gap: 4.0),
            ],
          ),
        ),
      ),
    );
  }
}
