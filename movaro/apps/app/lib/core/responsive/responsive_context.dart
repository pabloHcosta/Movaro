import 'package:flutter/material.dart';
import 'package:movaro_app/core/responsive/app_breakpoints.dart';

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isMobileLayout => screenWidth < AppBreakpoints.mobile;
  bool get isTabletLayout =>
      screenWidth >= AppBreakpoints.mobile &&
      screenWidth < AppBreakpoints.tablet;
  bool get isDesktopLayout => screenWidth >= AppBreakpoints.tablet;

  double get pageHorizontalPadding {
    if (isDesktopLayout) {
      return 32;
    }

    if (isTabletLayout) {
      return 28;
    }

    return 20;
  }

  double get pageVerticalPadding => isDesktopLayout ? 32 : 24;

  double get sectionSpacing => isDesktopLayout ? 28 : 24;
}
