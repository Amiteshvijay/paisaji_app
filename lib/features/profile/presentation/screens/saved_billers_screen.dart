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
    if (response.data is List) {
      return response.data as List<dynamic>;
    } else if (response.data is Map && response.data['data'] != null && response.data['data'] is List) {
      return response.data['data'] as List<dynamic>;
    } else if (response.data is Map && response.data['results'] != null && response.data['results'] is List) {
      return response.data['results'] as List<dynamic>;
    }
    return [];
  } catch (_) {
    return [];
  }
});

class SavedBillersScreen extends ConsumerWidget {
  const SavedBillersScreen({super.key});

  void _showAddBillerModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _AddBillerModal(),
    );
  }

  void _showQuickEditModal(BuildContext context, WidgetRef ref, Map<String, dynamic> biller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _EditBillerModal(billerData: biller),
    );
  }

  Future<void> _deleteBiller(BuildContext context, WidgetRef ref, String billerId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Biller', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('Are you sure you want to remove "$name" from your saved billers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.secondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final dio = ref.read(dioProvider);
        await dio.delete('saved-billers/$billerId/');
        ref.invalidate(savedBillersProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved biller "$name" deleted successfully'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete saved biller'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toUpperCase();
    if (cat.contains('ELECTR')) return Icons.electric_bolt_rounded;
    if (cat.contains('MOBILE') || cat.contains('PREPAID') || cat.contains('POSTPAID')) return Icons.smartphone_rounded;
    if (cat.contains('FASTAG')) return Icons.directions_car_filled_rounded;
    if (cat.contains('BROADBAND') || cat.contains('WIFI') || cat.contains('FIBER')) return Icons.wifi_rounded;
    if (cat.contains('WATER')) return Icons.water_drop_rounded;
    if (cat.contains('GAS')) return Icons.local_fire_department_rounded;
    if (cat.contains('CARD')) return Icons.credit_card_rounded;
    if (cat.contains('LOAN') || cat.contains('EMI')) return Icons.account_balance_rounded;
    if (cat.contains('DTH')) return Icons.tv_rounded;
    return Icons.receipt_long_rounded;
  }

  Color _getCategoryColor(String category) {
    final cat = category.toUpperCase();
    if (cat.contains('ELECTR')) return const Color(0xFFEAB308);
    if (cat.contains('MOBILE')) return const Color(0xFF007BFF);
    if (cat.contains('FASTAG')) return const Color(0xFF8B5CF6);
    if (cat.contains('BROADBAND')) return const Color(0xFF06B6D4);
    if (cat.contains('WATER')) return const Color(0xFF3B82F6);
    if (cat.contains('GAS')) return const Color(0xFFF97316);
    if (cat.contains('CARD')) return const Color(0xFF10B981);
    return const Color(0xFF0A2342);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double horizontalPadding = 20.0;
    const double cardMargin = 12.0;

    final billersAsync = ref.watch(savedBillersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Saved Billers', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryBlue, size: 26),
            tooltip: 'Add Saved Biller',
            onPressed: () => _showAddBillerModal(context, ref),
          ),
        ],
      ),
      body: billersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
              const SizedBox(height: 12),
              const Text('Failed to load saved billers', style: TextStyle(color: AppTheme.secondaryText, fontSize: 14)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(savedBillersProvider),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (billers) {
          if (billers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bookmark_border_rounded, size: 48, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Saved Billers Yet',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0A2342)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Save your electricity, mobile recharge, FASTag, and broadband accounts for 1-tap bill payments.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.secondaryText, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _showAddBillerModal(context, ref),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add Your First Biller', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(savedBillersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
              itemCount: billers.length,
              separatorBuilder: (context, index) => const SizedBox(height: cardMargin),
              itemBuilder: (context, index) {
                final b = billers[index] as Map<String, dynamic>;
                final id = b['id']?.toString() ?? '';
                final billerObj = b['biller_details'] ?? b['biller'];
                final billerName = billerObj?['name']?.toString() ?? b['biller_name']?.toString() ?? 'Utility';
                final category = billerObj?['category']?.toString() ?? b['biller_category']?.toString() ?? 'UTILITY';
                final nickname = b['nickname']?.toString().isNotEmpty == true
                    ? b['nickname'].toString()
                    : billerName;
                final identifier = b['customer_identifier']?.toString() ?? '';

                final catColor = _getCategoryColor(category);
                final catIcon = _getCategoryIcon(category);

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      context.push('/profile/saved-billers/detail', extra: b);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(catIcon, color: catColor, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        nickname,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: Color(0xFF0A2342),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '$billerName • $identifier',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Actions popup: Edit / Delete
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (val) {
                              if (val == 'edit') {
                                _showQuickEditModal(context, ref, b);
                              } else if (val == 'delete') {
                                _deleteBiller(context, ref, id, nickname);
                              } else if (val == 'pay') {
                                context.push('/payment/review', extra: {
                                  'title': nickname,
                                  'subtitle': billerName,
                                  'amount': 500.0,
                                });
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'pay',
                                child: Row(
                                  children: [
                                    Icon(Icons.payment_rounded, size: 18, color: AppTheme.primaryBlue),
                                    SizedBox(width: 8),
                                    Text('Pay Bill Now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0A2342)),
                                    SizedBox(width: 8),
                                    Text('Edit Biller', style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error),
                                    SizedBox(width: 8),
                                    Text('Delete Biller', style: TextStyle(fontSize: 13, color: AppTheme.error)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
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
  final _customBillerController = TextEditingController();
  String _billerCategory = 'ELECTRICITY';
  String _selectedProvider = 'Tata Power Mumbai';
  bool _isLoading = false;

  final Map<String, List<String>> _categoryProviders = {
    'ELECTRICITY': ['Tata Power Mumbai', 'BESCOM Bangalore', 'BSES Rajdhani Delhi', 'MSEDCL Maharashtra', 'Adani Electricity Mumbai', 'Other Electricity Board'],
    'MOBILE': ['Airtel Prepaid', 'Jio Prepaid', 'VI Prepaid', 'BSNL Prepaid', 'MTNL Delhi/Mumbai'],
    'FASTAG': ['ICICI Bank FASTag', 'Paytm Payments Bank FASTag', 'HDFC Bank FASTag', 'State Bank of India FASTag', 'Airtel Payments Bank FASTag'],
    'BROADBAND': ['Airtel Broadband', 'JioFiber', 'ACT Fibernet', 'Tata Play Fiber', 'BSNL Broadband'],
    'WATER': ['Delhi Jal Board (DJB)', 'Bangalore Water Supply (BWSSB)', 'Municipal Corporation of Greater Mumbai'],
    'GAS': ['Mahanagar Gas Mumbai', 'Indane Gas (IOCL)', 'Bharat Gas (BPCL)', 'HP Gas (HPCL)', 'Adani Total Gas'],
    'CREDIT_CARD': ['HDFC Bank Credit Card', 'SBI Card', 'ICICI Bank Credit Card', 'Axis Bank Credit Card'],
    'LOAN_EMI': ['ICICI Bank Loan EMI', 'HDFC Bank Loan', 'Bajaj Finance EMI', 'Hero Fincorp'],
  };

  @override
  void initState() {
    super.initState();
    _selectedProvider = _categoryProviders[_billerCategory]!.first;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _identifierController.dispose();
    _customBillerController.dispose();
    super.dispose();
  }

  Future<void> _createBiller() async {
    final nickname = _nicknameController.text.trim();
    final identifier = _identifierController.text.trim();
    final billerName = _selectedProvider == 'Other Electricity Board' && _customBillerController.text.trim().isNotEmpty
        ? _customBillerController.text.trim()
        : _selectedProvider;

    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Customer ID or Account Number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('saved-billers/', data: {
        'nickname': nickname.isNotEmpty ? nickname : billerName,
        'customer_identifier': identifier,
        'biller_name': billerName,
        'biller_category': _billerCategory,
      });

      ref.invalidate(savedBillersProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved biller created successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save biller. Please check details and try again.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = _categoryProviders[_billerCategory] ?? [];

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Saved Biller',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0A2342)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppTheme.secondaryText)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _billerCategory,
                  isExpanded: true,
                  items: _categoryProviders.keys.map((c) {
                    final label = c.replaceAll('_', ' ');
                    return DropdownMenuItem(value: c, child: Text(label, style: const TextStyle(fontSize: 14)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _billerCategory = val;
                        _selectedProvider = _categoryProviders[val]!.first;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Biller Provider', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppTheme.secondaryText)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: providers.contains(_selectedProvider) ? _selectedProvider : providers.first,
                  isExpanded: true,
                  items: providers.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 14)))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedProvider = val);
                  },
                ),
              ),
            ),
            if (_selectedProvider.startsWith('Other')) ...[
              const SizedBox(height: 14),
              const Text('Enter Biller Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppTheme.secondaryText)),
              const SizedBox(height: 6),
              CustomTextField(
                controller: _customBillerController,
                hintText: 'e.g. Torrent Power',
              ),
            ],
            const SizedBox(height: 14),
            const Text('Nickname (Optional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppTheme.secondaryText)),
            const SizedBox(height: 6),
            CustomTextField(
              controller: _nicknameController,
              hintText: 'e.g. Home Electricity, Dad Phone',
            ),
            const SizedBox(height: 14),
            const Text('Consumer ID / Account No / Mobile No', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppTheme.secondaryText)),
            const SizedBox(height: 6),
            CustomTextField(
              controller: _identifierController,
              hintText: 'e.g. 102938475',
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Save Biller',
              isLoading: _isLoading,
              onPressed: _createBiller,
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _EditBillerModal extends ConsumerStatefulWidget {
  final Map<String, dynamic> billerData;

  const _EditBillerModal({required this.billerData});

  @override
  ConsumerState<_EditBillerModal> createState() => _EditBillerModalState();
}

class _EditBillerModalState extends ConsumerState<_EditBillerModal> {
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

    final nickname = _nicknameController.text.trim();
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer identifier cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('saved-billers/$id/', data: {
        'nickname': nickname,
        'customer_identifier': identifier,
      });

      ref.invalidate(savedBillersProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biller updated successfully!'), backgroundColor: AppTheme.success),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update biller'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final billerObj = widget.billerData['biller_details'] ?? widget.billerData['biller'];
    final billerName = billerObj?['name'] ?? widget.billerData['nickname'] ?? 'Utility Biller';

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit $billerName',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF0A2342)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Nickname', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppTheme.secondaryText)),
            const SizedBox(height: 6),
            CustomTextField(
              controller: _nicknameController,
              hintText: 'e.g. Home Electricity',
            ),
            const SizedBox(height: 14),
            const Text('Customer ID / Account Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppTheme.secondaryText)),
            const SizedBox(height: 6),
            CustomTextField(
              controller: _identifierController,
              hintText: 'e.g. 102938475',
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Save Changes',
              isLoading: _isLoading,
              onPressed: _updateBiller,
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
