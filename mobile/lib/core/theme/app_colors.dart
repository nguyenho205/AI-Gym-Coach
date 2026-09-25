import 'package:flutter/material.dart';

/// Centralized color palette for AI-Coach-Gym.
/// Built with high-contrast, energetic athletic dark-mode and clean daylight surfaces.
class AppColors {
  AppColors._();

  // Primary Brand Accent (Athletic Electric Cyan & Cyber Teal)
  static const Color primary = Color(0xFF00E5FF);
  static const Color primaryDark = Color(0xFF00B4D8);
  static const Color primaryContainer = Color(0xFF00364A);
  static const Color onPrimary = Color(0xFF001F29);

  // Secondary Brand Accent (Energetic Volt / Jade)
  static const Color secondary = Color(0xFF00F0A8);
  static const Color secondaryDark = Color(0xFF059669);
  static const Color secondaryContainer = Color(0xFF064E3B);
  static const Color onSecondary = Color(0xFF022C22);

  // Tertiary Accent (Warm Amber / Technique Warning)
  static const Color tertiary = Color(0xFFFFB74D);
  static const Color tertiaryContainer = Color(0xFF5D4037);

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successContainer = Color(0xFF064E3B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFF78350F);
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFF7F1D1D);
  static const Color info = Color(0xFF38BDF8);

  // Dark Theme Surfaces (Deep Obsidian & Concentric Slate)
  static const Color darkBackground = Color(0xFF0A0D14);
  static const Color darkSurface = Color(0xFF131722);
  static const Color darkSurfaceElevated = Color(0xFF1A2130);
  static const Color darkSurfaceVariant = Color(0xFF232B3E);
  static const Color darkBorder = Color(0xFF283247);
  static const Color darkBorderSubtle = Color(0xFF1E2638);
  static const Color darkDivider = Color(0xFF1F2837);

  // Dark Text Hierarchy
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Light Theme Surfaces
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightSurfaceVariant = Color(0xFFE2E8F0);
  static const Color lightBorder = Color(0xFFCBD5E1);
  static const Color lightBorderSubtle = Color(0xFFE2E8F0);
  static const Color lightDivider = Color(0xFFE2E8F0);

  // Light Text Hierarchy
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Score Badges / Gradients
  static const Color scoreExcellent = Color(0xFF00F0A8);
  static const Color scoreGood = Color(0xFF00E5FF);
  static const Color scoreModerate = Color(0xFFFFB74D);
  static const Color scoreNeedsWork = Color(0xFFEF4444);
}
