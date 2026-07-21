import 'package:flutter/material.dart';

/// Centralized color palette extracted from Navojit Tech design mockups.
/// Never hardcode colors in widget files — always reference these tokens.
class AppColors {
  AppColors._();

  // ── Primary Palette ──
  static const Color primaryDark = Color(0xFF0A1628);
  static const Color primaryDarkAlt = Color(0xFF0F2847);
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color primaryBlueLight = Color(0xFF1E88E5);
  static const Color primaryBlueDark = Color(0xFF0D47A1);

  // ── Accent / Teal ──
  static const Color accentTeal = Color(0xFF26A69A);
  static const Color accentTealLight = Color(0xFF4DB6AC);

  // ── Surfaces ──
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F7FA);
  static const Color surfaceLightBlue = Color(0xFFEBF2FC);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  // ── Text ──
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkSecondary = Color(0xFFB0BEC5);
  static const Color textLink = Color(0xFF1565C0);

  // ── Borders ──
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderFocus = Color(0xFF1565C0);

  // ── Semantic ──
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningAmber = Color(0xFFFFC107);
  static const Color errorRed = Color(0xFFEF5350);
  static const Color infoBlueBg = Color(0xFFE3F2FD);

  // ── Gradients ──
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, primaryDarkAlt],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryBlueLight],
  );

  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceWhite, surfaceLight],
  );

  // ── Shadows ──
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primaryBlue.withAlpha(20),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(13),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
