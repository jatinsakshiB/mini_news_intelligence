class AppAssets {
  AppAssets._();

  static const String logoDark = 'assets/images/logo-dark.png';
  static const String logoLight = 'assets/images/logo.png';

  /// Returns the appropriate logo for current theme:
  /// - In Light Theme: returns `logoDark` (black letters for light backgrounds)
  /// - In Dark Theme: returns `logoLight` (white letters for dark backgrounds)
  static String getLogo({required bool isDark}) {
    return isDark ? logoLight : logoDark;
  }
}
