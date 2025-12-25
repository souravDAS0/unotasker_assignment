import 'package:flutter/material.dart';

/// Centralized design system for the application.
/// Contains colors, typography, spacing, shadows etc.
/// inspired by unotasker.com's design language.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════
  // COLORS
  // ═══════════════════════════════════════════════════════════════

  /// Background color for the main scaffold (#eae5fa - light purple)
  static const Color backgroundColor = Color(0xFFeae5fa);

  /// Surface color for cards and elevated components
  static const Color surface = Color(0xFFffffff);

  /// Primary brand color - vibrant purple
  static const Color primaryPurple = Color(0xFF6b4ce6);

  /// Accent color - golden yellow (from unotasker.com)
  static const Color accentYellow = Color(0xFFffcc33);

  /// Success color - green (for tracking active state)
  static const Color successGreen = Color(0xFF10b981);

  /// Error color - red (for errors and stop actions)
  static const Color errorRed = Color(0xFFef4444);

  // ─── Purple Shades ────────────────────────────────────────────

  /// Very light purple background
  static const Color purple50 = Color(0xFFf5f3ff);

  /// Light purple - used for hover states and lighter accents
  static const Color purple100 = Color(0xFFe9d5ff);

  /// Medium purple - used for borders
  static const Color purple200 = Color(0xFFc084fc);

  /// Darker purple - used for text on yellow backgrounds
  static const Color purple700 = Color(0xFF7c3aed);

  /// Deep purple from unotasker.com
  static const Color purple900 = Color(0xFF4b2ca0);

  // ─── Gray Shades ──────────────────────────────────────────────

  static const Color gray50 = Color(0xFFfafafa);
  static const Color gray100 = Color(0xFFf4f4f5);
  static const Color gray200 = Color(0xFFe4e4e7);
  static const Color gray300 = Color(0xFFd4d4d8);
  static const Color gray400 = Color(0xFFa1a1aa);
  static const Color gray600 = Color(0xFF52525b);
  static const Color gray700 = Color(0xFF3f3f46);
  static const Color gray800 = Color(0xFF27272a);
  static const Color gray900 = Color(0xFF18181b);

  // ─── Additional Colors ────────────────────────────────────────

  /// Lighter shade of success green
  static const Color green400 = Color(0xFF34d399);

  /// Lighter shade of error red
  static const Color red400 = Color(0xFFf87171);

  /// Pink color for location icon
  static const Color pink500 = Color(0xFFec4899);

  // ═══════════════════════════════════════════════════════════════
  // TYPOGRAPHY
  // ═══════════════════════════════════════════════════════════════

  /// Display large - for main page titles (36px, weight 800)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: gray900,
    letterSpacing: 0.5,
  );

  /// Heading large - for section headers (24px, weight 700)
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: gray900,
  );

  /// Heading medium - for card titles (20px, weight 600)
  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: gray900,
  );

  /// Heading small - for subheadings (16px, weight 600)
  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: gray900,
  );

  /// Body large - primary content (16px, weight 400)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: gray800,
    height: 1.5,
  );

  /// Body medium - secondary content (15px, weight 400)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: gray700,
    height: 1.5,
  );

  /// Body small - tertiary content (14px, weight 400)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: gray700,
  );

  /// Label large - button labels (16px, weight 600)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: surface,
  );

  /// Label medium - form labels (14px, weight 500)
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: gray700,
  );

  /// Label small - metadata (12px, weight 500)
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: gray600,
  );

  /// Caption - very small text (13px, weight 600)
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: purple700,
  );

  // ═══════════════════════════════════════════════════════════════
  // SPACING
  // ═══════════════════════════════════════════════════════════════

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ═══════════════════════════════════════════════════════════════
  // BORDER RADIUS
  // ═══════════════════════════════════════════════════════════════

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusPill = 999.0;

  // ═══════════════════════════════════════════════════════════════
  // SHADOWS
  // ═══════════════════════════════════════════════════════════════

  /// Low elevation shadow for subtle depth
  static List<BoxShadow> get lowElevation => [
    const BoxShadow(
      color: Color(0x1A000000), // 10% black
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Medium elevation shadow for cards and buttons
  static List<BoxShadow> get mediumElevation => [
    const BoxShadow(
      color: Color(0x1F000000), // 12% black
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// High elevation shadow for modals and overlays
  static List<BoxShadow> get highElevation => [
    const BoxShadow(
      color: Color(0x26000000), // 15% black
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// Purple glow shadow for accent elements
  static List<BoxShadow> get purpleGlow => [
    BoxShadow(
      color: primaryPurple.withValues(alpha: 0.3),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Green glow shadow for success states
  static List<BoxShadow> get greenGlow => [
    BoxShadow(
      color: successGreen.withValues(alpha: 0.3),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Red glow shadow for error/stop states
  static List<BoxShadow> get redGlow => [
    BoxShadow(
      color: errorRed.withValues(alpha: 0.3),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════

  /// Purple gradient for start button
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [primaryPurple, Color(0xFF9b84f5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Green gradient for active tracking status
  static const LinearGradient greenGradient = LinearGradient(
    colors: [successGreen, green400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Red gradient for stop button
  static const LinearGradient redGradient = LinearGradient(
    colors: [errorRed, red400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS
  // ═══════════════════════════════════════════════════════════════

  static const Duration fastAnimation = Duration(milliseconds: 100);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // ═══════════════════════════════════════════════════════════════
  // COMMON DECORATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Standard card decoration with white background and shadow
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: lowElevation,
  );

  /// Glass effect decoration for modern cards
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusLarge),
    border: Border.all(color: surface.withValues(alpha: 0.8), width: 1),
    boxShadow: lowElevation,
  );

  /// Pill-shaped badge decoration
  static BoxDecoration pillDecoration(Color backgroundColor) => BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(radiusPill),
  );
}
