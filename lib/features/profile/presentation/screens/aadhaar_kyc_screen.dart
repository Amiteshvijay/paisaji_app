import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/profile/data/profile_repository.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class AadhaarKycScreen extends ConsumerStatefulWidget {
  const AadhaarKycScreen({super.key});

  @override
  ConsumerState<AadhaarKycScreen> createState() => _AadhaarKycScreenState();
}

class _AadhaarKycScreenState extends ConsumerState<AadhaarKycScreen> {
  final _aadhaarController = TextEditingController();
  final _otpController = TextEditingController();

  File? _aadhaarFrontFile;
  File? _aadhaarBackFile;
  String? _existingFrontUrl;
  String? _existingBackUrl;

  bool _otpSent = false;
  bool _isAadhaarVerified = false;
  bool _isLoading = false;
  bool _isFetching = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadExistingAadhaar();
  }

  Future<void> _loadExistingAadhaar() async {
    try {
      final repo = ref.read(profileRepositoryProvider);
      final data = await repo.getKycStatus();
      if (mounted) {
        setState(() {
          _aadhaarController.text = data['aadhaar_number'] ?? '';
          _existingFrontUrl = data['aadhaar_front'];
          _existingBackUrl = data['aadhaar_back'];
          _isAadhaarVerified = data['is_aadhaar_verified'] == true;
          _isFetching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (picked != null) {
      setState(() {
        if (type == 'front') _aadhaarFrontFile = File(picked.path);
        if (type == 'back') _aadhaarBackFile = File(picked.path);
      });
    }
  }

  Future<void> _sendOtp() async {
    final cleanAadhaar = _aadhaarController.text.trim().replaceAll(' ', '');
    if (cleanAadhaar.length != 12) {
      _showToast('Please enter a valid 12-digit Aadhaar number');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to Aadhaar-registered mobile number (Demo OTP: 123456)'),
          backgroundColor: AppTheme.primaryBlue,
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showToast('Please enter the 6-digit OTP received on your mobile');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isAadhaarVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Aadhaar verified successfully! Please attach documents below.'),
            ],
          ),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  Future<void> _submitAadhaarDocuments() async {
    final cleanAadhaar = _aadhaarController.text.trim().replaceAll(' ', '');
    if (cleanAadhaar.length != 12) {
      _showToast('Please enter a valid 12-digit Aadhaar number');
      return;
    }
    if (!_isAadhaarVerified) {
      _showToast('Please request and verify the Aadhaar OTP first');
      return;
    }
    if (_aadhaarFrontFile == null && (_existingFrontUrl == null || _existingFrontUrl!.isEmpty)) {
      _showToast('Please attach the front photo of your Aadhaar card');
      return;
    }
    if (_aadhaarBackFile == null && (_existingBackUrl == null || _existingBackUrl!.isEmpty)) {
      _showToast('Please attach the back photo of your Aadhaar card');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(profileRepositoryProvider);

      String frontUrl = _existingFrontUrl ?? '';
      if (_aadhaarFrontFile != null) {
        frontUrl = await repo.uploadKycDocument(_aadhaarFrontFile!.path);
      }

      String backUrl = _existingBackUrl ?? '';
      if (_aadhaarBackFile != null) {
        backUrl = await repo.uploadKycDocument(_aadhaarBackFile!.path);
      }

      await repo.submitKycDocuments({
        'section': 'aadhaar',
        'aadhaar_number': cleanAadhaar,
        'aadhaar_front': frontUrl,
        'aadhaar_back': backUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Aadhaar details and documents submitted successfully!'),
              ],
            ),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showToast('Submission error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.error),
    );
  }

  Widget _buildDocBox({
    required String title,
    required String subtitle,
    required File? file,
    required String? existingUrl,
    required VoidCallback onTap,
  }) {
    final hasImage = file != null || (existingUrl != null && existingUrl.isNotEmpty);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? AppTheme.primaryBlue : AppTheme.border,
            width: 1.5,
          ),
        ),
        child: file != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(file, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              )
            : (existingUrl != null && existingUrl.isNotEmpty)
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(existingUrl, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_upload_outlined, color: AppTheme.primaryBlue, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryNavy)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.secondaryText)),
                    ],
                  ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UIDAI Aadhaar Verification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Guidance Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.fingerprint, color: AppTheme.primaryBlue, size: 30),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Section 2: Aadhaar Verification',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primaryNavy),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Enter Aadhaar number, complete mobile OTP authentication, and attach front and back documents.',
                                  style: TextStyle(fontSize: 12, color: AppTheme.secondaryText, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 1. Enter Aadhaar Number
                    const Text('Enter Aadhaar Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _aadhaarController,
                      hintText: '12-digit Aadhaar number',
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 16),

                    // 2. OTP Verification Box
                    if (_isAadhaarVerified) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: AppTheme.success, size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Aadhaar identity verified via UIDAI OTP',
                                style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      if (_otpSent) ...[
                        const Text('Enter OTP', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _otpController,
                                hintText: '6-digit OTP',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _verifyOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Verify OTP', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _isLoading ? null : _sendOtp,
                          child: const Text('Resend OTP', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12)),
                        ),
                      ] else ...[
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _sendOtp,
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: _isLoading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Request Aadhaar OTP'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryBlue,
                            side: const BorderSide(color: AppTheme.primaryBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 28),

                    // 3. Attach Front and Back of Aadhaar Document
                    const Text('Attach Aadhaar Document (Front & Back)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 4),
                    const Text('Attach clear, legible photos of both sides of your Aadhaar card.', style: TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _buildDocBox(
                            title: 'Front Side',
                            subtitle: 'Upload photo',
                            file: _aadhaarFrontFile,
                            existingUrl: _existingFrontUrl,
                            onTap: () => _pickImage('front'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildDocBox(
                            title: 'Back Side',
                            subtitle: 'Upload photo',
                            file: _aadhaarBackFile,
                            existingUrl: _existingBackUrl,
                            onTap: () => _pickImage('back'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    PrimaryButton(
                      text: 'Submit Aadhaar Verification',
                      isLoading: _isLoading,
                      onPressed: _submitAadhaarDocuments,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
