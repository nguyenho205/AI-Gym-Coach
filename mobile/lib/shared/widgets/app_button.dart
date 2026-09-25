import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';

/// Primary Island-style interactive button with nested trailing icon chip.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
    this.isOutlined = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.primary : AppColors.primaryDark;
    final defaultFg = isDark ? AppColors.onPrimary : Colors.white;

    final bg = backgroundColor ?? defaultBg;
    final fg = foregroundColor ?? defaultFg;

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: fg,
            side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1.2),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedFull),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: _buildChild(context, isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
        ),
      );
    }

    return Container(
      width: width ?? double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: AppRadius.roundedFull,
        boxShadow: onPressed != null && !isLoading ? AppShadows.glowCyan : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade300,
          disabledForegroundColor: isDark ? AppColors.darkTextMuted : Colors.grey.shade600,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedFull),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          elevation: 0,
        ),
        child: _buildChild(context, fg),
      ),
    );
  }

  Widget _buildChild(BuildContext context, Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: textColor,
            ),
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 10),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              trailingIcon,
              size: 15,
              color: textColor,
            ),
          ),
        ],
      ],
    );
  }
}
