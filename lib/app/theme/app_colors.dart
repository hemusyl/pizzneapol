import 'package:flutter/material.dart';

/// Centralized color palette for PIZZNEAPOL PIZZA app.
/// Matches the reference screenshot with vibrant orange, soft peach tints,
/// and clean modern card contrasts.
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFFF36C0A); // Signature vibrant orange from screenshot
  static const Color primaryDark = Color(0xFFD65800);
  static const Color primaryLight = Color(0xFFFF8533);

  // Tint / Accent Colors
  static const Color primaryPeach = Color(0xFFFFF2E8); // Location bar & badge background
  static const Color primaryPeachLight = Color(0xFFFFF8F3);
  static const Color accentOrange = Color(0xFFFA7921);

  // Background & Surface
  static const Color background = Color(0xFFFAF8F5); // Warm modern off-white background
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF1E1E24); // Bold, high-contrast dark text
  static const Color textSecondary = Color(0xFF7A7A85); // Subtitle & ingredient gray text
  static const Color textLight = Color(0xFFA6A6B0);
  static const Color textWhite = Colors.white;

  // Borders & Dividers
  static const Color borderLight = Color(0xFFEFECE6);
  static const Color borderSelected = Color(0xFFF36C0A); // Category selected border
  static const Color divider = Color(0xFFF0EFEB);

  // Status & Utility Colors
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color starYellow = Color(0xFFFFB800);
  static const Color heartRed = Color(0xFFFF3B30);

  // Shadows
  static const Color shadow = Color(0x0F000000);
}
