import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

final complaintsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('complaints/');
    return response.data['data'] ?? [];
  } catch (_) {
    return [
      {
        'complaint_number': 'CMP2391',
        'category': 'Payment Issue',
        'description': 'BESCOM Electricity payment debited but not updated.',
        'status': 'REGISTERED',
        'created_at': '2026-10-06',
      }
    ];
  }
});

class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  void _showRaiseComplaintModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const _RaiseComplaintModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 20.0;
    const double cardMargin = 12.0;

    final complaintsAsync = ref.watch(complaintsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Complaints', style: TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600, fontSize: 13)),
                TextButton(
                  onPressed: () => _showRaiseComplaintModal(context),
                  child: const Text('+ Raise New', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            complaintsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
              error: (err, stack) => const Center(child: Text('Failed to load complaints')),
              data: (complaints) {
                if (complaints.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No complaints registered yet.', style: TextStyle(color: AppTheme.secondaryText)),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: complaints.length,
                  separatorBuilder: (context, index) => const SizedBox(height: cardMargin),
                  itemBuilder: (context, index) {
                    final c = complaints[index];
                    final number = c['complaint_number'] ?? 'CMP0000';
                    final category = c['category'] ?? 'General';
                    final description = c['description'] ?? '';
                    final status = c['status'] ?? 'REGISTERED';
                    final date = c['created_at']?.toString().substring(0, 10) ?? '';

                    return InkWell(
                      onTap: () {
                        context.push('/profile/complaints/detail', extra: c);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Complaint #$number',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(
                                    status,
                                    style: const TextStyle(color: AppTheme.warning, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                  backgroundColor: const Color(0xFFFEF3C7),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('$category ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ $description', style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 12),
                            Text('Submitted on: $date', style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RaiseComplaintModal extends ConsumerStatefulWidget {
  const _RaiseComplaintModal();

  @override
  ConsumerState<_RaiseComplaintModal> createState() => _RaiseComplaintModalState();
}

class _RaiseComplaintModalState extends ConsumerState<_RaiseComplaintModal> {
  final _txnController = TextEditingController();
  final _descController = TextEditingController();
  final _otherCategoryController = TextEditingController();

  String _selectedCategory = 'Payment Issue';
  final List<String> _categories = [
    'Payment Issue',
    'Recharge Failure',
    'Bill Mismatch',
    'Refund Delay',
    'Others',
  ];

  PlatformFile? _attachedFile;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );
      if (files.isNotEmpty) {
        final file = files.first;
        int size = 0;
        try {
          if (file.path != null) {
            size = await File(file.path!).length();
          }
        } catch (_) {}

        if (size > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File size exceeds 5 MB limit. Please choose a smaller file.')),
            );
          }
          return;
        }

        setState(() {
          _attachedFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: ')),
        );
      }
    }
  }
  Future<void> _submit() async {
    final category = _selectedCategory == 'Others' ? _otherCategoryController.text.trim() : _selectedCategory;
    final txnRef = _txnController.text.trim();
    final description = _descController.text.trim();

    if (txnRef.isEmpty || category.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = ref.read(dioProvider);
      
      final metadata = <String, dynamic>{};
      if (_attachedFile != null) {
        metadata['attachment_name'] = _attachedFile!.name;
        int size = 0;
        try {
          if (_attachedFile!.path != null) {
            size = await File(_attachedFile!.path!).length();
          }
        } catch (_) {}
        metadata['attachment_size'] = size;
      }

      await dio.post('complaints/', data: {
        'transaction_reference': txnRef,
        'category': category,
        'description': description,
        'metadata': metadata,
      });

      ref.invalidate(complaintsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully to backend.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit complaint. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Raise a Complaint', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            
            // Category Dropdown
            const Text('Issue Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
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
                  value: _selectedCategory,
                  isExpanded: true,
                  items: _categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCategory = val);
                    }
                  },
                ),
              ),
            ),
            
            if (_selectedCategory == 'Others') ...[
              const SizedBox(height: 16),
              const Text('Specify Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _otherCategoryController,
                hintText: 'Enter custom category',
              ),
            ],

            const SizedBox(height: 16),
            const Text('Transaction / Reference ID', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _txnController,
              hintText: 'e.g. ZK987654321',
            ),

            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe your issue in detail...',
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

            const SizedBox(height: 20),
            // File Attachment
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file, size: 18),
                  label: const Text('Attach File (PDF/Image)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: const BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                if (_attachedFile != null)
                  Expanded(
                    child: Text(
                      _attachedFile!.name,
                      style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Submit Complaint',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
