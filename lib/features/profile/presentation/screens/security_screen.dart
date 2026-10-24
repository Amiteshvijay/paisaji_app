import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/services/fingerprint_service.dart';
import 'package:zeokash/core/storage/secure_storage.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/features/profile/data/profile_repository.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

final sessionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  return await repo.getSessions();
});

final deviceNameProvider = FutureProvider<String>((ref) async {
  return 'Primary Mobile';
});

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _fingerprintEnabled = false;
  bool _fingerprintAvailable = false;
  bool _hasHardware = false;
  bool _isLoadingBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkFingerprintStatus();
  }

  Future<void> _checkFingerprintStatus() async {
    final fpService = ref.read(fingerprintServiceProvider);
    final storage = ref.read(secureStorageProvider);

    final hasHw = await fpService.hasFingerprintHardware();
    final isAvail = await fpService.isFingerprintAvailable();
    final isEnabled = await storage.getFingerprintEnabled();

    if (mounted) {
      setState(() {
        _hasHardware = hasHw;
        _fingerprintAvailable = isAvail;
        _fingerprintEnabled = isEnabled && isAvail;
      });
    }
  }

  Future<String?> _showMpinDialog({required String title, required String message}) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SecurityMpinBottomSheet(title: title, message: message),
    );
  }

  Future<void> _handleToggleFingerprint(bool value) async {
    if (!_fingerprintAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fingerprint authentication is unavailable or no fingerprints are enrolled on this device.'),
        ),
      );
      return;
    }

    if (value) {
      final mpin = await _showMpinDialog(
        title: 'Enable Fingerprint Unlock',
        message: 'Enter your 4-digit M-PIN to authorize fingerprint security.',
      );
      if (mpin == null || mpin.length != 4) return;

      setState(() => _isLoadingBiometric = true);
      try {
        await ref.read(authControllerProvider.notifier).enableFingerprint(mpin);
        setState(() {
          _fingerprintEnabled = true;
          _isLoadingBiometric = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fingerprint Unlock enabled successfully.'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoadingBiometric = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception:', '').trim()),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } else {
      final mpin = await _showMpinDialog(
        title: 'Disable Fingerprint Unlock',
        message: 'Enter your 4-digit M-PIN to confirm disabling fingerprint security.',
      );
      if (mpin == null || mpin.length != 4) return;

      setState(() => _isLoadingBiometric = true);
      try {
        await ref.read(authControllerProvider.notifier).disableFingerprint(mpin);
        setState(() {
          _fingerprintEnabled = false;
          _isLoadingBiometric = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fingerprint Unlock disabled.')),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoadingBiometric = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception:', '').trim()),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 20.0;
    const double cardMargin = 8.0;

    final authState = ref.watch(authControllerProvider);
    final isMpinSet = authState.isMpinSet;
    final sessionsAsync = ref.watch(sessionsProvider);
    final deviceNameAsync = ref.watch(deviceNameProvider);
    final realDeviceName = deviceNameAsync.asData?.value ?? 'Android Device';

    String fpSubtitle;
    if (!_hasHardware) {
      fpSubtitle = 'Fingerprint sensor unavailable on this device';
    } else if (!_fingerprintAvailable) {
      fpSubtitle = 'No fingerprints enrolled in device settings';
    } else {
      fpSubtitle = _fingerprintEnabled
          ? 'Fingerprint authentication active'
          : 'Unlock Paisaजी securely using your fingerprint';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biometric Security',
              style: TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: cardMargin),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: SwitchListTile(
                secondary: const Icon(Icons.fingerprint, color: AppTheme.primaryNavy, size: 28),
                title: const Text('Fingerprint Unlock', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(fpSubtitle, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                value: _fingerprintEnabled,
                activeThumbColor: AppTheme.primaryBlue,
                onChanged: (_fingerprintAvailable && !_isLoadingBiometric)
                    ? (val) => _handleToggleFingerprint(val)
                    : null,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'MPIN Security',
              style: TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: cardMargin),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  if (!isMpinSet)
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: AppTheme.primaryNavy),
                      title: const Text('Set Up M-PIN', style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: const Text('Configure your 4-digit secure access PIN', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                      onTap: () => context.push('/auth/setup-mpin'),
                    ),
                  if (isMpinSet) ...[
                    ListTile(
                      leading: const Icon(Icons.lock_reset, color: AppTheme.primaryNavy),
                      title: const Text('Change M-PIN', style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: const Text('Update your existing 4-digit PIN', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                      onTap: () => context.push('/profile/security/change-mpin'),
                    ),
                    const Divider(color: AppTheme.border, height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.refresh, color: AppTheme.primaryNavy),
                      title: const Text('Forgot M-PIN?', style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: const Text('Reset via secure mobile OTP', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                      onTap: () => context.push('/auth/mpin-reset-otp'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Manage Registered Device',
              style: TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: cardMargin),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: sessionsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
                ),
                error: (e, s) => _buildDeviceTile(context, realDeviceName, 'Active now', {'device_name': realDeviceName, 'platform': 'ANDROID'}),
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return _buildDeviceTile(context, realDeviceName, 'Active now', {'device_name': realDeviceName, 'platform': 'ANDROID'});
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sessions.length,
                    separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
                    itemBuilder: (context, index) {
                      final s = sessions[index];
                      final devName = s['device_name'] ?? realDeviceName;
                      final platform = s['platform'] ?? 'ANDROID';
                      return ListTile(
                        leading: const Icon(Icons.phone_android, color: AppTheme.primaryNavy),
                        title: Text(devName, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text('$platform • Active now', style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                        trailing: const Text('This Device', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600, fontSize: 12)),
                        onTap: () {
                          context.push('/profile/security/device-info', extra: s);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTile(BuildContext context, String deviceName, String subtitle, Map<String, dynamic> data) {
    return ListTile(
      leading: const Icon(Icons.phone_android, color: AppTheme.primaryNavy),
      title: Text(deviceName, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
      trailing: const Text('This Device', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600, fontSize: 12)),
      onTap: () {
        context.push('/profile/security/device-info', extra: data);
      },
    );
  }
}

class _SecurityMpinBottomSheet extends StatefulWidget {
  final String title;
  final String message;

  const _SecurityMpinBottomSheet({
    required this.title,
    required this.message,
  });

  @override
  State<_SecurityMpinBottomSheet> createState() => _SecurityMpinBottomSheetState();
}

class _SecurityMpinBottomSheetState extends State<_SecurityMpinBottomSheet> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _mpinCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryBlue, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
          ),
          const SizedBox(height: 6),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return SizedBox(
                width: 55,
                height: 58,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  obscureText: true,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                  ),
                  onChanged: (val) {
                    setState(() {});
                    if (val.isNotEmpty && index < 3) {
                      _focusNodes[index + 1].requestFocus();
                    } else if (val.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                    if (_mpinCode.length == 4) {
                      Navigator.of(context).pop(_mpinCode);
                    }
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            text: 'Confirm M-PIN',
            onPressed: () {
              if (_mpinCode.length == 4) {
                Navigator.of(context).pop(_mpinCode);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter 4-digit M-PIN')),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
