import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/profile/presentation/screens/saved_billers_screen.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class BillerDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> billerData;

  const BillerDetailScreen({
    super.key,
    required this.billerData,
  });

  @override
  ConsumerState<BillerDetailScreen> createState() => _BillerDetailScreenState();
}

class _BillerDetailScreenState extends ConsumerState<BillerDetailScreen> {
  late TextEditingController _nicknameController;
  late TextEditingController _identifierController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.billerData['nickname'] ?? '');
    _identifierController = TextEditingController(text: widget.billerData['customer_identifier'] ?? '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _updateBiller() async {
    final id = widget.billerData['id'];
    if (id == null) return;

    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('saved-billers/$id/', data: {
        'nickname': _nicknameController.text.trim(),
        'customer_identifier': _identifierController.text.trim(),
      });
      ref.invalidate(savedBillersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biller updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update biller')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBiller() async {
    final id = widget.billerData['id'];
    if (id == null) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('saved-billers/$id/');
      ref.invalidate(savedBillersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biller deleted successfully')),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete biller')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final billerName = widget.billerData['biller']?['name'] ?? 'Utility Biller';

    return Scaffold(
      appBar: AppBar(
        title: Text(billerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.error),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Biller'),
                  content: const Text('Are you sure you want to remove this saved biller?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteBiller();
                      },
                      child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nickname', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _nicknameController,
                hintText: 'e.g. Home Electricity',
              ),
              const SizedBox(height: 20),
              const Text('Customer ID / Consumer Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _identifierController,
                hintText: 'e.g. 123456789',
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Update Biller',
                isLoading: _isLoading,
                onPressed: _updateBiller,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  context.push('/payment/review', extra: {
                    'title': _nicknameController.text,
                    'subtitle': billerName,
                    'amount': 500.0,
                  });
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppTheme.primaryBlue),
                ),
                child: const Text('Pay Bill Now', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
