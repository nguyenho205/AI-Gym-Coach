import 'package:flutter/material.dart';
import 'package:ai_coach_gym/core/theme/app_colors.dart';
import 'package:ai_coach_gym/core/theme/app_spacing.dart';
import 'package:ai_coach_gym/core/theme/app_text_styles.dart';
import 'package:ai_coach_gym/core/utils/validators.dart';
import 'package:ai_coach_gym/shared/widgets/app_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: _submitted
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 40),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Check Your Email', style: AppTextStyles.h2(isDark: isDark)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Password reset instructions have been sent to ${_emailController.text}.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium(isDark: isDark),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: 'Return to Sign In',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reset Password', style: AppTextStyles.h1(isDark: isDark)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Enter the email associated with your account and we will send you a reset link.',
                        style: AppTextStyles.bodyMedium(isDark: isDark),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'user@example.com',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                        validator: Validators.email,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: 'Send Reset Link',
                        onPressed: _handleReset,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
