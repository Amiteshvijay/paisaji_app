import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    {'label': 'Rewards', 'value': 'REWARD'},
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
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(walletTransactionsProvider(_selectedFilter));
                  },
                  child: ListView.separated(
                    itemCount: txs.length,
                    separatorBuilder: (context, index) => const Divider(indent: 70, endIndent: 16),
                    itemBuilder: (context, index) {
                      final item = txs[index];
                      final isCredit = ['TOPUP', 'REWARD_CREDIT', 'REWARD', 'REFUND'].contains(item.transactionType.toUpperCase());
                      final statusUpper = item.status.toUpperCase();
                      final isSuccess = statusUpper == 'SUCCESS' || statusUpper == 'COMPLETED' || statusUpper == 'POSTED';
                      final isPending = statusUpper == 'PENDING' || statusUpper == 'PROCESSING' || statusUpper == 'CREATED' || statusUpper == 'INITIATED';
                      final isReward = item.transactionType.toUpperCase().contains('REWARD');
                      final currSymbol = isReward ? 'G ' : '₹';
                      final prefix = isCredit ? '+' : '-';
                      final amtFormatted = item.amount == item.amount.roundToDouble()
                          ? item.amount.toInt().toString()
                          : item.amount.toStringAsFixed(2);
                      final refDisplay = item.referenceId.isNotEmpty ? item.referenceId : item.id;
                      final dateDisplay = item.createdAt.length >= 10 ? item.createdAt.substring(0, 10) : item.createdAt;

                      return ListTile(
                        onTap: () {
                          context.push('/history/details', extra: {
                            'title': item.description.isNotEmpty ? item.description : item.transactionType,
                            'date': item.createdAt,
                            'amount': item.amount,
                            'isSuccess': isSuccess,
                            'ref': refDisplay,
                            'type': item.transactionType,
                            'status': item.status,
                            'isReward': isReward,
                          });
                        },
                        leading: CircleAvatar(
                          backgroundColor: isSuccess
                              ? (isCredit ? Colors.green.shade50 : Colors.red.shade50)
                              : (isPending ? Colors.orange.shade50 : Colors.red.shade50),
                          child: Icon(
                            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isSuccess
                                ? (isCredit ? Colors.green : Colors.red)
                                : (isPending ? Colors.orange : Colors.red),
                          ),
                        ),
                        title: Text(
                          item.description.isNotEmpty ? item.description : item.transactionType,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ref: $refDisplay',
                                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSuccess
                                          ? Colors.green.shade50
                                          : (isPending ? Colors.orange.shade50 : Colors.red.shade50),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isSuccess
                                            ? Colors.green.shade200
                                            : (isPending ? Colors.orange.shade200 : Colors.red.shade200),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      statusUpper,
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isSuccess
                                            ? Colors.green.shade700
                                            : (isPending ? Colors.orange.shade800 : Colors.red.shade700),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    dateDisplay,
                                    style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$prefix$currSymbol$amtFormatted',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isCredit ? Colors.green.shade700 : (isSuccess ? Colors.black87 : Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error loading activity: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
