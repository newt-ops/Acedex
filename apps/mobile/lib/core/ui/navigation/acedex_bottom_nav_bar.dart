import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../theme/app_colors.dart';
import '../progress/acedex_dots_loader.dart';

/// Navigation item model for [AcedexBottomNavBar]
class AcedexNavItem {
  final dynamic icon;
  final String label;
  final Widget Function(BuildContext context, Color color, double size)? customIconBuilder;

  const AcedexNavItem({
    required this.label,
    this.icon,
    this.customIconBuilder,
  });
}

/// Acedex Canonical Apple iOS Floating Concave Notch Bottom Navigation Bar
///
/// Features:
/// - 348px x 68px floating rounded pill with corner radius 22px
/// - Traveling cubic-bezier concave valley (notch) cradling the elevated brand circle
/// - 50px x 50px elevated Royal Purple active circle centered 4px above bar top
/// - 6px x 6px active indicator dot at y=51px directly beneath the notch
/// - Real-time smoothstep icon elevation (-38px into the circle) and color interpolation
/// - Interactive tap selection and smooth horizontal drag scrubbing
/// - 3-Dots wave loader action inside the elevated active circle with expanding pulse ring
/// - Quiet floating active tab readout pill above the bar
/// - Centered iOS home indicator at bottom
class AcedexBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AcedexNavItem>? items;
  final VoidCallback? onActiveCircleTap;
  final bool showReadout;
  final bool showHomeIndicator;
  final bool autoTriggerActionOnCircleTap;

  const AcedexBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
    this.onActiveCircleTap,
    this.showReadout = true,
    this.showHomeIndicator = true,
    this.autoTriggerActionOnCircleTap = true,
  });

  /// Default 5 study navigation items matching canonical specification
  static List<AcedexNavItem> get defaultItems => [
        const AcedexNavItem(
          label: 'Home',
          icon: HugeIcons.strokeRoundedHome01,
        ),
        const AcedexNavItem(
          label: 'Search',
          icon: HugeIcons.strokeRoundedSearch01,
        ),
        AcedexNavItem(
          label: 'AI Scan',
          customIconBuilder: (context, color, size) => AcedexAiScanIcon(
            color: color,
            size: size,
          ),
        ),
        const AcedexNavItem(
          label: 'Saved',
          icon: HugeIcons.strokeRoundedBookmark02,
        ),
        const AcedexNavItem(
          label: 'Profile',
          icon: HugeIcons.strokeRoundedUserCircle,
        ),
      ];

  @override
  State<AcedexBottomNavBar> createState() => AcedexBottomNavBarState();
}

