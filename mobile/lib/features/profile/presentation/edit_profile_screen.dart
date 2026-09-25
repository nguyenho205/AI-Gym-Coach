import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_coach_gym/core/localization/app_localizations.dart';
import 'package:ai_coach_gym/core/theme/app_colors.dart';
import 'package:ai_coach_gym/core/theme/app_spacing.dart';
import 'package:ai_coach_gym/core/theme/app_text_styles.dart';
import 'package:ai_coach_gym/core/utils/validators.dart';
import 'package:ai_coach_gym/shared/widgets/app_button.dart';
import 'package:ai_coach_gym/features/auth/data/models/user_model.dart';
import 'package:ai_coach_gym/features/auth/presentation/controllers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String _gender = 'Male';

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _heightController = TextEditingController(
      text: user?.heightCm != null ? user!.heightCm!.round().toString() : '',
    );
    _weightController = TextEditingController(
      text: user?.weightKg != null ? user!.weightKg!.round().toString() : '',
    );
    _gender = (user?.gender != null && user!.gender!.isNotEmpty) ? user.gender! : 'Male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    final updated = (currentUser ?? const UserModel(id: 1, fullName: '', email: '')).copyWith(
      fullName: _nameController.text.trim(),
      heightCm: double.tryParse(_heightController.text.trim()),
      weightKg: double.tryParse(_weightController.text.trim()),
      gender: _gender,
    );

    final success = await authProvider.updateProfile(updated);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('profileUpdated')),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('editProfile'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('athleteDetails'), style: AppTextStyles.h2(isDark: isDark)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.tr('physicalMetricsHelp'),
                  style: AppTextStyles.bodyMedium(isDark: isDark),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: context.tr('fullName'),
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) => Validators.requiredField(v, context.tr('fullName')),
                ),
                const SizedBox(height: AppSpacing.base),

                // Height (cm)
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '${context.tr('height')} (cm)',
                    hintText: 'e.g. 175',
                    prefixIcon: const Icon(Icons.height_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.base),

                // Weight (kg)
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '${context.tr('weight')} (kg)',
                    hintText: 'e.g. 70',
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.base),

                // Gender Selector
                DropdownButtonFormField<String>(
                  initialValue: ['Male', 'Female', 'Other'].contains(_gender) ? _gender : 'Male',
                  decoration: InputDecoration(
                    labelText: context.tr('gender'),
                    prefixIcon: const Icon(Icons.wc_rounded),
                  ),
                  items: [
                    DropdownMenuItem(value: 'Male', child: Text(context.tr('male'))),
                    DropdownMenuItem(value: 'Female', child: Text(context.tr('female'))),
                    DropdownMenuItem(value: 'Other', child: Text(context.tr('otherGender'))),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _gender = val);
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Save Changes Button
                AppButton(
                  label: context.tr('save'),
                  isLoading: auth.isLoading,
                  icon: Icons.check_rounded,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
