import 'package:zeokash/core/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/profile/data/profile_repository.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  
  String? _selectedSex;
  String? _selectedEmploymentType;
  bool _isLoading = false;

  final List<Map<String, String>> _sexOptions = [
    {'label': 'Male', 'value': 'MALE'},
    {'label': 'Female', 'value': 'FEMALE'},
    {'label': 'Other', 'value': 'OTHER'},
    {'label': 'Prefer Not To Say', 'value': 'PREFER_NOT_TO_SAY'},
  ];

  final List<Map<String, String>> _employmentOptions = [
    {'label': 'Salaried', 'value': 'SALARIED'},
    {'label': 'Self-Employed', 'value': 'SELF_EMPLOYED'},
    {'label': 'Business', 'value': 'BUSINESS'},
    {'label': 'Student', 'value': 'STUDENT'},
    {'label': 'Other', 'value': 'OTHER'},
  ];

  Future<void> _selectDob(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year;
      setState(() {
        _dobController.text = '$day/$month/$year';
      });
    }
  }

  Future<void> _completeSetup() async {
    final name = _nameController.text.trim();
    final dob = _dobController.text.trim();

    if (name.isEmpty || dob.isEmpty || _selectedSex == null || _selectedEmploymentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all required profile details'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      await profileRepo.completeOnboarding({
        'full_name': name,
        'sex': _selectedSex,
        'dob': dob,
        'employment_type': _selectedEmploymentType,
      });
      await ref.read(secureStorageProvider).saveFullName(name);

      if (mounted) {
        final isMpinSet = ref.read(authControllerProvider).isMpinSet;
        if (isMpinSet) {
          context.go('/home');
        } else {
          context.go('/auth/setup-mpin');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete onboarding: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New User Onboarding'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person_outline, color: AppTheme.primaryBlue, size: 32),
              ),
              const SizedBox(height: 24),
              Text(
                'Tell us about yourself',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please provide your details to complete your fintech account setup.',
                style: TextStyle(color: AppTheme.secondaryText, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Enter your full name',
                    ),
                    const SizedBox(height: 16),
                    const Text('Sex / Gender', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSex,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      hint: const Text('Select sex'),
                      items: _sexOptions.map((opt) {
                        return DropdownMenuItem<String>(
                          value: opt['value'],
                          child: Text(opt['label']!),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedSex = val),
                    ),
                    const SizedBox(height: 16),
                    const Text('Date of Birth (DD/MM/YYYY)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDob(context),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          controller: _dobController,
                          hintText: 'DD/MM/YYYY',
                          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20, color: AppTheme.primaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Employment Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedEmploymentType,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      hint: const Text('Select employment type'),
                      items: _employmentOptions.map((opt) {
                        return DropdownMenuItem<String>(
                          value: opt['value'],
                          child: Text(opt['label']!),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedEmploymentType = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: 'Complete Onboarding',
                isLoading: _isLoading,
                onPressed: _completeSetup,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