class AcedexBottomNavBarState extends State<AcedexBottomNavBar>
    with TickerProviderStateMixin {
  static const double barWidth = 348.0;
  static const double barHeight = 68.0;
  static const double cornerRadius = 22.0;
  static const double circleDiameter = 50.0;
  static const double influenceRadius = 46.0;

  // 5 slot centers inside 348px bar (24px horizontal padding, 60px slot width)
  static const List<double> slotCenters = [54.0, 114.0, 174.0, 234.0, 294.0];

  late AnimationController _positionController;
  late Animation<double> _positionAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseScaleAnimation;
  late Animation<double> _pulseOpacityAnimation;

  late AnimationController _bounceController;
  late Animation<double> _bounceScaleAnimation;

  double _currentX = slotCenters[2];
  bool _isScrubbing = false;
  double _scrubStartX = 0.0;
  bool _hasDraggedFar = false;
  bool _isLoadingAction = false;

  List<AcedexNavItem> get _items => widget.items ?? AcedexBottomNavBar.defaultItems;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.currentIndex.clamp(0, slotCenters.length - 1);
    _currentX = slotCenters[initialIndex];

    _positionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _positionAnimation = Tween<double>(begin: _currentX, end: _currentX).animate(
      CurvedAnimation(parent: _positionController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _currentX = _positionAnimation.value;
        });
      });

    // Expanding pulse ring for 3-dot action
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _pulseScaleAnimation = Tween<double>(begin: 0.92, end: 1.56).animate(
      CurvedAnimation(parent: _pulseController, curve: const Interval(0.0, 0.9, curve: Curves.easeOutQuad)),
    );
    _pulseOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.72, end: 0.35), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.35, end: 0.0), weight: 70),
    ]).animate(_pulseController);

    // Elastic action bounce on circle
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _bounceScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.88), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 0.88, end: 1.10), weight: 35),
      TweenSequenceItem(tween: Tween<double>(begin: 1.10, end: 0.97), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 0.97, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(AcedexBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex && !_isScrubbing) {
      _animateToSlot(widget.currentIndex.clamp(0, slotCenters.length - 1));
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _animateToSlot(int index) {
    final targetX = slotCenters[index];
    _positionAnimation = Tween<double>(
      begin: _currentX,
      end: targetX,
    ).animate(
      CurvedAnimation(parent: _positionController, curve: Curves.easeOutCubic),
    );
    _positionController.forward(from: 0.0);
  }

  /// Triggers the canonical 3-Dots Action Wave Loader and expanding pulse ring
  void triggerThreeDotAction() {
    if (_isLoadingAction) return;

    setState(() {
      _isLoadingAction = true;
    });

    _pulseController.forward(from: 0.0);
    _bounceController.forward(from: 0.0);

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) {
        setState(() {
          _isLoadingAction = false;
        });
        _bounceController.forward(from: 0.0);
      }
    });
  }

  int _findNearestSlot(double x) {
    int bestIdx = 0;
    double bestDist = double.infinity;
    for (int i = 0; i < slotCenters.length; i++) {
      final d = (x - slotCenters[i]).abs();
      if (d < bestDist) {
        bestDist = d;
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    final localX = details.localPosition.dx;
    _isScrubbing = true;
    _hasDraggedFar = false;
    _scrubStartX = localX;
    _bounceController.animateTo(0.2, duration: const Duration(milliseconds: 120));
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isScrubbing) return;
    final localX = details.localPosition.dx;
    if ((localX - _scrubStartX).abs() > 7.0) {
      _hasDraggedFar = true;
      final clampedX = localX.clamp(slotCenters.first, slotCenters.last);
      setState(() {
        _currentX = clampedX;
      });
      final nearest = _findNearestSlot(clampedX);
      if (nearest != widget.currentIndex) {
        widget.onTap(nearest);
      }
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (!_isScrubbing) return;
    _isScrubbing = false;
    _bounceController.reverse();

    final nearest = _findNearestSlot(_currentX);
    if (_hasDraggedFar) {
      _animateToSlot(nearest);
      if (nearest != widget.currentIndex) {
        widget.onTap(nearest);
      }
    } else {
      if (nearest == widget.currentIndex) {
        _onSlotTapped(nearest);
      } else {
        widget.onTap(nearest);
        _animateToSlot(nearest);
      }
    }
  }

  void _onSlotTapped(int index) {
    if (index == widget.currentIndex) {
      if (widget.autoTriggerActionOnCircleTap) {
        triggerThreeDotAction();
      }
      widget.onActiveCircleTap?.call();
    } else {
      if (_isLoadingAction) {
        setState(() {
          _isLoadingAction = false;
        });
      }
      widget.onTap(index);
      _animateToSlot(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryAccent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final primaryAccentSoft = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final onAccentColor = isDark ? AppColors.onAccentDark : AppColors.onAccentLight;
    final barSurfaceColor = isDark ? AppColors.darkSurface : AppColors.lightRaised;
    final inactiveIconColor = isDark ? const Color(0xFF585862) : const Color(0xFFC2C2C8);
    final homeIndicatorColor = isDark ? const Color(0xFF3A3A42) : const Color(0xFFC7C7CC);

    final shadowColor1 = isDark
        ? const Color(0x94000000)
        : const Color(0x141C1C1E);
    final shadowColor2 = isDark
        ? const Color(0x5C000000)
        : const Color(0x0A1C1C1E);

    final fabShadows = isDark
        ? [
            const BoxShadow(
              color: Color(0x6BB866CF),
              offset: Offset(0, 12),
              blurRadius: 26,
              spreadRadius: -4,
            ),
            const BoxShadow(
              color: Color(0x85000000),
              offset: Offset(0, 4),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ]
        : [
            const BoxShadow(
              color: Color(0x6B8A2BA3),
              offset: Offset(0, 10),
              blurRadius: 22,
              spreadRadius: -4,
            ),
            const BoxShadow(
              color: Color(0x388A2BA3),
              offset: Offset(0, 4),
              blurRadius: 10,
              spreadRadius: -2,
            ),
          ];

    final currentItem = _items[widget.currentIndex.clamp(0, _items.length - 1)];

    return Semantics(
      container: true,
      label: 'Acedex Bottom Navigation Bar',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Quiet Active Tab Readout Pill Above Floating Bar
          if (widget.showReadout) ...[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey<String>(currentItem.label),
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.5),
                decoration: BoxDecoration(
                  color: barSurfaceColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: primaryAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      currentItem.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 2. Floating Concave Notch Navigation Bar
          FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: barWidth,
              height: barHeight + 35.0, // 103px total height: 35px above bar + 68px bar
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // A. Concave Notch SVG Path Painter
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: barHeight,
                    child: CustomPaint(
                      size: const Size(barWidth, barHeight),
                      painter: _ConcavePillPainter(
                        cx: _currentX,
                        surfaceColor: barSurfaceColor,
                        shadowColor1: shadowColor1,
                        shadowColor2: shadowColor2,
                      ),
                    ),
                  ),

                  // B. Expanding Pulse Ring Behind Elevated Circle (Active during 3-dot action)
                  if (_isLoadingAction)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        final ringSize = circleDiameter * _pulseScaleAnimation.value;
                        return Positioned(
                          top: 31.0 - (ringSize / 2),
                          left: _currentX - (ringSize / 2),
                          width: ringSize,
                          height: ringSize,
                          child: Opacity(
                            opacity: _pulseOpacityAnimation.value.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryAccentSoft.withValues(alpha: 0.35),
                                border: Border.all(
                                  color: primaryAccent,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  // C. Elevated 50px x 50px Royal Purple Active Brand Circle
                  // Center is at y=31px (4px above bar top, delta from bar center = -38px)
                  Positioned(
                    top: 6.0,
                    left: _currentX - (circleDiameter / 2),
                    width: circleDiameter,
                    height: circleDiameter,
                    child: AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _bounceScaleAnimation.value,
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _onSlotTapped(widget.currentIndex),
                        child: Container(
                          width: circleDiameter,
                          height: circleDiameter,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryAccent,
                            boxShadow: fabShadows,
                          ),
                          child: Center(
                            child: _isLoadingAction
                                ? AcedexDotsLoader(
                                    dotSize: 6.0,
                                    gap: 4.5,
                                    color: onAccentColor,
                                    duration: const Duration(milliseconds: 820),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // D. Crisp 6px x 6px Active Indicator Dot at y=51px from bar top
                  // Bar top is at y=35, so y=35+51-3 = 83px from top
                  Positioned(
                    top: 35.0 + 51.0 - 3.0,
                    left: _currentX - 3.0,
                    width: 6,
                    height: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // E. Five Evenly Spaced Icon Slots with Dynamic Smoothstep Lift
                  Positioned(
                    bottom: 0,
                    left: 0,
                    width: barWidth,
                    height: barHeight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragStart: _handleHorizontalDragStart,
                      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
                      onHorizontalDragEnd: _handleHorizontalDragEnd,
                      child: Row(
                        children: [
                          const SizedBox(width: 24.0), // Horizontal padding
                          for (int i = 0; i < _items.length && i < 5; i++) ...[
                            _buildSlotButton(
                              context: context,
                              index: i,
                              item: _items[i],
                              isDark: isDark,
                              primaryAccent: primaryAccent,
                              onAccentColor: onAccentColor,
                              inactiveColor: inactiveIconColor,
                            ),
                          ],
                          const SizedBox(width: 24.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Apple iOS Home Indicator Pill at bottom
          if (widget.showHomeIndicator) ...[
            const SizedBox(height: 10),
            Container(
              width: 134,
              height: 5,
              decoration: BoxDecoration(
                color: homeIndicatorColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  Widget _buildSlotButton({
    required BuildContext context,
    required int index,
    required AcedexNavItem item,
    required bool isDark,
    required Color primaryAccent,
    required Color onAccentColor,
    required Color inactiveColor,
  }) {
    final slotCenterX = slotCenters[index];
    final dist = (_currentX - slotCenterX).abs();
    final raw = (1.0 - dist / influenceRadius).clamp(0.0, 1.0);
    // Apple cubic smoothstep easing
    final p = raw * raw * (3.0 - 2.0 * raw);

    // Delta between bar center (y=34) and elevated circle center (y=-4) = -38px
    final liftY = -38.0 * p;
    final scale = 1.0 + 0.08 * p;

    // If 3-dots action is running on this active tab, smoothly hide the active icon
    final activeIconOpacity = (_isLoadingAction && index == widget.currentIndex) ? 0.0 : p;
    final inactiveIconOpacity = (1.0 - p).clamp(0.0, 1.0);

    return SizedBox(
      key: Key('nav-slot-$index'),
      width: 60.0,
      height: barHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onSlotTapped(index),
        child: Center(
          child: Transform.translate(
            offset: Offset(0, liftY),
            child: Transform.scale(
              scale: scale,
              child: SizedBox(
                width: 24,
                height: 24,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Inactive Icon Layer
                    Opacity(
                      opacity: inactiveIconOpacity,
                      child: _renderItemIcon(context, item, inactiveColor, 22.0),
                    ),
                    // Active Icon Layer (inside circle)
                    Opacity(
                      opacity: activeIconOpacity,
                      child: _renderItemIcon(context, item, onAccentColor, 22.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderItemIcon(BuildContext context, AcedexNavItem item, Color color, double size) {
    if (item.customIconBuilder != null) {
      return item.customIconBuilder!(context, color, size);
    }
    if (item.icon is List<List<dynamic>>) {
      return HugeIcon(
        icon: item.icon as List<List<dynamic>>,
        color: color,
        size: size,
      );
    }
    if (item.icon is IconData) {
      return Icon(
        item.icon as IconData,
        color: color,
        size: size,
      );
    }
    return Icon(Icons.star, color: color, size: size);
  }
}

/// Custom painter generating the SVG traveling cubic-bezier concave notch
class _ConcavePillPainter extends CustomPainter {
  final double cx;
  final Color surfaceColor;
  final Color shadowColor1;
  final Color shadowColor2;

  _ConcavePillPainter({
    required this.cx,
    required this.surfaceColor,
    required this.shadowColor1,
    required this.shadowColor2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;
    const R = 22.0;
    const halfSpan = 43.0;
    const depth = 27.0;

    // Clamp shoulders cleanly inside top corner tangents [R, W - R]
    final xL = (cx - halfSpan).clamp(R, W - R);
    final xR = (cx + halfSpan).clamp(R, W - R);
    final leftSpan = cx - xL;
    final rightSpan = xR - cx;

    // Symmetrical cubic-bezier control points forming a concentric cradle
    final lCp1X = xL + leftSpan * 0.40;
    final lCp2X = cx - leftSpan * 0.58;
    final rCp1X = cx + rightSpan * 0.58;
    final rCp2X = xR - rightSpan * 0.40;

    final path = Path()
      ..moveTo(R, 0)
      ..lineTo(xL, 0)
      ..cubicTo(lCp1X, 0, lCp2X, depth, cx, depth)
      ..cubicTo(rCp1X, depth, rCp2X, 0, xR, 0)
      ..lineTo(W - R, 0)
      ..arcToPoint(Offset(W, R), radius: const Radius.circular(R))
      ..lineTo(W, H - R)
      ..arcToPoint(Offset(W - R, H), radius: const Radius.circular(R))
      ..lineTo(R, H)
      ..arcToPoint(Offset(0, H - R), radius: const Radius.circular(R))
      ..lineTo(0, R)
      ..arcToPoint(Offset(R, 0), radius: const Radius.circular(R))
      ..close();

    // Drop Shadow 1 (Deep soft ambient blur)
    final shadowPaint1 = Paint()
      ..color = shadowColor1
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13.0);
    canvas.save();
    canvas.translate(0, 12);
    canvas.drawPath(path, shadowPaint1);
    canvas.restore();

    // Drop Shadow 2 (Tight edge definition)
    final shadowPaint2 = Paint()
      ..color = shadowColor2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.save();
    canvas.translate(0, 2);
    canvas.drawPath(path, shadowPaint2);
    canvas.restore();

    // Surface Fill
    final fillPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _ConcavePillPainter oldDelegate) {
    return oldDelegate.cx != cx ||
        oldDelegate.surfaceColor != surfaceColor ||
        oldDelegate.shadowColor1 != shadowColor1 ||
        oldDelegate.shadowColor2 != shadowColor2;
  }
}

/// Custom vector icon for the AI Scan viewfinder matching the prototype SVG
class AcedexAiScanIcon extends StatelessWidget {
  final Color color;
  final double size;

  const AcedexAiScanIcon({
    super.key,
    required this.color,
    this.size = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AiScanIconPainter(color: color),
    );
  }
}

class _AiScanIconPainter extends CustomPainter {
  final Color color;

  _AiScanIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Viewfinder brackets:
    // Top Left
    final tlPath = Path()
      ..moveTo(4.5, 9.0)
      ..lineTo(4.5, 6.8)
      ..arcToPoint(const Offset(6.8, 4.5), radius: const Radius.circular(2.3))
      ..lineTo(9.0, 4.5);
    canvas.drawPath(tlPath, strokePaint);

    // Top Right
    final trPath = Path()
      ..moveTo(15.0, 4.5)
      ..lineTo(17.2, 4.5)
      ..arcToPoint(const Offset(19.5, 6.8), radius: const Radius.circular(2.3))
      ..lineTo(19.5, 9.0);
    canvas.drawPath(trPath, strokePaint);

    // Bottom Right
    final brPath = Path()
      ..moveTo(19.5, 15.0)
      ..lineTo(19.5, 17.2)
      ..arcToPoint(const Offset(17.2, 19.5), radius: const Radius.circular(2.3))
      ..lineTo(15.0, 19.5);
    canvas.drawPath(brPath, strokePaint);

    // Bottom Left
    final blPath = Path()
      ..moveTo(9.0, 19.5)
      ..lineTo(6.8, 19.5)
      ..arcToPoint(const Offset(4.5, 17.2), radius: const Radius.circular(2.3))
      ..lineTo(4.5, 15.0);
    canvas.drawPath(blPath, strokePaint);

    // Centered rounded formula / pill bar: rect at x=7.5, y=9.8, w=9, h=4.4, r=2.2
    final pillRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(7.5, 9.8, 9.0, 4.4),
      const Radius.circular(2.2),
    );
    canvas.drawRRect(pillRRect, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AiScanIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
