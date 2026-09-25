import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';

/// Double-Bezel architectural card container.
/// Uses concentric curves: an outer shell with subtle hairline ring enclosing an inner core container.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool isSelected;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBorder = isSelected
        ? AppColors.primary
        : (borderColor ?? (isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle));

    final shellBg = isDark
        ? (isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.darkSurfaceElevated.withValues(alpha: 0.5))
        : (isSelected ? AppColors.primaryDark.withValues(alpha: 0.08) : AppColors.lightSurfaceElevated);

    final innerBg = backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedCard,
        child: Container(
          decoration: BoxDecoration(
            color: shellBg,
            borderRadius: AppRadius.roundedCard,
            border: Border.all(
              color: defaultBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          padding: const EdgeInsets.all(3.0), // Outer shell padding
          child: Container(
            decoration: BoxDecoration(
              color: innerBg,
              borderRadius: AppRadius.roundedInner,
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
