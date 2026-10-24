import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeokash/core/services/fingerprint_service.dart';
import 'package:zeokash/core/storage/secure_storage.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/features/profile/data/profile_repository.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class MpinLoginScreen extends ConsumerStatefulWidget {
  final String mobileNumber;

  const MpinLoginScreen({
    super.key,
    required this.mobileNumber,
  });

  @override
  ConsumerState<MpinLoginScreen> createState() => _MpinLoginScreenState();
}

class _MpinLoginScreenState extends ConsumerState<MpinLoginScreen> {
  String _fullName = 'Valued Customer';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storage = ref.read(secureStorageProvider);
      final isFpEnabled = await storage.getFingerprintEnabled();
      if (isFpEnabled && ref.read(authControllerProvider).isFingerprintEnabled) {
        _authenticateWithBiometrics();
      }
    });
  }

  Future<void> _loadUserData() async {
    final storage = ref.read(secureStorageProvider);
    String? name = await storage.getFullName();

    if (name == null || name.isEmpty || name == 'Valued Customer') {
      try {
        final profileRepo = ref.read(profileRepositoryProvider);
        final profileData = await profileRepo.getProfile();
        final profileObj = profileData['profile'] ?? profileData;
        name = profileObj['full_name'] ?? profileData['full_name'];
        if (name != null && name.isNotEmpty) {
          await storage.saveFullName(name);
        }
      } catch (_) {}
    }

    if (mounted && name != null && name.isNotEmpty) {
      setState(() {
        _fullName = name!;
      });
    }
  }

  Future<void> _authenticateWithBiometrics({String? pendingRoute}) async {
    if (_isAuthenticating) return;

    final storage = ref.read(secureStorageProvider);
    final isFpEnabled = await storage.getFingerprintEnabled();
    final fpService = ref.read(fingerprintServiceProvider);
    final hasHw = await fpService.hasFingerprintHardware();
    final isAvail = await fpService.isFingerprintAvailable();

    if (!hasHw) {
      _showErrorDialog('Fingerprint sensor hardware is not available on this Android device.');
      return;
    }

    if (!isAvail) {
      _showErrorDialog('No fingerprints are enrolled in your Android device settings. Please add a fingerprint in device settings first.');
      return;
    }

    if (!isFpEnabled) {
      _showSetupFingerprintAlert(pendingRoute: pendingRoute);
      return;
    }

    setState(() => _isAuthenticating = true);
    try {
      final success = await ref.read(authControllerProvider.notifier).unlockWithFingerprint(widget.mobileNumber);
      if (!mounted) return;
      if (success) {
        if (pendingRoute != null) {
          context.push(pendingRoute);
        } else {
          context.go('/home');
        }
      } else {
        final err = ref.read(authControllerProvider).errorMessage ?? 'Fingerprint verification failed. Please check your sensor or use M-PIN.';
        _showErrorDialog(err);
      }
    } catch (e) {
      _showErrorDialog('Fingerprint error: ${e.toString().replaceAll('Exception:', '').trim()}');
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fingerprint Authentication'),
        content: Text(message, style: const TextStyle(color: AppTheme.secondaryText, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            onPressed: () {
              Navigator.pop(ctx);
              _showMpinAuthDialog();
            },
            child: const Text('Use M-PIN Instead'),
          ),
        ],
      ),
    );
  }

  void _showSetupFingerprintAlert({String? pendingRoute}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Up Fingerprint Unlock'),
        content: const Text(
          'Fingerprint unlock is not set up for your account yet. Would you like to set up fingerprint unlock now for instant login?',
          style: TextStyle(color: AppTheme.secondaryText, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showMpinAuthDialog(pendingRoute: pendingRoute);
            },
            child: const Text('Do Later', style: TextStyle(color: AppTheme.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            onPressed: () {
              Navigator.pop(ctx);
              _promptMpinForFingerprintSetup(pendingRoute: pendingRoute);
            },
            child: const Text('Set Up Now'),
          ),
        ],
      ),
    );
  }

  void _promptMpinForFingerprintSetup({String? pendingRoute}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SetupFingerprintMpinBottomSheet(
        mobileNumber: widget.mobileNumber,
        pendingRoute: pendingRoute,
      ),
    );
  }

  void _showMpinAuthDialog({String? pendingRoute}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MpinAuthBottomSheet(
        mobileNumber: widget.mobileNumber,
        pendingRoute: pendingRoute,
        isLogin: true,
      ),
    );
  }

  void _handleServiceTap(String route) {
    _showMpinAuthDialog(pendingRoute: route);
  }

  Future<void> _launchWhatsApp() async {
    const phone = '918860996616';
    final message = Uri.encodeComponent('Hello Paisaजी Support, I need assistance with my account.');
    final url = Uri.parse('https://wa.me/$phone?text=$message');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch WhatsApp support.')),
          );
        }
      }
    } catch (_) {}
  }

  String _formatCustId(String mobile) {
    if (mobile.length >= 4) {
      return 'Cust ID *****${mobile.substring(mobile.length - 4)}';
    }
    return 'Cust ID *****3549';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final custIdText = _formatCustId(widget.mobileNumber);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      floatingActionButton: Semantics(
        label: 'Contact Paisaजी Support on WhatsApp',
        child: FloatingActionButton(
          heroTag: 'whatsapp_support_btn_login',
          onPressed: _launchWhatsApp,
          backgroundColor: Colors.white,
          elevation: 4,
          mini: true,
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF25D366),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Logo / Bank Name (Without Use OTP button)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/branding/paisaji_primary.png',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Greeting & Customer ID
              Text(
                'Hello,',
                style: TextStyle(color: AppTheme.secondaryText, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                _fullName.toUpperCase(),
                style: const TextStyle(color: AppTheme.primaryNavy, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 0.3),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    custIdText,
                    style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.secondaryText),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Access Section (Recharge, Pay Bills, Loan) - Perfectly fitted without overflow
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Frequently used features & special offers',
                      style: TextStyle(color: AppTheme.secondaryText, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildQuickAccessCard(
                            context,
                            icon: Icons.phone_android,
                            label: 'Recharge',
                            onTap: () => _handleServiceTap('/recharge/plans'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildQuickAccessCard(
                            context,
                            icon: Icons.receipt_long,
                            label: 'Pay Bills',
                            onTap: () => _handleServiceTap('/electricity/providers'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildQuickAccessCard(
                            context,
                            icon: Icons.currency_rupee,
                            label: 'Loan',
                            onTap: () => _handleServiceTap('/loan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Login with Fingerprint Button (Prominent)
              PrimaryButton(
                text: 'Login with Fingerprint',
                isLoading: authState.isLoading || _isAuthenticating,
                onPressed: () => _authenticateWithBiometrics(),
              ),
              const SizedBox(height: 16),

              // Bottom Options: Login with MPIN (left) — Forgot MPIN? (right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _showMpinAuthDialog(),
                    child: const Text(
                      'Login with MPIN',
                      style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/auth/mpin-reset-otp', extra: widget.mobileNumber),
                    child: const Text(
                      'Forgot MPIN?',
                      style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Latest Feature Card (Credit Card)
              InkWell(
                onTap: () => context.push('/credit-cards/explore'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.credit_card, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LATEST FEATURE',
                              style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Lifetime Free Credit Card',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Instant approval & high rewards',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.primaryNavy,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MpinAuthBottomSheet extends ConsumerStatefulWidget {
  final String mobileNumber;
  final String? pendingRoute;
  final bool isLogin;

  const _MpinAuthBottomSheet({
    required this.mobileNumber,
    this.pendingRoute,
    this.isLogin = true,
  });

  @override
  ConsumerState<_MpinAuthBottomSheet> createState() => _MpinAuthBottomSheetState();
}

class _MpinAuthBottomSheetState extends ConsumerState<_MpinAuthBottomSheet> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;

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

  Future<void> _verify() async {
    final mpin = _mpinCode;
    if (mpin.length != 4) return;

    setState(() => _isLoading = true);
    try {
      if (widget.isLogin) {
        await ref.read(authControllerProvider.notifier).loginWithMpin(widget.mobileNumber, mpin);
      } else {
        await ref.read(authControllerProvider.notifier).unlockWithMpin(mpin);
      }
      if (mounted) {
        Navigator.pop(context);
        if (widget.pendingRoute != null) {
          context.push(widget.pendingRoute!);
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        for (var c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '').trim()), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
          const Text(
            'Enter M-PIN',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
          ),
          const SizedBox(height: 6),
          const Text(
            'Please enter your 4-digit M-PIN to authorize action.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.secondaryText, fontSize: 13),
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
                      _verify();
                    }
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            text: widget.isLogin ? 'Sign In & Proceed' : 'Verify & Unlock',
            isLoading: _isLoading,
            onPressed: _verify,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SetupFingerprintMpinBottomSheet extends ConsumerStatefulWidget {
  final String mobileNumber;
  final String? pendingRoute;

  const _SetupFingerprintMpinBottomSheet({
    required this.mobileNumber,
    this.pendingRoute,
  });

  @override
  ConsumerState<_SetupFingerprintMpinBottomSheet> createState() => _SetupFingerprintMpinBottomSheetState();
}

class _SetupFingerprintMpinBottomSheetState extends ConsumerState<_SetupFingerprintMpinBottomSheet> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;

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

  Future<void> _verifyAndSetup() async {
    final mpin = _mpinCode;
    if (mpin.length != 4) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).loginWithMpin(widget.mobileNumber, mpin);
      await ref.read(authControllerProvider.notifier).enableFingerprint(mpin);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fingerprint Unlock successfully configured!'),
            backgroundColor: AppTheme.success,
          ),
        );
        if (widget.pendingRoute != null) {
          context.push(widget.pendingRoute!);
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        for (var c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup failed: ${e.toString().replaceAll('Exception:', '').trim()}'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
            child: const Icon(Icons.fingerprint, color: AppTheme.primaryBlue, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'Authorize Fingerprint Setup',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your 4-digit M-PIN first to authorize enabling fingerprint unlock.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.secondaryText, fontSize: 13),
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
                      _verifyAndSetup();
                    }
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            text: 'Verify M-PIN & Enable Fingerprint',
            isLoading: _isLoading,
            onPressed: _verifyAndSetup,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
