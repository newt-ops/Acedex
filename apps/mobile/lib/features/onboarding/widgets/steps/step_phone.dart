import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/buttons/acedex_button.dart';
import '../../../../core/ui/inputs/acedex_text_field.dart';
import '../../../auth/services/auth_service.dart';

enum PhoneDetectorState {
  idle,
  checking,
  available,
  alreadyRegistered,
}

class StepPhone extends StatefulWidget {
  final String initialPhone;
  final ValueChanged<String> onPhoneChanged;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final AuthService? authService;

  const StepPhone({
    super.key,
    required this.initialPhone,
    required this.onPhoneChanged,
    required this.onContinue,
    required this.onBack,
    this.authService,
  });

  @override
  State<StepPhone> createState() => _StepPhoneState();
}

class _StepPhoneState extends State<StepPhone> {
  late final TextEditingController _controller;
  late final AuthService _authService;
  Timer? _debounceTimer;
  PhoneDetectorState _detectorState = PhoneDetectorState.idle;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();

    var display = widget.initialPhone;
    if (display.startsWith('+251')) {
      display = display.substring(4);
    } else if (display.startsWith('251')) {
      display = display.substring(3);
    } else if (display.startsWith('0')) {
      display = display.substring(1);
    }
    _controller = TextEditingController(text: display);

    _controller.addListener(_onInputChanged);
    if (display.isNotEmpty) {
      _triggerDetector();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onInputChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    setState(() {});
    _triggerDetector();
  }

  void _triggerDetector() {
    _debounceTimer?.cancel();
    final raw = _controller.text.trim();
    if (!AuthService.isValidPhone(raw)) {
      if (_detectorState != PhoneDetectorState.idle) {
        setState(() {
          _detectorState = PhoneDetectorState.idle;
        });
      }
      return;
    }

    setState(() {
      _detectorState = PhoneDetectorState.checking;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      final clean = AuthService.normalizePhone(raw);
      final isRegistered = await _authService.checkPhoneRegistered(clean);
      if (!mounted) return;

      setState(() {
        _detectorState = isRegistered
            ? PhoneDetectorState.alreadyRegistered
            : PhoneDetectorState.available;
      });
    });
  }

  bool get _isValid {
    final raw = _controller.text.trim();
    return AuthService.isValidPhone(raw) &&
        _detectorState != PhoneDetectorState.alreadyRegistered;
  }

  void _submit() {
    if (_isValid) {
      final clean = AuthService.normalizePhone(_controller.text.trim());
      widget.onPhoneChanged(clean);
      widget.onContinue();
    }
  }

  void _goToLogin(String cleanPhone) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/auth',
      (route) => false,
      arguments: {'prefilledPhone': cleanPhone},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final errorColor = isDark ? AppColors.darkError : AppColors.error;

    final cleanPhone = AuthService.normalizePhone(_controller.text.trim());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Category Badge
          Text(
            'YOUR ACCOUNT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),

          // Main Title
          Text(
            "What's your phone number?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          Text(
            "We'll use this to set up your student account.",
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: subtext,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 32),

          // Ethiopian Phone Input Row with +251 prefix
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // +251 Prefix Box
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _detectorState ==
                            PhoneDetectorState.alreadyRegistered
                        ? errorColor
                        : line,
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedCall02,
                      color: accent,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+251',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Squircle Input Field
              Expanded(
                child: AcedexTextField(
                  controller: _controller,
                  hint: '912 345 678',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Live Animated Detector Status
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _detectorState == PhoneDetectorState.idle
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Text(
              'Supports formats: 09..., 07..., 9..., or 7...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: subtext,
              ),
            ),
            secondChild: Builder(
              builder: (context) {
                switch (_detectorState) {
                  case PhoneDetectorState.checking:
                    return Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Verifying phone availability...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: subtext,
                          ),
                        ),
                      ],
                    );
                  case PhoneDetectorState.available:
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                            size: 14,
                            color: Color(0xFF16A34A),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Phone number is available for registration',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    );
                  case PhoneDetectorState.alreadyRegistered:
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkErrorSoft
                            : AppColors.lightErrorSoft,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: errorColor.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedAlertCircle,
                                size: 16,
                                color: errorColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This phone number is already registered.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: errorColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => _goToLogin(cleanPhone),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Sign in with this number instead',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: accent,
                                    decoration: TextDecoration.underline,
                                    decorationColor: accent,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedArrowRight01,
                                  size: 14,
                                  color: accent,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  case PhoneDetectorState.idle:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),

          const Spacer(),

          // Continue Button
          AcedexButton(
            label: 'Continue',
            variant: AcedexButtonVariant.primary,
            size: AcedexButtonSize.lg,
            isFullWidth: true,
            trailingIcon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 18,
              color: Colors.white,
            ),
            onPressed: _isValid ? _submit : null,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
