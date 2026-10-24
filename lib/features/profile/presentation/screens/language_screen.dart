import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/profile/data/profile_repository.dart';
import 'package:zeokash/features/profile/presentation/screens/profile_screen.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String _selectedLang = 'en';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profileAsync = ref.read(profileDataProvider);
    profileAsync.whenData((data) {
      setState(() {
        _selectedLang = data['preferred_language'] ?? 'en';
      });
    });
  }

  Future<void> _saveLanguage(String lang) async {
    setState(() {
      _selectedLang = lang;
      _isLoading = true;
    });

    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.updateProfile({'preferred_language': lang});
      ref.invalidate(profileDataProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang == 'hi' ? 'भाषा हिंदी में बदल दी गई' : 'Language updated to English')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update language')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 20.0;
    const double cardMargin = 8.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select App Language', style: TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: cardMargin),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: RadioGroup<String>(
                groupValue: _selectedLang,
                onChanged: (val) {
                  if (val != null) _saveLanguage(val);
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('English', style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: const Text('Default international', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                      value: 'en',
                      activeColor: AppTheme.primaryBlue,
                    ),
                    const Divider(color: AppTheme.border, height: 1, indent: 16),
                    RadioListTile<String>(
                      title: const Text('हिंदी', style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: const Text('Indian regional', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                      value: 'hi',
                      activeColor: AppTheme.primaryBlue,
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
            ],
          ],
        ),
      ),
    );
  }
}