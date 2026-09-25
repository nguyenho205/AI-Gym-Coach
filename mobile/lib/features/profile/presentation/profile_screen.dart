import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_coach_gym/core/localization/app_localizations.dart';
import 'package:ai_coach_gym/core/routing/app_routes.dart';
import 'package:ai_coach_gym/core/theme/app_colors.dart';
import 'package:ai_coach_gym/core/theme/app_spacing.dart';
import 'package:ai_coach_gym/core/theme/app_text_styles.dart';
import 'package:ai_coach_gym/shared/widgets/app_button.dart';
import 'package:ai_coach_gym/shared/widgets/app_card.dart';
import 'package:ai_coach_gym/features/auth/presentation/controllers/auth_provider.dart';
import 'package:ai_coach_gym/features/history/presentation/controllers/history_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final history = context.watch<HistoryProvider>();
    final user = auth.currentUser;

    // Real dynamic user profile fields
    final String name = (user != null && user.fullName.trim().isNotEmpty)
        ? user.fullName
        : (user != null && user.email.trim().isNotEmpty)
            ? user.email.split('@').first
            : context.tr('notSet');

    final String email = (user != null && user.email.trim().isNotEmpty)
        ? user.email
        : context.tr('notSet');

    final totalSessions = history.items.length;
    final hasHistory = history.items.isNotEmpty;
    final int avgScore = hasHistory
        ? (history.items.fold<int>(0, (sum, item) => sum + (item.result?.score ?? item.score)) ~/ history.items.length)
        : 0;

    final heightDisplay = user?.heightCm != null ? '${user!.heightCm!.round()} cm' : '--';
    final weightDisplay = user?.weightKg != null ? '${user!.weightKg!.round()} kg' : '--';
    final genderDisplay = (user?.gender != null && user!.gender!.isNotEmpty) ? user.gender! : context.tr('notSet');

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('profileTitle')),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: context.tr('navSettings'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              // Avatar Enclosure with real initial
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.primary : AppColors.primaryDark,
                    width: 2.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.primary : AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(name, style: AppTextStyles.h2(isDark: isDark)),
              const SizedBox(height: 2),
              Text(email, style: AppTextStyles.bodyMedium(isDark: isDark)),
              const SizedBox(height: AppSpacing.lg),

              // Edit Profile Button
              AppButton(
                label: context.tr('editProfile'),
                isOutlined: true,
                width: 170,
                icon: Icons.edit_outlined,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.editProfile);
                },
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Physical & Workout Stats Cards (Real Metrics)
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(heightDisplay, style: AppTextStyles.h2(isDark: isDark)),
                          const SizedBox(height: 2),
                          Text(context.tr('height'), style: AppTextStyles.bodySmall(isDark: isDark)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(weightDisplay, style: AppTextStyles.h2(isDark: isDark)),
                          const SizedBox(height: 2),
                          Text(context.tr('weight'), style: AppTextStyles.bodySmall(isDark: isDark)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(genderDisplay, style: AppTextStyles.h3(isDark: isDark)),
                          const SizedBox(height: 2),
                          Text(context.tr('gender'), style: AppTextStyles.bodySmall(isDark: isDark)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Workout History Summary Card (Real Data)
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('$totalSessions', style: AppTextStyles.metricValue(isDark: isDark)),
                        const SizedBox(height: 4),
                        Text(context.tr('sessionsLogged'), style: AppTextStyles.bodySmall(isDark: isDark)),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    Column(
                      children: [
                        Text(
                          hasHistory ? '$avgScore' : '--',
                          style: AppTextStyles.metricValue(isDark: isDark).copyWith(
                            color: isDark ? AppColors.secondary : AppColors.secondaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(context.tr('averageForm'), style: AppTextStyles.bodySmall(isDark: isDark)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Language Quick Selector in Profile
              AppCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(context.tr('language')),
                  subtitle: Text(AppLocalizations.of(context).locale.languageCode == 'vi'
                      ? 'Tiếng Việt'
                      : AppLocalizations.of(context).locale.languageCode == 'zh'
                          ? '中文 (简体)'
                          : 'English'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.settings);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Sign Out Button
              AppButton(
                label: 'Sign Out',
                isOutlined: true,
                foregroundColor: AppColors.error,
                icon: Icons.logout_rounded,
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
