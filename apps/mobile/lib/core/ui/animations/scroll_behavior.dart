import 'package:flutter/material.dart';

/// Global Apple-Style Bouncing Scroll Behavior
///
/// Enforces fluid iOS rubber-band overscroll bouncing physics (`BouncingScrollPhysics`)
/// across all scrollable widgets (ListView, GridView, SingleChildScrollView, CustomScrollView)
/// on all target platforms, eliminating rigid Material overscroll glows.
class AcedexScrollBehavior extends MaterialScrollBehavior {
  const AcedexScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Return pure child without Android stretch/glow effect for a clean Apple rubber-band feel
    return child;
  }
}
