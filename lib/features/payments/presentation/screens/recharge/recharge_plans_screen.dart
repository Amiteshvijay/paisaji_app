import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:zeokash/features/payments/providers/recharge_provider.dart';
import 'package:zeokash/features/payments/data/recharge_repository.dart';

class RechargePlansScreen extends ConsumerStatefulWidget {
  final String mobileNumber;

  const RechargePlansScreen({
    super.key,
    required this.mobileNumber,
  });

  @override
  ConsumerState<RechargePlansScreen> createState() => _RechargePlansScreenState();
}

class _RechargePlansScreenState extends ConsumerState<RechargePlansScreen> {
  String _searchQuery = '';
  List<dynamic> _circles = [];

  @override
  void initState() {
    super.initState();
    _loadCircles();
  }

  Future<void> _loadCircles() async {
    final repo = ref.read(rechargeRepositoryProvider);
    final circlesList = await repo.getCircles();
    if (mounted && circlesList.isNotEmpty) {
      setState(() {
        _circles = circlesList;
      });
    }
  }

  void _showChangeOperatorSheet(BuildContext context, RechargeState state, bool isDth) {
    final List<String> operators = isDth
        ? const ['Tata Play', 'Airtel Digital TV', 'Dish TV', 'Sun Direct', 'Videocon D2H']
        : const ['Airtel', 'Jio', 'Vi', 'BSNL', 'MTNL'];

    final List<String> circleOptions = _circles.isNotEmpty
        ? _circles.map((c) => (c['display_name'] ?? c['name'] ?? c['code']).toString()).toList()
        : const [
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
          ];

    String? selectedOp = operators.firstWhere(
      (op) => op.toLowerCase() == state.operatorName.toLowerCase(),
      orElse: () => operators.first,
    );

    String? selectedCir = circleOptions.firstWhere(
      (c) =>
          c.toLowerCase() == state.circle.toLowerCase() ||
          c.toLowerCase().contains(state.circle.toLowerCase()) ||
          state.circle.toLowerCase().contains(c.toLowerCase()),
      orElse: () => circleOptions.first,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 20),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const Text(
                    'Change Operator & Circle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedOp,
                        items: operators.map((op) {
                          return DropdownMenuItem<String>(
                            value: op,
                            child: Text(op, style: const TextStyle(fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                        onChanged: (val) => setSheetState(() => selectedOp = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Telecom Circle',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCir,
                        items: circleOptions.map((c) {
                          return DropdownMenuItem<String>(
                            value: c,
                            child: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                        onChanged: (val) => setSheetState(() => selectedCir = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final newOperator = selectedOp ?? state.operatorName;
                        final newCircle = selectedCir ?? state.circle;
                        final code = _getOperatorCode(newOperator);

                        ref.read(rechargeStateProvider.notifier).updateState(
                          state.copyWith(
                            operatorName: newOperator,
                            operatorCode: code,
                            circle: newCircle,
                          ),
                        );

                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A2342),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Update & View Plans', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getOperatorCode(String operatorName) {
    switch (operatorName.toLowerCase()) {
      case 'airtel':
      case 'airtel digital tv':
        return 'AIRTEL';
      case 'jio':
        return 'JIO';
      case 'vi':
      case 'vodafone idea':
        return 'VI';
      case 'bsnl':
        return 'BSNL';
      case 'mtnl':
        return 'MTNL';
      default:
        return operatorName.toUpperCase().replaceAll(' ', '_');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rechargeStateProvider);
    final plansAsync = ref.watch(rechargePlansProvider);
    final isDth = widget.mobileNumber.startsWith('DTH');
    final displayName = isDth ? 'DTH ID: ' : widget.mobileNumber;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PaisaJi Recharge Plans', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.tune, color: Color(0xFF0A2342)),
              onPressed: () => _showChangeOperatorSheet(context, state, isDth),
            ),
          ],
        ),
        body: Column(
          children: [
            // Top Operator Banner Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A2342), Color(0xFF007BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF0A2342).withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              state.operatorName,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            state.circle,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _showChangeOperatorSheet(context, state, isDth),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0A2342),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      elevation: 0,
                    ),
                    child: const Text('Change', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search plan price, validity, data...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Category Tab Bar
            const TabBar(
              isScrollable: true,
              labelColor: Color(0xFF007BFF),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF007BFF),
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: [
                Tab(text: 'All Plans'),
                Tab(text: 'Truly Unlimited'),
                Tab(text: 'Data Only'),
                Tab(text: 'Top Up'),
                Tab(text: 'Annual'),
              ],
            ),

            // Plans Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _buildPlansList(context, plansAsync, isDth, displayName, null),
                  _buildPlansList(context, plansAsync, isDth, displayName, 'unlimited'),
                  _buildPlansList(context, plansAsync, isDth, displayName, 'data'),
                  _buildPlansList(context, plansAsync, isDth, displayName, 'topup'),
                  _buildPlansList(context, plansAsync, isDth, displayName, 'annual'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansList(BuildContext context, AsyncValue<List<dynamic>> plansAsync, bool isDth, String displayName, String? categoryFilter) {
    return plansAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF007BFF))),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('Unable to load plans for this operator/circle.\n', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
      data: (plans) {
        var filtered = plans.where((p) {
          final desc = (p['short_description'] ?? p['description'] ?? p['name'] ?? '').toString().toLowerCase();
          final price = (p['amount'] ?? p['price'] ?? '').toString();
          final data = (p['data_summary'] ?? p['data_benefit'] ?? '').toString().toLowerCase();
          final query = _searchQuery.toLowerCase();
          final matchesQuery = desc.contains(query) || price.contains(query) || data.contains(query);

          if (categoryFilter != null) {
            final cat = (p['category']?['code'] ?? p['category']?['name'] ?? '').toString().toLowerCase();
            return matchesQuery && (cat.contains(categoryFilter) || desc.contains(categoryFilter));
          }
          return matchesQuery;
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No recharge plans available for this filter.', style: TextStyle(color: Colors.grey)));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final plan = filtered[index];
            final offerId = plan['offer_id'] ?? plan['id'];
            final amountVal = double.tryParse((plan['amount'] ?? plan['price'] ?? '0').toString()) ?? 0.0;
            final validity = (plan['validity_text'] ?? plan['validity'] ?? '28 Days').toString();
            final dataSummary = (plan['data_summary'] ?? plan['data_benefit'] ?? '').toString();
            final voiceSummary = (plan['voice_summary'] ?? 'Unlimited Calls').toString();
            final desc = (plan['short_description'] ?? plan['description'] ?? plan['name'] ?? '').toString();
            final benefits = plan['benefits'] as List<dynamic>? ?? [];

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Amount + Validity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0A2342)),
                          ),
                          if (plan['is_featured'] == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4)),
                              child: Text('POPULAR', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.amber.shade900)),
                            ),
                          ],
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          validity,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF007BFF)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Middle Row: Benefits badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (dataSummary.isNotEmpty)
                        _buildBenefitBadge(Icons.network_cell, dataSummary, Colors.green),
                      if (voiceSummary.isNotEmpty)
                        _buildBenefitBadge(Icons.call, voiceSummary, Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.3),
                  ),

                  // Structured Benefit Badges (OTT, 5G, etc.)
                  if (benefits.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: benefits.take(2).map((b) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            b['value_text'] ?? b['benefit_type']?['name'] ?? '',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Bottom Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Create plan selection snapshot before proceeding
                        String? selectionId;
                        if (offerId != null) {
                          final repo = ref.read(rechargeRepositoryProvider);
                          final snap = await repo.createPlanSelection(offerId: offerId is int ? offerId : int.parse(offerId.toString()), amount: amountVal.toStringAsFixed(2));
                          selectionId = snap?['selection_id'];
                        }

                        if (!context.mounted) return;
                        context.push('/payment/review', extra: {
                          'title': isDth ? 'DTH Recharge' : 'Mobile Recharge',
                          'subtitle': displayName,
                          'amount': amountVal,
                          'plan_selection_id': selectionId,
                          'operatorCode': ref.read(rechargeStateProvider).operatorCode,
                          'circle': ref.read(rechargeStateProvider).circle,
                          'mobileNumber': widget.mobileNumber,
                          'baseAmount': amountVal,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Recharge with this Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBenefitBadge(IconData icon, String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.shade700),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color.shade800)),
        ],
      ),
    );
  }
}
