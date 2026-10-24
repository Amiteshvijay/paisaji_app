import 'package:zeokash/core/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/profile/data/profile_repository.dart';
import 'package:zeokash/features/profile/presentation/screens/profile_screen.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class PersonalDetailsScreen extends ConsumerStatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  ConsumerState<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedGender = 'Male';
  final List<String> _genders = ['Male', 'Female', 'Other'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profileAsync = ref.read(profileDataProvider);
    profileAsync.whenData((data) {
      final profile = data['profile'] ?? {};
      _nameController.text = profile['full_name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _dobController.text = profile['dob'] ?? '';
      _addressController.text = profile['address'] ?? '';
      _selectedGender = profile['gender'] ?? 'Male';
      if (!_genders.contains(_selectedGender)) {
        _selectedGender = 'Male';
      }
    });
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final updatedName = _nameController.text.trim();
      await repo.updateProfile({
        'full_name': updatedName,
        'email': _emailController.text.trim(),
        'dob': _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : null,
        'gender': _selectedGender,
        'address': _addressController.text.trim(),
      });
      if (updatedName.isNotEmpty) {
        await ref.read(secureStorageProvider).saveFullName(updatedName);
      }
      ref.invalidate(profileDataProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personal details updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update personal details')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (error, stackTrace) => const Center(child: Text('Failed to load profile')),
        data: (data) {
          final mobile = data['mobile_number'] ?? '';
          final isMobileVerified = data['is_mobile_verified'] ?? true;
          
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Enter full name',
                  ),
                  const SizedBox(height: 16),
                  const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        isExpanded: true,
                        items: _genders.map((g) {
                          return DropdownMenuItem<String>(
                            value: g,
                            child: Text(g),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedGender = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Date of Birth (YYYY-MM-DD)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _dobController,
                    hintText: 'e.g. 1994-11-13',
                  ),
                  const SizedBox(height: 16),
                  const Text('Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter complete residential address',
                      filled: true,
                      fillColor: AppTheme.surface,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Mobile Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(mobile, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                        if (isMobileVerified)
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: AppTheme.success, size: 16),
                              SizedBox(width: 4),
                              Text('Verified', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Save Changes',
                    isLoading: _isLoading,
                    onPressed: _save,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
