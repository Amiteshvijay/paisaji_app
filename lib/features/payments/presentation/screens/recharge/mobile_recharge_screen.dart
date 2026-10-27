import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/services/contacts_service.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/payments/data/recharge_repository.dart';
import 'package:zeokash/features/payments/providers/recharge_provider.dart';
import 'package:zeokash/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:zeokash/features/zeocoins/presentation/providers/zeocoin_provider.dart';

class MobileRechargeScreen extends ConsumerStatefulWidget {
  const MobileRechargeScreen({super.key});

  @override
  ConsumerState<MobileRechargeScreen> createState() => _MobileRechargeScreenState();
}

class _MobileRechargeScreenState extends ConsumerState<MobileRechargeScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedOperator;
  String? _selectedCircle;
  String? _selectedContactName;
  bool _useZeoCoins = true;
  bool _userManuallySelectedOperator = false;
  bool _userManuallySelectedCircle = false;

  final List<String> _operators = ['Airtel', 'Jio', 'Vi', 'BSNL', 'MTNL'];
  final List<String> _circles = [
    'Haryana',
    'Delhi NCR',
    'Punjab',
    'UP East',
    'UP West',
    'Mumbai',
    'Maharashtra & Goa',
    'Gujarat',
    'Rajasthan',
    'Madhya Pradesh & Chhattisgarh',
    'Bihar & Jharkhand',
    'Kolkata',
    'West Bengal',
    'Odisha',
    'Andhra Pradesh & Telangana',
    'Karnataka',
    'Tamil Nadu & Chennai',
    'Kerala',
    'Himachal Pradesh',
    'Jammu & Kashmir',
    'Assam',
    'North East',
    'All India',
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(rechargeStateProvider);
    if (state.mobileNumber.isNotEmpty) {
      _phoneController.text = state.mobileNumber;
    }
    _selectedOperator = _matchOperator(state.operatorName);
    _selectedCircle = _matchCircle(state.circle);

    _amountController.addListener(() {
      setState(() {});
    });
  }

  String? _matchOperator(String? op) {
    if (op == null || op.isEmpty) return null;
    for (final item in _operators) {
      if (item.toLowerCase() == op.toLowerCase()) return item;
    }
    return _operators.first;
  }

  String? _matchCircle(String? cir) {
    if (cir == null || cir.isEmpty) return null;
    for (final item in _circles) {
      if (item.toLowerCase() == cir.toLowerCase() ||
          item.toLowerCase().contains(cir.toLowerCase()) ||
          cir.toLowerCase().contains(item.toLowerCase())) {
        return item;
      }
    }
    return _circles.first;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double _getDiscountRate(String? op) {
    if (op == null) return 0.005;
    final lower = op.toLowerCase();
    if (lower.contains('bsnl')) return 0.015; // BSNL 1.5%
    if (lower.contains('vi') || lower.contains('vodafone') || lower.contains('idea')) return 0.020; // VI 2%
    if (lower.contains('airtel')) return 0.005; // Airtel 0.5%
    if (lower.contains('jio')) return 0.005; // Jio 0.5%
    if (lower.contains('mtnl')) return 0.005; // MTNL 0.5%
    return 0.005;
  }

  String _getDiscountPercentText(String? op) {
    final rate = _getDiscountRate(op);
    final pct = rate * 100;
    if (pct == pct.roundToDouble()) {
      return '${pct.toInt()}%';
    }
    return '${pct.toStringAsFixed(1)}%';
  }

  double get _enteredAmount => double.tryParse(_amountController.text.trim()) ?? 0.0;
  bool get _isJio => (_selectedOperator ?? '').toLowerCase().contains('jio');
  bool get _isJioUnderMin => _isJio && _enteredAmount > 0 && _enteredAmount < 349;

  /// Helper to mask phone numbers securely: e.g. 9661665549 -> 9661••••49


  /// Helper to format ISO dates to concise readable string
  static String _formatRechargeDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw.split('T').first;
    }
  }

  void _onPhoneChanged(String val) async {
    final clean = val.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      try {
        final repo = ref.read(rechargeRepositoryProvider);
        final detected = await repo.detectOperator(clean);
        if (detected.isNotEmpty && mounted) {
          setState(() {
            // Auto-detect is a convenience suggestion only.
            // If the user manually edited/selected an operator or circle (e.g. MNP ported number),
            // the user's manual selection is always final and never overridden.
            if (!_userManuallySelectedOperator && detected['operator_name'] != null) {
              _selectedOperator = _matchOperator(detected['operator_name'].toString());
            }
            if (!_userManuallySelectedCircle && detected['circle'] != null) {
              _selectedCircle = _matchCircle(detected['circle'].toString());
            }
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _pickFromContacts() async {
    try {
      final contact = await ContactsService.pickContact();
      if (contact != null && contact.cleanNumber.isNotEmpty) {
        setState(() {
          _phoneController.text = contact.cleanNumber;
          _selectedContactName = (contact.name != null && contact.name!.trim().isNotEmpty)
              ? contact.name!.trim()
              : null;
        });
        _onPhoneChanged(contact.cleanNumber);
        if (mounted && contact.name != null && contact.name!.trim().isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected: ${contact.name} (${contact.cleanNumber})'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not access contacts directory')),
        );
      }
    }
  }

  Future<void> _goToPlans() async {
    final number = _phoneController.text.trim();
    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter mobile number first')),
      );
      return;
    }

    final opName = _selectedOperator ?? 'Airtel';
    final cirName = _selectedCircle ?? 'Haryana';

    ref.read(rechargeStateProvider.notifier).updateState(RechargeState(
      mobileNumber: number,
      operatorName: opName,
      operatorCode: opName.toUpperCase().replaceAll(' ', '_'),
      circle: cirName,
    ));

    final selectedPrice = await context.push<int>('/recharge/plans', extra: number);
    if (selectedPrice != null && mounted) {
      setState(() {
        _amountController.text = selectedPrice.toString();
      });
    }
  }

  void _showAllRecentRechargesModal(List<dynamic> allRecentRecharges) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recharge History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Your authenticated recharge transaction history:', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
              const SizedBox(height: 16),
              if (allRecentRecharges.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded, size: 54, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('No Recent Recharges', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                        const SizedBox(height: 6),
                        const Text(
                          'Your recharge history will appear here once you make your first recharge.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.secondaryText, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: allRecentRecharges.length,
                    separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
                    itemBuilder: (context, index) {
                      final item = allRecentRecharges[index] as Map<String, dynamic>;
                      final number = item['mobile_number']?.toString() ?? '';
                      final op = item['operator_name']?.toString() ?? item['operator_code']?.toString() ?? 'Mobile';
                      final date = _formatRechargeDate(item['created_at']?.toString());
                      final amt = item['amount']?.toString() ?? '0';
                      final statusStr = (item['status']?.toString() ?? 'SUCCESS').toUpperCase();
                      final isSuccess = statusStr == 'SUCCESS';
                      final isPending = statusStr.contains('PENDING');

                      Color statusColor = AppTheme.success;
                      if (isPending) statusColor = Colors.orange;
                      if (!isSuccess && !isPending) statusColor = AppTheme.error;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          child: Text(
                            op.isNotEmpty ? op[0].toUpperCase() : 'R',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                          ),
                        ),
                        title: Text(
                          number,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        subtitle: Text(
                          '$op • $date',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹$amt',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              statusStr,
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _phoneController.text = number;
                            _selectedOperator = _matchOperator(op);
                            final parsedAmt = double.tryParse(amt);
                            if (parsedAmt != null && parsedAmt > 0) {
                              _amountController.text = parsedAmt.toInt().toString();
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onRechargeNow(double coinBalance) {
    final number = _phoneController.text.trim();
    final amt = _enteredAmount;

    if (number.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    if (amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount or select a plan from View Plans')),
      );
      return;
    }

    if (_isJio && amt < 349) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jio mobile recharge will be done for ₹349 or more. Less than ₹349 recharge is not available.'),
          backgroundColor: Color(0xFFDC2626),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_selectedOperator == null || _selectedOperator!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an operator')),
      );
      return;
    }
    final op = _selectedOperator!;
    final cir = _selectedCircle ?? 'Haryana';

    final instantDiscount = amt * _getDiscountRate(op);
    final maxUsableCoins = (coinBalance * 0.05);
    final maxCoinsForPlan = (amt - instantDiscount) * 10.0;
    final coinsUsed = _useZeoCoins
        ? (maxUsableCoins < maxCoinsForPlan ? maxUsableCoins : maxCoinsForPlan).clamp(0.0, coinBalance)
        : 0.0;
    final coinDiscount = coinsUsed / 10.0;
    final finalPayable = (amt - instantDiscount - coinDiscount).clamp(1.0, double.infinity);

    ref.read(rechargeStateProvider.notifier).updateState(RechargeState(
      mobileNumber: number,
      operatorName: op,
      operatorCode: op.toUpperCase().replaceAll(' ', '_'),
      circle: cir,
    ));

    context.push('/payment/review', extra: {
      'title': 'Mobile Recharge ($op)',
      'subtitle': '+91 $number - $cir',
      'amount': finalPayable,
      'baseAmount': amt,
      'instantDiscount': instantDiscount,
      'zeocoinDiscount': coinDiscount,
      'coinsRedeemed': coinsUsed,
      'mobileNumber': number,
      'operatorCode': op,
      'circle': cir,
      'serviceType': 'MOBILE_RECHARGE',
    });
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDiscount ? const Color(0xFF16A34A) : const Color(0xFF64748B),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: isDiscount ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
            fontWeight: (isDiscount || isBold) ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRechargesSection() {
    final historyAsync = ref.watch(userRechargeHistoryProvider);

    return historyAsync.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0047AB)),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (historyList) {
        // Empty state when user has no recharge history
        if (historyList.isEmpty) {
          return Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.history_toggle_off_rounded, color: Color(0xFF64748B), size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Recent Recharges',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Your recharge history will appear here once you make your first recharge.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Show latest 5 recharges for logged-in user
        final top5 = historyList.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Recent Recharges',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () => _showAllRecentRechargesModal(historyList),
                  child: const Text('Show All', style: TextStyle(color: Color(0xFF0047AB), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: top5.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  if (index == top5.length) {
                    return InkWell(
                      onTap: () => _showAllRecentRechargesModal(historyList),
                      borderRadius: BorderRadius.circular(30),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF0047AB), width: 2),
                            ),
                            child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0047AB)),
                          ),
                          const SizedBox(height: 6),
                          const Text('Show All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0047AB))),
                        ],
                      ),
                    );
                  }

                  final item = top5[index] as Map<String, dynamic>;
                  final number = item['mobile_number']?.toString() ?? '';
                  final op = item['operator_name']?.toString() ?? item['operator_code']?.toString() ?? 'Recharge';
                  final amt = item['amount']?.toString() ?? '';

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _phoneController.text = number;
                        _selectedOperator = _matchOperator(op);
                        final parsedAmt = double.tryParse(amt);
                        if (parsedAmt != null && parsedAmt > 0) {
                          _amountController.text = parsedAmt.toInt().toString();
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: SizedBox(
                      width: 76,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: const Color(0xFFF1F5F9),
                            child: Text(
                              op.isNotEmpty ? op[0].toUpperCase() : 'R',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0047AB)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            op,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            number,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentRewardsBanner() {
    return InkWell(
      onTap: () => context.push('/rewards/my-rewards'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFEF08A), Color(0xFFFACC15)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.card_giftcard, color: Color(0xFF854D0E), size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Rewards',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'You won +20 G Coins • Tap to view all',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletDataProvider);
    final balance = walletAsync.asData?.value.availableBalance ?? 0.0;
    final balanceStr = balance.toStringAsFixed(3);

    final zeocoinAsync = ref.watch(zeocoinWalletProvider);
    final coinBalance = zeocoinAsync.asData?.value.availableBalance ?? 0.0;
    final coinInrValue = coinBalance / 10.0;

    final amt = _enteredAmount;
    final discountRate = _getDiscountRate(_selectedOperator);
    final instantDiscount = amt * discountRate;

    final maxUsableCoins = (coinBalance * 0.05);
    final maxCoinsForPlan = (amt - instantDiscount) * 10.0;
    final coinsUsed = _useZeoCoins
        ? (maxUsableCoins < maxCoinsForPlan ? maxUsableCoins : maxCoinsForPlan).clamp(0.0, coinBalance)
        : 0.0;
    final coinDiscount = coinsUsed / 10.0;
    final finalAmount = (amt - instantDiscount - coinDiscount).clamp(0.0, double.infinity);
    final totalSavings = instantDiscount + coinDiscount;

    return Scaffold(
      backgroundColor: const Color(0xFF0047AB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047AB),
        elevation: 0,
        centerTitle: true,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: InkWell(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24, width: 1.2),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
              ),
            ),
          ),
        ),
        title: const Text(
          'Prepaid Recharge',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Mobile Number Section
              const Text(
                'Mobile Number',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        onChanged: _onPhoneChanged,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Mobile Number',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: _pickFromContacts,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0047AB).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.contacts_rounded,
                            color: Color(0xFF0047AB),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedContactName != null && _selectedContactName!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_rounded, size: 16, color: Color(0xFF0047AB)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _selectedContactName!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0047AB),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedContactName = null;
                            _phoneController.clear();
                          });
                        },
                        child: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // 2. Operator Section (User selection is final, supporting MNP)
              const Text(
                'Operator',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedOperator,
                    hint: const Text(
                      'Select Operator',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                    isExpanded: true,
                    items: _operators.map((op) {
                      return DropdownMenuItem<String>(
                        value: op,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              op,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_getDiscountPercentText(op)} OFF',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0047AB),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedOperator = val;
                        _userManuallySelectedOperator = true;
                      });
                    },
                  ),
                ),
              ),

              // Instant Operator Discount Banner
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: Color(0xFF16A34A), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Instant Discount: ${_getDiscountPercentText(_selectedOperator)} off on ${_selectedOperator ?? "operator"} recharge',
                        style: const TextStyle(
                          color: Color(0xFF15803D),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Circle Section
              const Text(
                'Circle',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCircle,
                    hint: const Text(
                      'Select Circle',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                    isExpanded: true,
                    items: _circles.map((cir) {
                      return DropdownMenuItem<String>(
                        value: cir,
                        child: Text(
                          cir,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCircle = val;
                        _userManuallySelectedCircle = true;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Amount Section
              const Text(
                'Amount',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isJioUnderMin ? const Color(0xFFDC2626) : const Color(0xFFE2E8F0),
                    width: _isJioUnderMin ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Amount',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _goToPlans,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          'View Plans',
                          style: TextStyle(
                            color: Color(0xFF0047AB),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isJioUnderMin) ...[
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 16),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Jio recharges below ₹349 are not available. Please choose ₹349 or higher.',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (_isJio) ...[
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF64748B), size: 15),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Minimum recharge for Jio is ₹349. Choose higher recharge for valid plans.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),

              // 5. Balance Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your balance : ₹$balanceStr',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 6. ZeoCoins Redemption Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Use G Coins',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '5% COIN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Balance: ${coinBalance.toStringAsFixed(0)} Coins (₹${coinInrValue.toStringAsFixed(2)}) • 5% usable',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _useZeoCoins,
                      activeThumbColor: const Color(0xFFD97706),
                      onChanged: (val) {
                        setState(() => _useZeoCoins = val);
                      },
                    ),
                  ],
                ),
              ),

              // 7. Instant Recharge Summary
              if (amt > 0) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.receipt_long, color: Color(0xFF0047AB), size: 18),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Instant Recharge Summary',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (totalSavings > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Save ₹${totalSavings.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Recharge Plan Amount', '₹${amt.toStringAsFixed(2)}'),
                      const SizedBox(height: 6),
                      _buildSummaryRow(
                        'Instant Discount (${_getDiscountPercentText(_selectedOperator)})',
                        '-₹${instantDiscount.toStringAsFixed(2)}',
                        isDiscount: true,
                      ),
                      if (_useZeoCoins && coinDiscount > 0) ...[
                        const SizedBox(height: 6),
                        _buildSummaryRow(
                          'G Coins Applied (${coinsUsed.toStringAsFixed(coinsUsed == coinsUsed.roundToDouble() ? 0 : 2)} Coins • 5%)',
                          '-₹${coinDiscount.toStringAsFixed(2)}',
                          isDiscount: true,
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Final Payment Amount',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '₹${finalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF0047AB),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),

              // 8. Recharge Now Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _onRechargeNow(coinBalance),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isJioUnderMin ? const Color(0xFF94A3B8) : const Color(0xFF0047AB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    amt > 0
                        ? 'Recharge Now • ₹${finalAmount.toStringAsFixed(2)}'
                        : 'Recharge Now',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 9. Your Recent Recharges Section (Strictly Authenticated User Isolated)
              _buildRecentRechargesSection(),
              const SizedBox(height: 24),

              // 10. Recent Rewards Banner
              _buildRecentRewardsBanner(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
