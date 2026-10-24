import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/wallet/data/wallet_model.dart';
import 'package:zeokash/features/wallet/data/wallet_repository.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class SubmitEvidenceScreen extends ConsumerStatefulWidget {
  final WalletTopup topup;

  const SubmitEvidenceScreen({
    super.key,
    required this.topup,
  });

  @override
  ConsumerState<SubmitEvidenceScreen> createState() => _SubmitEvidenceScreenState();
}

class _SubmitEvidenceScreenState extends ConsumerState<SubmitEvidenceScreen> {
  final TextEditingController _utrController = TextEditingController();
  XFile? _screenshot;
  bool _isLoading = false;

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Upload Screenshot', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryBlue),
              title: Text('Choose from Gallery', style: GoogleFonts.outfit(fontSize: 15)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryBlue),
              title: Text('Take Photo with Camera', style: GoogleFonts.outfit(fontSize: 15)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() => _screenshot = picked);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select image: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    final utr = _utrController.text.trim();
    if (utr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 12-digit UTR / UPI Reference Number')),
      );
      return;
    }

    if (_screenshot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach payment screenshot')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(walletRepositoryProvider);
      final updatedTopup = await repo.submitEvidence(widget.topup.id, utr, _screenshot!.path);
      if (mounted) {
        context.pushReplacement('/wallet/topups/pending', extra: updatedTopup);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit evidence: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final refCode = widget.topup.reference ?? 'ZKT${widget.topup.id.substring(0, 8).toUpperCase()}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Payment Details', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Top-up Amount', style: GoogleFonts.outfit(color: AppTheme.secondaryText, fontSize: 13)),
                        Text('?${widget.topup.amount.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Paisaजी Reference', style: GoogleFonts.outfit(color: AppTheme.secondaryText, fontSize: 13)),
                        Text(refCode, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.primaryNavy)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text('Enter UTR / UPI Reference Number', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _utrController,
                hintText: 'Enter 12-digit UTR or UPI reference',
              ),

              const SizedBox(height: 24),
              Text('Payment Screenshot', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showImageSourcePicker,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: _screenshot != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(File(_screenshot!.path), fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload_outlined, size: 40, color: AppTheme.primaryBlue),
                            const SizedBox(height: 8),
                            Text('Upload Payment Screenshot', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                            const SizedBox(height: 4),
                            Text('JPG, PNG, WEBP up to 5 MB', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.secondaryText)),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 8),
              Text(
                'Upload the UPI payment confirmation showing the amount and transaction reference.',
                style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.secondaryText, height: 1.4),
              ),

              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Submit for Verification',
                isLoading: _isLoading,
                onPressed: _submit,
              ),

              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Your wallet will be credited only after payment verification.',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.secondaryText, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
