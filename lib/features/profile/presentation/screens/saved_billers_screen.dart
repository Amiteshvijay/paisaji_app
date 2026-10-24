import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

final savedBillersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('saved-billers/');
    return response.data['data'] ?? [];
  } catch (_) {
    return [
      {'id': '1', 'nickname': 'Home Electricity', 'customer_identifier': '••••8392', 'biller': {'name': 'BESCOM'}},
      {'id': '2', 'nickname': "Dad's Airtel", 'customer_identifier': '+91 ••••• •••310', 'biller': {'name': 'Airtel Prepaid'}},
      {'id': '3', 'nickname': 'Primary FASTag', 'customer_identifier': 'DL••••1234', 'biller': {'name': 'ICICI Bank FASTag'}},
    ];
  }
});

class SavedBillersScreen extends ConsumerWidget {
  const SavedBillersScreen({super.key});

  void _showAddBillerModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddBillerModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double horizontalPadding = 20.0;
    const double cardMargin = 12.0;

    final billersAsync = ref.watch(savedBillersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Billers', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryBlue),
            onPressed: () => _showAddBillerModal(context, ref),
          ),
        ],
      ),
      body: billersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (error, stackTrace) => const Center(child: Text('Failed to load saved billers')),
        data: (billers) {
          if (billers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No saved billers found.', style: TextStyle(color: AppTheme.secondaryText)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddBillerModal(context, ref),
                    child: const Text('Add Biller'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
            itemCount: billers.length,
            separatorBuilder: (context, index) => const SizedBox(height: cardMargin),
            itemBuilder: (context, index) {
              final b = billers[index];
              final nickname = b['nickname'] ?? b['biller']?['name'] ?? 'Biller';
              final identifier = b['customer_identifier'] ?? '';
              final billerName = b['biller']?['name'] ?? '';

              return InkWell(
                onTap: () {
                  context.push('/profile/saved-billers/detail', extra: b);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bookmark_outline, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nickname, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text('$billerName • $identifier', style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AddBillerModal extends ConsumerStatefulWidget {
  const _AddBillerModal();

  @override
  ConsumerState<_AddBillerModal> createState() => _AddBillerModalState();
}

class _AddBillerModalState extends ConsumerState<_AddBillerModal> {
  final _nicknameController = TextEditingController();
  final _identifierController = TextEditingController();
  String _billerType = 'Electricity';
  bool _isLoading = false;

  final List<String> _billerTypes = ['Electricity', 'Mobile Prepaid', 'FASTag', 'Broadband', 'Water'];

  Future<void> _createBiller() async {
    if (_nicknameController.text.trim().isEmpty || _identifierController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('saved-billers/', data: {
        'nickname': _nicknameController.text.trim(),
        'customer_identifier': _identifierController.text.trim(),
        'biller_name': _billerType,
      });
      ref.invalidate(savedBillersProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biller added successfully')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add biller')),
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
            Text('Add Saved Biller', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            const Text('Biller Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
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
                  value: _billerType,
                  isExpanded: true,
                  items: _billerTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _billerType = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Nickname', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _nicknameController,
              hintText: 'e.g. Home Electricity',
            ),
            const SizedBox(height: 16),
            const Text('Customer ID / Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _identifierController,
              hintText: 'e.g. 123456789',
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Save Biller',
              isLoading: _isLoading,
              onPressed: _createBiller,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
