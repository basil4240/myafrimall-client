import 'package:flutter/material.dart';

class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600.0;
  static const double tablet = 1024.0;

  // Use inside widgets with MediaQuery
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobile && w < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;

  static bool isMobileOrTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < tablet;

  // Use inside LayoutBuilder (preferred - avoids MediaQuery rebuild cost)
  static bool isMobileC(double maxWidth) => maxWidth < mobile;
  static bool isTabletC(double maxWidth) =>
      maxWidth >= mobile && maxWidth < tablet;
  static bool isDesktopC(double maxWidth) => maxWidth >= tablet;
  static bool isMobileOrTabletC(double maxWidth) => maxWidth < tablet;
}