import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/g_coin_wallet/presentation/providers/g_coin_withdrawal_provider.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class AddBankAccountScreen extends ConsumerStatefulWidget {
  const AddBankAccountScreen({super.key});

  @override
  ConsumerState<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends ConsumerState<AddBankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _accountController = TextEditingController();
  final _confirmAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _branchController = TextEditingController();

  String _proofType = 'CANCELLED_CHEQUE';
  XFile? _selectedProofFile;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _bankNameController.dispose();
    _holderNameController.dispose();
    _accountController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  void _onIfscChanged(String ifsc) {
    final clean = ifsc.trim().toUpperCase();
    if (clean.length >= 4) {
      final prefix = clean.substring(0, 4);
      final branchMap = {
        'HDFC': ('HDFC Bank', 'HDFC Central Branch'),
        'SBIN': ('State Bank of India', 'SBI Main Branch'),
        'ICIC': ('ICICI Bank', 'ICICI Tech Park Branch'),
        'UTIB': ('Axis Bank', 'Axis Bank City Branch'),
        'PUNB': ('Punjab National Bank', 'PNB Metro Branch'),
        'KKBK': ('Kotak Mahindra Bank', 'Kotak Prime Branch'),
        'BARB': ('Bank of Baroda', 'BOB Commercial Branch'),
        'CNRB': ('Canara Bank', 'Canara Central Branch'),
      };
      if (branchMap.containsKey(prefix)) {
        final info = branchMap[prefix]!;
        if (_bankNameController.text.isEmpty) {
          _bankNameController.text = info.$1;
        }
        _branchController.text = info.$2;
        setState(() {});
      }
    }
  }

  Future<void> _pickProofDocument(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85);

      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.length();
        if (bytes > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File size exceeds 5 MB limit. Please select a smaller document.')),
            );
          }
          return;
        }
        setState(() {
          _selectedProofFile = picked;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick document: $e')),
        );
      }
    }
  }

  void _showProofPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Bank Proof Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFEFF6FF), child: Icon(Icons.photo_library, color: AppTheme.primaryBlue)),
                title: const Text('Choose from Gallery / Files'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickProofDocument(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFEFF6FF), child: Icon(Icons.camera_alt, color: AppTheme.primaryBlue)),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickProofDocument(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitBankAccount() async {
    if (!_formKey.currentState!.validate()) return;

    if (_accountController.text.trim() != _confirmAccountController.text.trim()) {
      setState(() => _errorMessage = 'Account numbers do not match.');
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(gCoinWithdrawalRepositoryProvider);
      final newBank = await repo.registerBankAccount(
        bankName: _bankNameController.text.trim(),
        accountHolderName: _holderNameController.text.trim(),
        accountNumber: _accountController.text.trim(),
        confirmAccountNumber: _confirmAccountController.text.trim(),
        ifsc: _ifscController.text.trim().toUpperCase(),
        proofPath: _selectedProofFile?.path,
        proofType: _proofType,
      );

      ref.invalidate(userBankAccountsProvider);
      ref.invalidate(gCoinWithdrawalEligibilityProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.success,
            content: Text(
              newBank.isVerified
                  ? 'Bank account verified successfully! (Penny Drop OK)'
                  : 'Bank account submitted for verification.',
            ),
          ),
        );
        context.pop(newBank);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Add Bank Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Color(0xFF1D4ED8), size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Beneficiary account must match your verified KYC legal name. Transferred funds settle instantly via IMPS.',
                          style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // IFSC Code
                const Text('IFSC Code', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryText)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _ifscController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 11,
                  decoration: InputDecoration(
                    hintText: 'e.g. HDFC0001234',
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                  ),
                  onChanged: _onIfscChanged,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'IFSC code is required';
                    if (v.trim().length != 11) return 'IFSC must be exactly 11 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Bank Name
                const Text('Bank Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryText)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _bankNameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. HDFC Bank',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Bank name is required' : null,
                ),
                const SizedBox(height: 16),

                // Bank Branch
                if (_branchController.text.isNotEmpty) ...[
                  const Text('Bank Branch (Auto-detected)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _branchController,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Account Holder Name
                const Text('Account Holder Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryText)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _holderNameController,
                  decoration: InputDecoration(
                    hintText: 'Name as registered with bank',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Account holder name is required' : null,
                ),
                const SizedBox(height: 16),

                // Account Number
                const Text('Bank Account Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryText)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _accountController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter 9 to 18 digits',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Account number is required';
                    if (v.trim().length < 9 || v.trim().length > 18) return 'Account number must be 9-18 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Account Number
                const Text('Confirm Bank Account Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryText)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmAccountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Re-enter account number',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please confirm your account number';
                    if (v.trim() != _accountController.text.trim()) return 'Account numbers do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Document Proof Upload
                const Text('Bank Proof Document (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryText)),
                const SizedBox(height: 4),
                const Text('Cancelled cheque, passbook, or bank statement (Max 5 MB)', style: TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _buildProofTypeOption('CANCELLED_CHEQUE', 'Cheque'),
                    const SizedBox(width: 8),
                    _buildProofTypeOption('PASSBOOK', 'Passbook'),
                    const SizedBox(width: 8),
                    _buildProofTypeOption('STATEMENT', 'Statement'),
                  ],
                ),
                const SizedBox(height: 12),

                InkWell(
                  onTap: _showProofPickerModal,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border, style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _selectedProofFile != null ? Icons.check_circle_outline : Icons.cloud_upload_outlined,
                          size: 36,
                          color: _selectedProofFile != null ? AppTheme.success : AppTheme.primaryBlue,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedProofFile != null
                              ? _selectedProofFile!.name
                              : 'Tap to upload document proof (JPG, PNG, PDF)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _selectedProofFile != null ? FontWeight.bold : FontWeight.normal,
                            color: _selectedProofFile != null ? AppTheme.primaryText : AppTheme.secondaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: PrimaryButton(
                    text: 'Verify & Link Bank Account',
                    isLoading: _isUploading,
                    onPressed: _submitBankAccount,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProofTypeOption(String type, String label) {
    final isSelected = _proofType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _proofType = type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryNavy : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppTheme.primaryNavy : AppTheme.border),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.primaryText,
            ),
          ),
        ),
      ),
    );
  }
}
