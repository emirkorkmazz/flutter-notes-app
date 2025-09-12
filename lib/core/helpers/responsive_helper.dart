import 'package:flutter/material.dart';

/// Responsive design helper class for consistent spacing and text sizes
class ResponsiveHelper {
  ResponsiveHelper._();

  // Screen size breakpoints
  static const double _smallScreen = 600;
  static const double _mediumScreen = 900;
  static const double _largeScreen = 1200;

  // Mobile sub-categories
  static const double _mobileSmall = 375; // iPhone SE, small Androids
  static const double _mobileMedium = 414; // iPhone 12, 13, 14
  static const double _mobileLarge = 430; // iPhone 14 Pro Max

  /// Get screen type based on width
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _smallScreen) return ScreenType.mobile;
    if (width < _mediumScreen) return ScreenType.tablet;
    if (width < _largeScreen) return ScreenType.desktop;
    return ScreenType.largeDesktop;
  }

  /// Get mobile screen subtype
  static MobileScreenType getMobileScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= _mobileSmall) return MobileScreenType.small;
    if (width <= _mobileMedium) return MobileScreenType.medium;
    if (width <= _mobileLarge) return MobileScreenType.large;
    return MobileScreenType.large; // Extra large devices
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) =>
      getScreenType(context) == ScreenType.mobile;

  /// Check if device is tablet
  static bool isTablet(BuildContext context) =>
      getScreenType(context) == ScreenType.tablet;

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) =>
      getScreenType(context) == ScreenType.desktop ||
      getScreenType(context) == ScreenType.largeDesktop;

  /// Check if device is small mobile (iPhone SE, small Android)
  static bool isMobileSmall(BuildContext context) =>
      isMobile(context) &&
      getMobileScreenType(context) == MobileScreenType.small;

  /// Check if device is medium mobile (iPhone 12, 13, 14)
  static bool isMobileMedium(BuildContext context) =>
      isMobile(context) &&
      getMobileScreenType(context) == MobileScreenType.medium;

  /// Check if device is large mobile (iPhone 14 Pro Max)
  static bool isMobileLarge(BuildContext context) =>
      isMobile(context) &&
      getMobileScreenType(context) == MobileScreenType.large;

  /// Check if device has notch/dynamic island (çentik var mı?)
  static bool hasNotch(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return padding.top >
        24; // iOS status bar is 20-24px, notch devices have more
  }

  /// Check if device has Dynamic Island (iPhone 14 Pro and later models)
  /// Dynamic Island devices have safe area around 59px
  static bool hasDynamicIsland(BuildContext context) {
    final safeAreaTop = getTopSafeAreaPadding(context);
    final screenHeight = MediaQuery.of(context).size.height;
    // iPhone 14 Pro/Max, iPhone 15 Pro/Max, iPhone 16 series
    // Dynamic Island creates ~59px safe area
    return safeAreaTop >= 55 && safeAreaTop <= 65 && screenHeight > 800;
  }

  /// Check if device has safe area at top (çentik veya dynamic island)
  static bool hasTopSafeArea(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return padding.top > 0;
  }

  /// Get safe area top padding
  static double getTopSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// Get safe area bottom padding
  static double getBottomSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  // SPACING HELPERS

  /// Extra extra small spacing (2px base)
  static double spacingXXS(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.002; // ~2px on 800px height
  }

  /// Extra small spacing (4px base)
  static double spacingXS(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.005; // ~4px on 800px height
  }

  /// Small spacing (8px base)
  static double spacingS(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.01; // ~8px on 800px height
  }

  /// Medium spacing (16px base)
  static double spacingM(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.02; // ~16px on 800px height
  }

  /// Large spacing (24px base)
  static double spacingL(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.03; // ~24px on 800px height
  }

  /// Extra large spacing (32px base)
  static double spacingXL(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.04; // ~32px on 800px height
  }

  /// XXL spacing (48px base)
  static double spacingXXL(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.06; // ~48px on 800px height
  }

  /// Custom spacing based on height percentage
  static double spacing(BuildContext context, double percentage) {
    final height = MediaQuery.of(context).size.height;
    return height * percentage;
  }

  // TEXT SIZE HELPERS

  /// Extra extra small text (10px base)
  static double textSizeExtraExtraSmall(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile(context)) return width * 0.022; // ~10px on 375px width
    if (isTablet(context)) return width * 0.016; // ~15px on 750px width
    return 10; // Desktop fixed size
  }

  /// Extra small text (10px base)
  static double textSizeExtraSmall(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile(context)) return width * 0.027; // ~10px on 375px width
    if (isTablet(context)) return width * 0.020; // ~15px on 750px width
    return 12; // Desktop fixed size
  }

  /// Small text (12px base)
  static double textSizeSmall(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile(context)) return width * 0.032; // ~12px on 375px width
    if (isTablet(context)) return width * 0.024; // ~18px on 750px width
    return 14; // Desktop fixed size
  }

  /// Body text (14px base)
  static double textSizeBody(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile(context)) return width * 0.037; // ~14px on 375px width
    if (isTablet(context)) return width * 0.027; // ~20px on 750px width
    return 16; // Desktop fixed size
  }

  /// Medium text (16px base)
  static double textSizeMedium(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile(context)) return width * 0.043; // ~16px on 375px width
    if (isTablet(context)) return width * 0.032; // ~24px on 750px width
    return 18; // Desktop fixed size
  }

  /// Large text (18px base)
  static double textSizeLarge(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile(context)) return width * 0.048; // ~18px on 375px width
    if (isTablet(context)) return width * 0.036; // ~27px on 750px width
    return 20; // Desktop fixed size
  }

  /// Heading text (20px base)
  static double textSizeHeading(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile(context)) return width * 0.053; // ~20px on 375px width
    if (isTablet(context)) return width * 0.040; // ~30px on 750px width
    return 24; // Desktop fixed size
  }

  /// Title text (24px base)
  static double textSizeTitle(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile(context)) return width * 0.064; // ~24px on 375px width
    if (isTablet(context)) return width * 0.048; // ~36px on 750px width
    return 28; // Desktop fixed size
  }

  /// Display text (32px base)
  static double textSizeDisplay(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile(context)) return width * 0.085; // ~32px on 375px width
    if (isTablet(context)) return width * 0.064; // ~48px on 750px width
    return 36; // Desktop fixed size
  }

  // SPECIALIZED SPACING HELPERS (OTP View gibi sayfalar için)

  /// Top safe area spacing (çentik durumuna göre dinamik)
  static double topSafeAreaSpacing(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final safeAreaTop = getTopSafeAreaPadding(context);

    if (isMobileSmall(context)) {
      // iPhone SE gibi küçük cihazlar
      return safeAreaTop + (height * 0.02); // SafeArea + minimum spacing
    } else if (hasDynamicIsland(context)) {
      // Dynamic Island cihazlar (iPhone 14 Pro ve sonrası)
      return safeAreaTop + (height * 0.015); // SafeArea + az spacing
    } else if (hasNotch(context)) {
      // Çentikli cihazlar (iPhone X-13)
      return safeAreaTop + (height * 0.025); // SafeArea + orta spacing
    } else {
      // Standart mobil cihazlar
      return safeAreaTop + (height * 0.035); // SafeArea + normal spacing
    }
  }

  /// Header spacing (Ana sayfa üst kısmı için)
  static double headerTopSpacing(BuildContext context) {
    final safeAreaTop = getTopSafeAreaPadding(context);

    if (isMobileSmall(context)) {
      // iPhone SE: SafeArea + minimum
      return safeAreaTop + 20;
    } else if (hasDynamicIsland(context)) {
      // Dynamic Island cihazlar (iPhone 14 Pro ve sonrası): SafeArea + az
      return safeAreaTop + 15;
    } else if (hasNotch(context)) {
      // Çentikli cihazlar (iPhone X-13): SafeArea + orta
      return safeAreaTop + 12;
    } else {
      // Diğer cihazlar: SafeArea + normal
      return safeAreaTop + 25;
    }
  }

  /// Logo bottom spacing
  static double logoBottomSpacing(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.05; // ~40px on 800px height
  }

  /// Form field spacing
  static double formFieldSpacing(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.02; // ~16px on 800px height
  }

  /// Button top spacing
  static double buttonTopSpacing(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.04; // ~32px on 800px height
  }

  /// Section spacing
  static double sectionSpacing(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.03; // ~24px on 800px height
  }

  /// Content spacing (içerik alanları için)
  static double contentSpacing(BuildContext context) {
    if (isMobileSmall(context)) {
      return 40; // iPhone SE için daha az spacing
    } else if (isMobileLarge(context)) {
      return 60; // Büyük cihazlar için daha fazla
    }
    return 50; // Orta boy cihazlar için standart
  }

  /// Card spacing (kartlar arası boşluk)
  static double cardSpacing(BuildContext context) {
    if (isMobileSmall(context)) {
      return 25; // Küçük cihazlarda daha az
    }
    return 35; // Diğer cihazlarda standart
  }

  /// Bottom sheet spacing
  static double bottomSheetSpacing(BuildContext context) {
    final bottomPadding = getBottomSafeAreaPadding(context);
    return bottomPadding > 0 ? bottomPadding + 16 : 16;
  }

  // WIDGET SIZE HELPERS

  /// Logo width
  static double logoWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width * 0.4; // %40 of screen width
  }

  /// Logo height
  static double logoHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.15; // %15 of screen height
  }

  /// Button height
  static double buttonHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.07; // ~56px on 800px height
  }

  /// Input field height
  static double inputHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height * 0.065; // ~52px on 800px height
  }

  /// Card border radius
  static double cardBorderRadius(BuildContext context) {
    if (isMobile(context)) return 12;
    if (isTablet(context)) return 16;
    return 20; // Desktop
  }

  /// Icon size small
  static double iconSizeSmall(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width * 0.04; // ~15px on 375px width
  }

  /// Icon size medium
  static double iconSizeMedium(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width * 0.06; // ~22px on 375px width
  }

  /// Icon size large
  static double iconSizeLarge(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width * 0.08; // ~30px on 375px width
  }

  /// Icon size extra large
  static double iconSizeExtraLarge(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width * 0.12; // ~38px on 375px width
  }
}

enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

enum MobileScreenType {
  small, // iPhone SE, küçük Android'ler
  medium, // iPhone 12, 13, 14
  large, // iPhone 14 Pro Max, büyük Android'ler
}
