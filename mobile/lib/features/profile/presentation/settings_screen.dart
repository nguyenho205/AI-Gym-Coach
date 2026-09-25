import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_coach_gym/core/constants/app_constants.dart';
import 'package:ai_coach_gym/core/localization/app_localizations.dart';
import 'package:ai_coach_gym/core/localization/locale_provider.dart';
import 'package:ai_coach_gym/core/network/api_client.dart';
import 'package:ai_coach_gym/core/routing/app_routes.dart';
import 'package:ai_coach_gym/core/storage/local_storage_service.dart';
import 'package:ai_coach_gym/core/theme/app_colors.dart';
import 'package:ai_coach_gym/core/theme/app_spacing.dart';
import 'package:ai_coach_gym/core/theme/app_text_styles.dart';
import 'package:ai_coach_gym/core/theme/theme_provider.dart';
import 'package:ai_coach_gym/shared/widgets/app_button.dart';
import 'package:ai_coach_gym/shared/widgets/app_card.dart';
import 'package:ai_coach_gym/features/auth/presentation/controllers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  void _showApiUrlDialog(BuildContext context) async {
    final localStorage = context.read<LocalStorageService>();
    final currentUrl = await localStorage.getBaseUrl();
    final controller = TextEditingController(text: currentUrl);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('serverUrl')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${context.tr('serverConfig')} (FastAPI Backend)',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'http://localhost:8000/api/v1',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () async {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                await localStorage.setBaseUrl(newUrl);
                if (context.mounted) {
                  context.read<ApiClient>().updateBaseUrl(newUrl);
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settingsTitle'))),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.pagePadding,
          children: [
            // 1. Language Selection Section (English, Tiếng Việt, 中文)
            Text(context.tr('language'), style: AppTextStyles.h3(isDark: isDark)),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _buildLanguageOption(
                    title: 'English',
                    subtitle: 'English (US)',
                    language: AppLanguage.english,
                    currentLanguage: localeProvider.currentLanguage,
                    onTap: () => localeProvider.setLanguage(AppLanguage.english),
                    isDark: isDark,
                  ),
                  const Divider(height: 1),
                  _buildLanguageOption(
                    title: 'Tiếng Việt',
                    subtitle: 'Vietnamese',
                    language: AppLanguage.vietnamese,
                    currentLanguage: localeProvider.currentLanguage,
                    onTap: () => localeProvider.setLanguage(AppLanguage.vietnamese),
                    isDark: isDark,
                  ),
                  const Divider(height: 1),
                  _buildLanguageOption(
                    title: '中文 (简体)',
                    subtitle: 'Simplified Chinese',
                    language: AppLanguage.chinese,
                    currentLanguage: localeProvider.currentLanguage,
                    onTap: () => localeProvider.setLanguage(AppLanguage.chinese),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 2. Appearance Section
            Text(context.tr('appearance'), style: AppTextStyles.h3(isDark: isDark)),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _buildThemeOption(
                    title: '${context.tr('darkMode')} (Athletic Obsidian)',
                    mode: ThemeMode.dark,
                    currentMode: themeProvider.themeMode,
                    onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                    isDark: isDark,
                  ),
                  const Divider(height: 1),
                  _buildThemeOption(
                    title: context.tr('lightMode'),
                    mode: ThemeMode.light,
                    currentMode: themeProvider.themeMode,
                    onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                    isDark: isDark,
                  ),
                  const Divider(height: 1),
                  _buildThemeOption(
                    title: 'Follow System',
                    mode: ThemeMode.system,
                    currentMode: themeProvider.themeMode,
                    onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 3. Notifications Section
            Text('Notifications', style: AppTextStyles.h3(isDark: isDark)),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                value: _notificationsEnabled,
                title: const Text('Workout & Form Reminders'),
                subtitle: const Text('Receive cues and progress milestones'),
                onChanged: (val) {
                  setState(() => _notificationsEnabled = val);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 4. Server Configuration Section
            Text(context.tr('serverConfig'), style: AppTextStyles.h3(isDark: isDark)),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.dns_rounded),
                title: Text(context.tr('serverUrl')),
                subtitle: FutureBuilder<String>(
                  future: context.read<LocalStorageService>().getBaseUrl(),
                  builder: (context, snapshot) => Text(
                    snapshot.data ?? AppConstants.defaultBaseUrl,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                trailing: const Icon(Icons.edit_outlined, size: 20),
                onTap: () => _showApiUrlDialog(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 5. About Section
            Text(context.tr('aboutApp'), style: AppTextStyles.h3(isDark: isDark)),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(context.tr('aboutApp')),
                    subtitle: const Text('Architecture, models & disclaimer'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.code_rounded),
                    title: Text(context.tr('version')),
                    trailing: Text(
                      AppConstants.appVersion,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 6. Sign Out Button
            AppButton(
              label: context.tr('logout'),
              isOutlined: true,
              foregroundColor: AppColors.error,
              icon: Icons.logout_rounded,
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(context.tr('logout')),
                    content: Text(context.tr('logoutConfirm')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(context.tr('cancel')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(context.tr('logout'), style: const TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String subtitle,
    required AppLanguage language,
    required AppLanguage currentLanguage,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final isSelected = language == currentLanguage;
    final primaryColor = isDark ? AppColors.primary : AppColors.primaryDark;

    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: primaryColor)
          : const Icon(Icons.circle_outlined, color: AppColors.darkTextMuted, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildThemeOption({
    required String title,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final isSelected = mode == currentMode;
    final primaryColor = isDark ? AppColors.primary : AppColors.primaryDark;

    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: primaryColor)
          : const Icon(Icons.circle_outlined, color: AppColors.darkTextMuted, size: 20),
      onTap: onTap,
    );
  }
}
