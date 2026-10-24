import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class EnableFingerprintScreen extends ConsumerStatefulWidget {
  final String? initialMpin;
  const EnableFingerprintScreen({super.key, this.initialMpin});

  @override
  ConsumerState<EnableFingerprintScreen> createState() => _EnableFingerprintScreenState();
}

class _EnableFingerprintScreenState extends ConsumerState<EnableFingerprintScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleEnableFingerprint() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? mpin = widget.initialMpin;
      if (mpin == null || mpin.isEmpty) {
        mpin = await _showMpinDialog();
        if (mpin == null || mpin.isEmpty) {
          setState(() => _isLoading = false);
          return;
        }
      }

      await ref.read(authControllerProvider.notifier).enableFingerprint(mpin);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fingerprint Unlock enabled successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '').trim();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _showMpinDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify M-PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your 4-digit M-PIN to enable biometric unlock.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: '4-digit M-PIN',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Security', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  size: 44,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Enable Fingerprint Unlock',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryNavy,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Unlock Paisaजी faster and more securely using your device\'s fingerprint sensor.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Feature Benefits Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    _buildBenefitRow(
                      Icons.flash_on_outlined,
                      'Instant Access',
                      'Unlock in seconds without typing your MPIN each time.',
                    ),
                    const Divider(height: 20, color: AppTheme.border),
                    _buildBenefitRow(
                      Icons.security_outlined,
                      'Keystore-Backed Security',
                      'Secured with hardware-backed cryptographic challenge signing.',
                    ),
                    const Divider(height: 20, color: AppTheme.border),
                    _buildBenefitRow(
                      Icons.pin_outlined,
                      'MPIN Always Available',
                      'Your 4-digit MPIN remains available as an instant fallback.',
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppTheme.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Enable Fingerprint Unlock',
                isLoading: _isLoading,
                onPressed: _handleEnableFingerprint,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isLoading ? null : () => context.go('/home'),
                child: const Text(
                  'Skip for Now',
                  style: TextStyle(
                    color: AppTheme.secondaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
