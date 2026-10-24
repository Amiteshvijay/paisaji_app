import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/services/otp_autofill_service.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String mobileNumber;

  const OtpVerificationScreen({
    super.key,
    required this.mobileNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> with WidgetsBindingObserver {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  bool _isAutoVerifying = false;
  int _resendCountdown = 60;
  DateTime? _endTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCountdown();
    _startSmsRetriever();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isVerifying) {
      if (_otpCode.length < 6) {
        _startSmsRetriever();
      }
    }
  }

  void _startSmsRetriever() {
    OtpAutofillService().startListening(
      onOtpReceived: (extractedOtp) {
        if (!mounted || _isVerifying) return;
        _populateAndAutoSubmit(extractedOtp);
      },
    );
  }

  void _populateAndAutoSubmit(String code) {
    if (code.length != 6) return;
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = code[i];
    }
    setState(() {
      _isAutoVerifying = true;
    });
    FocusScope.of(context).unfocus();
    _verify();
  }

  void _startCountdown() {
    _timer?.cancel();
    _endTime = DateTime.now().add(const Duration(seconds: 60));
    _resendCountdown = 60;
    
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_endTime != null) {
        final remaining = _endTime!.difference(DateTime.now()).inSeconds;
        final current = remaining > 0 ? remaining : 0;
        if (current != _resendCountdown) {
          setState(() {
            _resendCountdown = current;
          });
        }
        if (current <= 0) {
          timer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    OtpAutofillService().stopListening();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _clearFields() {
    for (var c in _controllers) {
      c.clear();
    }
    if (mounted) {
      _focusNodes[0].requestFocus();
      setState(() {
        _isAutoVerifying = false;
      });
    }
  }

  void _handlePaste(String pastedText) {
    final digits = pastedText.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 6) {
      final code = digits.substring(0, 6);
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = code[i];
      }
      setState(() {});
      FocusScope.of(context).unfocus();
      _verify();
    }
  }

  Future<void> _verify() async {
    if (_isVerifying) return;
    final otp = _otpCode;
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final res = await ref.read(authControllerProvider.notifier).verifyOtp(widget.mobileNumber, otp);

      await OtpAutofillService().stopListening();

      if (mounted) {
        final user = res['user'] as Map<String, dynamic>?;
        final onboardingStatus = user?['onboarding_status'] as String?;
        final nextStep = res['next_step'] as String?;

        if (nextStep == 'ONBOARDING' || onboardingStatus != 'COMPLETED') {
          context.go('/auth/profile-setup');
        } else {
          context.go('/auth/setup-mpin');
        }
      }
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString();
        if (errorStr.contains('DEVICE_CONFLICT') || errorStr.contains('already logged in')) {
          _showDeviceConflictDialog(context);
        } else {
          _clearFields();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid OTP. Please try again.')),
          );
          _startSmsRetriever();
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _isAutoVerifying = false;
        });
      }
    }
  }

  void _showDeviceConflictDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Device Conflict'),
        content: const Text(
          'You are already logged in on another device. Please try logging in with that device. If you lost this device, click below to forget the device now.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/auth/forget-device');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
            child: const Text('Forget Device Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final maskedMobile = widget.mobileNumber.length >= 10
        ? ' ****** '
        : widget.mobileNumber;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.sms_outlined, color: AppTheme.primaryBlue, size: 32),
              ),
              const SizedBox(height: 24),
              Text(
                'Verify your mobile',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ve sent a 6-digit verification code to:\n+91 $maskedMobile',
                style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 12),
              if (_isAutoVerifying)
                Row(
                  children: const [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'SMS detected. Verifying automatically...',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: _controllers[index].text.isNotEmpty ? AppTheme.surface : AppTheme.background,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: _controllers[index].text.isNotEmpty ? AppTheme.primaryBlue : AppTheme.border,
                            width: _controllers[index].text.isNotEmpty ? 2 : 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: _controllers[index].text.isNotEmpty ? AppTheme.primaryBlue : AppTheme.border,
                            width: _controllers[index].text.isNotEmpty ? 2 : 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length > 1) {
                          _handlePaste(value);
                          return;
                        }
                        setState(() {});
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_otpCode.length == 6) {
                          _verify();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _resendCountdown > 0
                        ? null
                        : () async {
                            _clearFields();
                            _startCountdown();
                            _startSmsRetriever();
                            await ref.read(authControllerProvider.notifier).sendOtp(widget.mobileNumber);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('New OTP sent successfully')),
                              );
                            }
                          },
                    child: Text(
                      _resendCountdown > 0 ? 'Resend in ${_resendCountdown}s' : 'Resend OTP',
                      style: TextStyle(
                        color: _resendCountdown > 0 ? AppTheme.secondaryText : AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      OtpAutofillService().stopListening();
                      context.pop();
                    },
                    child: const Text('Change Number', style: TextStyle(color: AppTheme.secondaryText)),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: 'Verify Code',
                isLoading: authState.isLoading || _isVerifying,
                onPressed: _verify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
