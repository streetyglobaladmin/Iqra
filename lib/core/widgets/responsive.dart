import 'package:flutter/material.dart';

/// Lightweight responsive helpers so the same codebase renders well on
/// phones (native Android target) and wide desktop browsers (Public
/// Website, IQRA Studio, Nuerizo Control Center web deployments) without
/// a second UI implementation.
class Breakpoints {
  Breakpoints._();
  static const double tablet = 720;
  static const double desktop = 1080;
  static const double wide = 1440;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
}

/// Centers content with a sensible max width on large screens, while
/// staying edge-to-edge on phones. Use this to wrap page bodies for
/// Studio / Control Center / Public Website so they don't stretch into
/// unreadable full-bleed rows on desktop browsers.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 1100,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Returns 1/2/3 grid columns based on available width — used by the
/// Public Website feature/lecture grids and admin summary cards.
int responsiveColumns(double width) {
  if (width >= Breakpoints.wide) return 4;
  if (width >= Breakpoints.desktop) return 3;
  if (width >= Breakpoints.tablet) return 2;
  return 1;
}
