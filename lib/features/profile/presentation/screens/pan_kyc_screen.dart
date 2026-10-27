import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/profile/data/profile_repository.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class PanKycScreen extends ConsumerStatefulWidget {
  const PanKycScreen({super.key});

  @override
  ConsumerState<PanKycScreen> createState() => _PanKycScreenState();
}

class _PanKycScreenState extends ConsumerState<PanKycScreen> {
  final _nameController = TextEditingController();
  final _panController = TextEditingController();
  final _dobController = TextEditingController();
  final _fatherNameController = TextEditingController();

  File? _panFrontFile;
  String? _existingPanFrontUrl;

  bool _isLoading = false;
  bool _isFetching = true;
  String? _status;
  String? _rejectionReason;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadExistingKyc();
  }

  Future<void> _loadExistingKyc() async {
    try {
      final repo = ref.read(profileRepositoryProvider);
      final data = await repo.getKycStatus();
      if (mounted) {
        setState(() {
          _nameController.text = data['full_legal_name'] ?? '';
          _panController.text = data['pan_number'] ?? '';
          _dobController.text = data['dob'] ?? '';
          _fatherNameController.text = data['father_name'] ?? '';
          _existingPanFrontUrl = data['pan_card_front'];
          _status = data['status'];
          _rejectionReason = data['rejection_reason'];
          _isFetching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _panController.dispose();
    _dobController.dispose();
    _fatherNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    DateTime initial = DateTime.now().subtract(const Duration(days: 365 * 18));
    if (_dobController.text.isNotEmpty) {
      try {
        initial = DateTime.parse(_dobController.text.trim());
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.primaryNavy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickPanFrontImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (picked != null) {
      setState(() {
        _panFrontFile = File(picked.path);
      });
    }
  }

  Future<void> _submitPanKyc() async {
    final name = _nameController.text.trim();
    final pan = _panController.text.trim().toUpperCase();
    final dob = _dobController.text.trim();
    final fatherName = _fatherNameController.text.trim();

    if (name.isEmpty) {
      _showToast('Please enter your Full Name as per PAN Card');
      return;
    }
    if (pan.length != 10) {
      _showToast('Please enter a valid 10-character PAN number (e.g. ABCDE1234F)');
      return;
    }
    if (dob.isEmpty) {
      _showToast('Please select your Date of Birth');
      return;
    }
    if (fatherName.isEmpty) {
      _showToast("Please enter your Father's Name");
      return;
    }
    if (_panFrontFile == null && (_existingPanFrontUrl == null || _existingPanFrontUrl!.isEmpty)) {
      _showToast('Please attach the front of your PAN card');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(profileRepositoryProvider);

      String panFrontUrl = _existingPanFrontUrl ?? '';
      if (_panFrontFile != null) {
        panFrontUrl = await repo.uploadKycDocument(_panFrontFile!.path);
      }

      await repo.submitKycDocuments({
        'section': 'pan',
        'full_legal_name': name,
        'pan_number': pan,
        'dob': dob,
        'father_name': fatherName,
        'pan_card_front': panFrontUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('PAN verification details submitted successfully!'),
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

  @override
  Widget build(BuildContext context) {
    final isVerified = _status == 'VERIFIED';
    final isUnderReview = _status == 'UNDER_REVIEW' || _status == 'PENDING';

    return Scaffold(
      appBar: AppBar(
        title: const Text('PAN Card Verification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
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
                          Icon(Icons.credit_card, color: AppTheme.primaryBlue, size: 30),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Section 1: PAN Verification',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primaryNavy),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Provide your PAN card details and upload a clear front photo for legal compliance.',
                                  style: TextStyle(fontSize: 12, color: AppTheme.secondaryText, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_rejectionReason != null && _rejectionReason!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.error, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Rejection note: $_rejectionReason',
                                style: const TextStyle(color: AppTheme.error, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // 1. Full Name
                    const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Full legal name as printed on PAN card',
                      textCapitalization: TextCapitalization.words,
                    ),

                    const SizedBox(height: 18),

                    // 2. PAN Card Number
                    const Text('PAN Card Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _panController,
                      hintText: 'e.g. ABCDE1234F',
                      textCapitalization: TextCapitalization.characters,
                    ),

                    const SizedBox(height: 18),

                    // 3. Date of Birth
                    const Text('Date of Birth (DOB)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDateOfBirth,
                      borderRadius: BorderRadius.circular(12),
                      child: IgnorePointer(
                        child: CustomTextField(
                          controller: _dobController,
                          hintText: 'YYYY-MM-DD',
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 4. Father's Name
                    const Text("Father's Name", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _fatherNameController,
                      hintText: "Father's legal name as per government ID",
                      textCapitalization: TextCapitalization.words,
                    ),

                    const SizedBox(height: 24),

                    // 5. Attach PAN Card Front Only
                    const Text('Attach PAN Card (Front Only)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 4),
                    const Text('Upload a clear, readable photo of the front side of your PAN card.', style: TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
                    const SizedBox(height: 12),

                    InkWell(
                      onTap: _pickPanFrontImage,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (_panFrontFile != null || (_existingPanFrontUrl != null && _existingPanFrontUrl!.isNotEmpty))
                                ? AppTheme.primaryBlue
                                : AppTheme.border,
                            width: 1.5,
                          ),
                        ),
                        child: _panFrontFile != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(_panFrontFile!, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit, color: Colors.white, size: 18),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('Tap to change', style: TextStyle(color: Colors.white, fontSize: 11)),
                                    ),
                                  ),
                                ],
                              )
                            : (_existingPanFrontUrl != null && _existingPanFrontUrl!.isNotEmpty)
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.network(_existingPanFrontUrl!, fit: BoxFit.cover),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.edit, color: Colors.white, size: 18),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.camera_alt_outlined, color: AppTheme.primaryBlue, size: 28),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Upload PAN Card Front',
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.primaryNavy),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'JPG, PNG or PDF up to 5MB',
                                        style: TextStyle(fontSize: 12, color: AppTheme.secondaryText),
                                      ),
                                    ],
                                  ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    PrimaryButton(
                      text: isVerified
                          ? 'PAN Card Verified'
                          : isUnderReview
                              ? 'Update PAN Details'
                              : 'Submit PAN Verification',
                      isLoading: _isLoading,
                      onPressed: _submitPanKyc,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
