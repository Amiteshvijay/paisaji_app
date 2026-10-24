import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/loyalty_provider.dart';
import '../services/loyalty_api_service.dart';
import '../widgets/coupon_card.dart';

class CouponWalletScreen extends ConsumerStatefulWidget {
  const CouponWalletScreen({super.key});

  @override
  ConsumerState<CouponWalletScreen> createState() => _CouponWalletScreenState();
}

class _CouponWalletScreenState extends ConsumerState<CouponWalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(loyaltyCouponsProvider('ISSUED'));
    ref.invalidate(loyaltyCouponsProvider('CLAIMED'));
    ref.invalidate(loyaltyCouponsProvider('EXPIRED'));
    ref.invalidate(loyaltyMeProvider);
  }

  Future<void> _redeem(int id) async {
    try {
      final api = ref.read(loyaltyApiServiceProvider);
      await api.redeemCoupon(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coupon redeemed successfully!')),
        );
        _refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error redeeming coupon: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Coupon Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A2342),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF3B82F6),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Available'),
            Tab(text: 'Used'),
            Tab(text: 'Expired'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCouponList('ISSUED'),
          _buildCouponList('CLAIMED'),
          _buildCouponList('EXPIRED'),
        ],
      ),
    );
  }

  Widget _buildCouponList(String status) {
    final couponsAsync = ref.watch(loyaltyCouponsProvider(status));

    return couponsAsync.when(
      data: (coupons) {
        if (coupons.isEmpty) {
          return Center(
            child: Text(
              'No ${status.toLowerCase()} coupons found.',
              style: const TextStyle(color: Colors.white60, fontSize: 15),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView.builder(
            itemCount: coupons.length,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              return CouponCard(
                coupon: coupon,
                onRedeem: status == 'ISSUED' ? () => _redeem(coupon.id) : null,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text('Error loading coupons: $err', style: const TextStyle(color: Colors.redAccent)),
      ),
    );
  }
}
