import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_coach_gym/core/localization/app_localizations.dart';
import 'package:ai_coach_gym/core/localization/locale_provider.dart';
import 'package:ai_coach_gym/core/routing/app_routes.dart';
import 'package:ai_coach_gym/core/theme/app_colors.dart';
import 'package:ai_coach_gym/core/theme/app_spacing.dart';
import 'package:ai_coach_gym/core/theme/app_text_styles.dart';
import 'package:ai_coach_gym/core/utils/validators.dart';
import 'package:ai_coach_gym/shared/widgets/app_button.dart';
import 'package:ai_coach_gym/features/auth/presentation/controllers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<AppLanguage>(
            tooltip: context.tr('language'),
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language_rounded, size: 20),
                const SizedBox(width: 4),
                Text(
                  localeProvider.currentLanguage.displayName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
              ],
            ),
            onSelected: (lang) => localeProvider.setLanguage(lang),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: AppLanguage.english,
                child: Text('English'),
              ),
              const PopupMenuItem(
                value: AppLanguage.vietnamese,
                child: Text('Tiếng Việt'),
              ),
              const PopupMenuItem(
                value: AppLanguage.chinese,
                child: Text('中文 (简体)'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon Chip
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.primary : AppColors.primaryDark).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isDark ? AppColors.primary : AppColors.primaryDark).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: isDark ? AppColors.primary : AppColors.primaryDark,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    context.tr('welcomeBack'),
                    style: AppTextStyles.hero(isDark: isDark),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.tr('loginTitle'),
                    style: AppTextStyles.bodyMedium(isDark: isDark),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Error notification banner if any
                  if (authProvider.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                  ],

                  // Email Input
                  TextFormField(
                    key: const Key('login_email_input'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: context.tr('email'),
                      hintText: 'demo@gymcoach.ai',
                      prefixIcon: const Icon(Icons.mail_outline_rounded),
                    ),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // Password Input
                  TextFormField(
                    key: const Key('login_password_input'),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    decoration: InputDecoration(
                      labelText: context.tr('password'),
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => Validators.requiredField(v, context.tr('password')),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Sign In Action Button
                  AppButton(
                    key: const Key('login_submit_button'),
                    label: context.tr('signIn'),
                    isLoading: authProvider.isLoading,
                    trailingIcon: Icons.arrow_forward_rounded,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Register Alternative
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr('noAccount'),
                        style: AppTextStyles.bodyMedium(isDark: isDark),
                      ),
                      TextButton(
                        key: const Key('login_to_register_button'),
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                        child: Text(
                          context.tr('signUp'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.primary : AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
