import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/inputs/acedex_theme_toggle.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../../onboarding/widgets/numeric_keypad.dart';
import '../services/auth_service.dart';

/// Full-Screen Apple-Style PIN Authentication Screen
///
/// Features complete software keyboard suppression, custom squircle numeric keypad,
/// tactile spring feedback, 6-digit auto-submission, and fluid error shake animations.
class LoginPinScreen extends StatefulWidget {
  final String phone;
  final AuthService? authService;

  const LoginPinScreen({
    super.key,
    required this.phone,
    this.authService,
  });

  @override
  State<LoginPinScreen> createState() => _LoginPinScreenState();
}

class _LoginPinScreenState extends State<LoginPinScreen>
    with SingleTickerProviderStateMixin {
  late final AuthService _authService;
  String _pin = '';
  bool _isLoading = false;
  String? _errorMessage;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 12.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_pin.length >= 6 || _isLoading) return;

    HapticFeedback.selectionClick();

    setState(() {
      _pin += digit;
      _errorMessage = null;
    });

    if (_pin.length == 6) {
      _handleLogin();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty || _isLoading) return;

    HapticFeedback.selectionClick();

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _errorMessage = null;
    });
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cleanPhone = AuthService.normalizePhone(widget.phone);
      final user = await _authService.login(
        phone: cleanPhone,
        pin: _pin,
      );

      if (!mounted) return;
      await AuthStorage.instance.saveLastPhone(cleanPhone);
      await AuthStorage.instance.setSeenSplash(true);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (route) => false,
        arguments: user,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0.0);
      setState(() {
        _errorMessage = e.message;
        _pin = '';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0.0);
      setState(() {
        _errorMessage = 'Unable to connect to Acedex. Please check connection.';
        _pin = '';
        _isLoading = false;
      });
    }
  }

  String _formatDisplayPhone(String raw) {
    final normalized = AuthService.normalizePhone(raw);
    if (normalized.startsWith('+251') && normalized.length == 13) {
      final code = normalized.substring(0, 4);
      final p1 = normalized.substring(4, 6);
      final p2 = normalized.substring(6, 9);
      final p3 = normalized.substring(9);
      return '$code $p1 $p2 $p3';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final softAccent =
        isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final errorColor = isDark ? AppColors.darkError : AppColors.error;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: AcedexBounceable(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/auth');
              }
            },
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                color: accent,
                size: 22,
              ),
            ),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: AcedexThemeToggle(compact: true),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(flex: 1),

                      // Top Lock Insignia
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: softAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accent.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedSquareLock02,
                          color: accent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Title
                      Text(
                        'Enter your PIN',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Candidate Phone Number Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: line, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedCall02,
                              color: accent,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDisplayPhone(widget.phone),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Switch Account / Use different number link
                      AcedexBounceable(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed('/auth');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          child: Text(
                            'Switch Account',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // 6-Digit PIN Squircle Indicator Cells
                      AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_shakeAnimation.value, 0),
                            child: child,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            final isFilled = index < _pin.length;
                            final isCurrent =
                                index == _pin.length && !_isLoading;

                            return Container(
                              width: 44,
                              height: 52,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: isFilled ? softAccent : surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _errorMessage != null
                                      ? errorColor
                                      : isCurrent
                                          ? accent
                                          : isFilled
                                              ? accent.withValues(alpha: 0.6)
                                              : line,
                                  width: (isCurrent || isFilled) ? 1.8 : 1.0,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: isFilled
                                  ? Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: accent,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : null,
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Error or Loading Indicator
                      SizedBox(
                        height: 26,
                        child: _isLoading
                            ? Center(
                                child: AcedexDotsLoader(
                                  color: accent,
                                  dotSize: 6.0,
                                  gap: 4.0,
                                ),
                              )
                            : _errorMessage != null
                                ? Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: errorColor,
                                    ),
                                  )
                                : null,
                      ),

                      const Spacer(flex: 2),

                      // Ergonomic 3x4 Custom Keypad (Software Keyboard Suppressed)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: NumericKeypad(
                          onDigit: _onDigit,
                          onDelete: _onDelete,
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
