import 'package:flutter/material.dart';

class Spacing {
  // Enhanced vertical spacing values for better visual hierarchy
  static const double xxxs = 2.0;
  static const double xxs = 3.0;
  // Base spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Component-specific spacing for consistent visual hierarchy
  static const double cardPadding = 20.0;
  static const double sectionSpacing = 32.0;
  static const double componentSpacing = 12.0;
  static const double textSpacing = 6.0;

  // Padding values
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const EdgeInsets paddingVerticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(vertical: xl);

  // Margin values
  static const EdgeInsets marginXs = EdgeInsets.all(xs);
  static const EdgeInsets marginSm = EdgeInsets.all(sm);
  static const EdgeInsets marginMd = EdgeInsets.all(md);
  static const EdgeInsets marginLg = EdgeInsets.all(lg);
  static const EdgeInsets marginXl = EdgeInsets.all(xl);

  // Border radius values
  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(9999));

  // Icon sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;

  // Button heights
  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 40.0;
  static const double buttonHeightLg = 48.0;
  static const double buttonHeightXl = 56.0;

  // Elevation values
  static const double elevationNone = 0.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // Bottom navigation bar height
  static const double bottomNavHeight = 80.0;

  // App bar height
  static const double appBarHeight = 56.0;

  // Enhanced spacing widgets for better consistency
  static const Widget horizontalSpaceXxxs = SizedBox(width: xxxs);
  static const Widget horizontalSpaceXxs = SizedBox(width: xxs);
  static const Widget horizontalSpaceXs = SizedBox(width: xs);
  static const Widget horizontalSpaceSm = SizedBox(width: sm);
  static const Widget horizontalSpaceMd = SizedBox(width: md);
  static const Widget horizontalSpaceLg = SizedBox(width: lg);
  static const Widget horizontalSpaceXl = SizedBox(width: xl);

  static const Widget verticalSpaceXxxs = SizedBox(height: xxxs);
  static const Widget verticalSpaceXxs = SizedBox(height: xxs);
  static const Widget verticalSpaceXs = SizedBox(height: xs);
  static const Widget verticalSpaceSm = SizedBox(height: sm);
  static const Widget verticalSpaceMd = SizedBox(height: md);
  static const Widget verticalSpaceLg = SizedBox(height: lg);
  static const Widget verticalSpaceXl = SizedBox(height: xl);
  static const Widget verticalSpaceXxl = SizedBox(height: xxl);

  // Component-specific spacing widgets
  static const Widget cardSpacing = SizedBox(height: componentSpacing);
  static const Widget sectionSpacingWidget = SizedBox(height: sectionSpacing);
  static const Widget textSpacingWidget = SizedBox(height: textSpacing);

  // Responsive breakpoints
  static const double mobileBreakpoint = 480.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;

  // Safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // Responsive padding based on screen size
  static EdgeInsets responsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < mobileBreakpoint) {
      return paddingMd;
    } else if (screenWidth < tabletBreakpoint) {
      return paddingLg;
    } else {
      return paddingXl;
    }
  }

  // Responsive spacing based on screen size
  static double responsiveSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < mobileBreakpoint) {
      return md;
    } else if (screenWidth < tabletBreakpoint) {
      return lg;
    } else {
      return xl;
    }
  }
}
