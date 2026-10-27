import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/storage/secure_storage.dart';
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
  bool _isSendingOtp = false;

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _startEmailVerification(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address first')),
      );
      return;
    }

    setState(() => _isSendingOtp = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final res = await repo.sendEmailOtp(cleanEmail);
      if (mounted) {
        final message = res['message'] ?? 'Verification OTP sent to your email!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.primaryNavy,
          ),
        );
        _showOtpBottomSheet(cleanEmail);
      }
    } catch (e) {
      if (mounted) {
        String errMsg = 'Failed to send OTP code: ';
        if (e.toString().contains('already associated')) {
          errMsg = 'This email is already associated with another account.';
        } else if (e.toString().contains('RATE_LIMIT') || e.toString().contains('wait')) {
          errMsg = 'Please wait before requesting another OTP.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errMsg), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  void _showOtpBottomSheet(String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (modalCtx) => _EmailOtpModal(
        email: email,
        onVerified: () {
          ref.invalidate(profileDataProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Email verified successfully!'),
                ],
              ),
              backgroundColor: AppTheme.success,
            ),
          );
        },
      ),
    );
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
          final isEmailVerified = data['is_email_verified'] == true;
          final savedEmail = (data['email'] ?? '').toString();

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
                          const Icon(Icons.check_circle, color: AppTheme.success, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Email Address',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText),
                      ),

                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isEmailVerified ? AppTheme.success.withValues(alpha: 0.4) : AppTheme.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'name@example.com',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                        if (isEmailVerified && savedEmail.isNotEmpty && savedEmail.toLowerCase() == _emailController.text.trim().toLowerCase())
                          const Padding(
                            padding: EdgeInsets.only(right: 14),
                            child: Icon(Icons.verified, color: AppTheme.success, size: 20),
                          )
                        else if (_emailController.text.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: TextButton(
                              onPressed: _isSendingOtp ? null : () => _startEmailVerification(_emailController.text.trim()),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primaryBlue,
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              child: _isSendingOtp
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
                                    )
                                  : const Text('Verify', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!isEmailVerified && _emailController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: Color(0xFFD97706)),
                        const SizedBox(width: 5),
                        Text(
                          'Tap "Verify" to receive a 6-digit OTP on your mail.',
                          style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                        ),
                      ],
                    ),
                  ],
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

class _EmailOtpModal extends ConsumerStatefulWidget {
  final String email;
  final VoidCallback onVerified;

  const _EmailOtpModal({
    required this.email,
    required this.onVerified,
  });

  @override
  ConsumerState<_EmailOtpModal> createState() => _EmailOtpModalState();
}

class _EmailOtpModalState extends ConsumerState<_EmailOtpModal> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  bool _isResending = false;
  int _secondsLeft = 60;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _handlePaste(String pastedText) {
    final digits = pastedText.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 6) {
      final code = digits.substring(0, 6);
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = code[i];
      }
      setState(() {});
      FocusScope.of(context).unfocus();
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpCode.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(profileRepositoryProvider);
      final res = await repo.verifyEmailOtp(widget.email, code);
      if (res['success'] == true) {
        if (mounted) {
          Navigator.pop(context);
          widget.onVerified();
        }
      } else {
        setState(() => _errorMessage = res['error']?['message'] ?? 'Invalid code entered');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Invalid or expired code. Please try again.');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_secondsLeft > 0) return;
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.sendEmailOtp(widget.email);
      _startTimer();
      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A fresh verification code has been sent to your email.')),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to resend code. Please try again.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A0A2342),
              blurRadius: 24,
              offset: Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined, color: AppTheme.primaryBlue, size: 32),
              ),
              const SizedBox(height: 12),
              const Text(
                'Verify Your Email',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 6),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13, height: 1.4),
                  children: [
                    const TextSpan(text: 'Enter the 6-digit code sent to\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

          // 6-digit OTP Inputs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final isFilled = _controllers[index].text.isNotEmpty;
              final isFocused = _focusNodes[index].hasFocus;
              return Container(
                width: 48,
                height: 56,
                decoration: BoxDecoration(
                  color: isFilled ? const Color(0xFFF0F7FF) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isFocused
                        ? AppTheme.primaryBlue
                        : (isFilled ? const Color(0xFF93C5FD) : AppTheme.border),
                    width: isFocused ? 2.0 : 1.2,
                  ),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    cursorColor: AppTheme.primaryBlue,
                    cursorWidth: 2.0,
                    cursorHeight: 24.0,
                    showCursor: true,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      color: AppTheme.primaryNavy,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: (val) {
                      if (val.length > 1) {
                        _handlePaste(val);
                        return;
                      }
                      setState(() {});
                      if (val.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (val.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      if (_otpCode.length == 6) {
                        _verifyOtp();
                      }
                    },
                  ),
                ),
              );
            }),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppTheme.error, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ],

          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Verify & Confirm',
            isLoading: _isVerifying,
            onPressed: _verifyOtp,
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Didn't receive the email? ", style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
              if (_secondsLeft > 0)
                Text(
                  'Resend in ${_secondsLeft}s',
                  style: const TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.bold, fontSize: 13),
                )
              else
                InkWell(
                  onTap: _isResending ? null : _resendOtp,
                  child: _isResending
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
                        )
                      : const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                ),
            ],
          ),
          const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
