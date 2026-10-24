import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:zeokash/shared/widgets/cards/transaction_row.dart';
import 'package:zeokash/shared/widgets/inputs/search_field.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Topup', 'Spend', 'Reward', 'Refund'];
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final typeFilter = _selectedFilter == 'All' ? null : _selectedFilter.toUpperCase();
    final txAsync = ref.watch(walletTransactionsProvider(typeFilter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('History', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletTransactionsProvider(typeFilter));
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: SearchField(
                hintText: 'Search orders, transactions...',
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return ChoiceChip(
                    showCheckmark: false,
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.primaryText,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryBlue,
                    backgroundColor: AppTheme.surface,
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedFilter = filter);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: txAsync.when(
                data: (txs) {
                  final filtered = txs.where((t) {
                    if (_searchQuery.isEmpty) return true;
                    return t.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           t.transactionType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           t.referenceId.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.secondaryText),
                          const SizedBox(height: 16),
                          const Text('No history found.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.secondaryText)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
                    itemBuilder: (context, index) {
                      final t = filtered[index];
                      final isSuccess = t.status == 'POSTED' || t.status == 'SUCCESS' || t.status == 'COMPLETED';
                      final isReward = t.transactionType.toUpperCase().contains('REWARD');
                      final isCredit = ['TOPUP', 'REWARD', 'REWARD_CREDIT', 'REFUND'].contains(t.transactionType.toUpperCase());

                      IconData iconData = Icons.payment;
                      if (isReward) {
                        iconData = Icons.card_giftcard_rounded;
                      } else if (isCredit) {
                        iconData = Icons.arrow_downward_rounded;
                      } else {
                        iconData = Icons.arrow_upward_rounded;
                      }

                      return TransactionRow(
                        title: t.description.isNotEmpty ? t.description : t.transactionType,
                        date: t.createdAt.length >= 16 ? t.createdAt.substring(0, 16).replaceFirst('T', ' ') : t.createdAt,
                        amount: t.amount,
                        isSuccess: isSuccess,
                        currencySymbol: isReward ? 'G ' : '₹',
                        amountPrefix: isCredit ? '+' : '-',
                        icon: iconData,
                        onTap: () {
                          context.push('/history/details', extra: {
                            'title': t.description.isNotEmpty ? t.description : t.transactionType,
                            'date': t.createdAt,
                            'amount': t.amount,
                            'isSuccess': isSuccess,
                            'ref': t.referenceId.isNotEmpty ? t.referenceId : t.id,
                            'type': t.transactionType,
                            'status': t.status,
                            'isReward': isReward,
                          });
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
                error: (e, s) => Center(child: Text('Error loading history: $e', style: const TextStyle(color: AppTheme.error))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
