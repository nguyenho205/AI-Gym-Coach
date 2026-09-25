import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized typographic scale for AI Gym Coach.
class AppTextStyles {
  AppTextStyles._();

  // Eyebrow Tag Style (as requested in Taste Skill)
  static TextStyle eyebrow({bool isDark = true}) => TextStyle(
        fontSize: 11.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: isDark ? AppColors.primary : AppColors.primaryDark,
      );

  // Large Hero Headings
  static TextStyle hero({bool isDark = true}) => TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.15,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle h1({bool isDark = true}) => TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle h2({bool isDark = true}) => TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.25,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle h3({bool isDark = true}) => TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  // Body Styles
  static TextStyle bodyLarge({bool isDark = true}) => TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        height: 1.5,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle bodyMedium({bool isDark = true}) => TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.45,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      );

  static TextStyle bodySmall({bool isDark = true}) => TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.4,
        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
      );

  // Metrics / Numbers
  static TextStyle metricValue({bool isDark = true}) => TextStyle(
        fontSize: 36.0,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.0,
        height: 1.1,
        color: isDark ? AppColors.primary : AppColors.primaryDark,
      );

  static TextStyle scoreNumber({bool isDark = true}) => TextStyle(
        fontSize: 56.0,
        fontWeight: FontWeight.w900,
        letterSpacing: -2.0,
        height: 1.0,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  // Button Labels
  static const TextStyle button = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    height: 1.2,
  );
}
