/// Centralized spacing, sizing, radii, and breakpoint constants.
class AppDimensions {
  AppDimensions._();

  // ── Breakpoints ──
  static const double mobileMax = 600;
  static const double desktopMin = 1024;

  // ── Max Content Width (desktop centered card) ──
  static const double maxContentWidth = 480;
  static const double maxContentWidthWide = 1200;

  // ── Navigation Rail ──
  static const double sideNavWidth = 72;
  static const double sideNavWidthExpanded = 240;

  // ── Spacing Scale ──
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;

  // ── Border Radii ──
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // ── Icon Sizes ──
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
  static const double iconHero = 48;

  // ── Button / Input Heights ──
  static const double buttonHeight = 52;
  static const double inputHeight = 52;

  // ── Screen Padding ──
  static const double screenPadding = 24;
}
