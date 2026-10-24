import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/features/wallet/presentation/providers/wallet_provider.dart';

class WalletActivityScreen extends ConsumerStatefulWidget {
  const WalletActivityScreen({super.key});

  @override
  ConsumerState<WalletActivityScreen> createState() => _WalletActivityScreenState();
}

class _WalletActivityScreenState extends ConsumerState<WalletActivityScreen> {
  String? _selectedFilter;

  final List<Map<String, String?>> _filters = [
    {'label': 'All', 'value': null},
    {'label': 'Top-ups', 'value': 'TOPUP'},
    {'label': 'Spends', 'value': 'SPEND'},
    {'label': 'Rewards', 'value': 'REWARD_CREDIT'},
    {'label': 'Refunds', 'value': 'REFUND'},
  ];

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(walletTransactionsProvider(_selectedFilter));

    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet Activity', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter['label']!),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter['value'];
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Activity List
          Expanded(
            child: txAsync.when(
              data: (txs) {
                if (txs.isEmpty) {
                  return Center(
                    child: Text(
                      'No transactions found for this filter.',
                      style: GoogleFonts.outfit(color: Colors.grey),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: txs.length,
                  separatorBuilder: (err, stack) => const Divider(indent: 70),
                  itemBuilder: (context, index) {
                    final item = txs[index];
                    final isCredit = ['TOPUP', 'REWARD_CREDIT', 'REWARD', 'REFUND'].contains(item.transactionType.toUpperCase());
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCredit ? Colors.green.shade50 : Colors.red.shade50,
                        child: Icon(
                          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isCredit ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        item.description.isNotEmpty ? item.description : item.transactionType,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        'Ref:  | ',
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isCredit ? Colors.green : Colors.black87,
                            ),
                          ),
                          Text(
                            item.createdAt.length >= 10 ? item.createdAt.substring(0, 10) : item.createdAt,
                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error loading activity: ')),
            ),
          ),
        ],
      ),
    );
  }
}
