import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_coach_gym/core/localization/app_localizations.dart';
import 'package:ai_coach_gym/core/theme/app_colors.dart';
import 'package:ai_coach_gym/core/theme/app_spacing.dart';
import 'package:ai_coach_gym/core/theme/app_text_styles.dart';
import 'package:ai_coach_gym/core/utils/validators.dart';
import 'package:ai_coach_gym/shared/widgets/app_button.dart';
import 'package:ai_coach_gym/features/auth/presentation/controllers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('success')),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('createAccount')),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('joinGym'),
                    style: AppTextStyles.h1(isDark: isDark),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.tr('heroSubtitle'),
                    style: AppTextStyles.bodyMedium(isDark: isDark),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Error Banner
                  if (authProvider.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                  ],

                  // Full Name
                  TextFormField(
                    key: const Key('register_name_input'),
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: context.tr('fullName'),
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                    ),
                    validator: (v) => Validators.requiredField(v, context.tr('fullName')),
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // Email
                  TextFormField(
                    key: const Key('register_email_input'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: context.tr('email'),
                      prefixIcon: const Icon(Icons.mail_outline_rounded),
                    ),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // Password
                  TextFormField(
                    key: const Key('register_password_input'),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: context.tr('password'),
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // Confirm Password
                  TextFormField(
                    key: const Key('register_confirm_password_input'),
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: context.tr('confirmPassword'),
                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                    ),
                    validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Submit Button
                  AppButton(
                    key: const Key('register_submit_button'),
                    label: context.tr('createAccount'),
                    isLoading: authProvider.isLoading,
                    onPressed: _handleRegister,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr('haveAccount'),
                        style: AppTextStyles.bodyMedium(isDark: isDark),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          context.tr('signIn'),
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
