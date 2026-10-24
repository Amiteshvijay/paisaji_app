import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/payments/data/recharge_repository.dart';
import 'package:zeokash/features/rewards/providers/scratch_card_provider.dart';
import 'package:zeokash/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:zeokash/features/zeocoins/data/zeocoin_repository.dart';
import 'package:zeokash/features/zeocoins/presentation/providers/zeocoin_provider.dart';

class PaymentProcessingScreen extends ConsumerStatefulWidget {
  final String title;
  final double amount;
  final double? coinsRedeemed;
  final double? baseAmount;
  final double? instantDiscount;
  final double? zeocoinDiscount;
  final String? mobileNumber;
  final String? operatorCode;
  final String? circle;
  final String? serviceType;

  const PaymentProcessingScreen({
    super.key,
    required this.title,
    required this.amount,
    this.coinsRedeemed,
    this.baseAmount,
    this.instantDiscount,
    this.zeocoinDiscount,
    this.mobileNumber,
    this.operatorCode,
    this.circle,
    this.serviceType,
  });

  @override
  ConsumerState<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends ConsumerState<PaymentProcessingScreen> {
  String _statusMessage = 'Processing payment securely...';

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  Future<void> _processPayment() async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    String txRef = 'ZK$nowMs';
    bool isRechargeSuccess = true;
    String? errorMessage;

    // 1. If coins were redeemed, execute redemption on backend
    if (widget.coinsRedeemed != null && widget.coinsRedeemed! > 0) {
      try {
        final repo = ref.read(zeocoinRepositoryProvider);
        await repo.executeRedemption(widget.coinsRedeemed!, txRef);
        ref.invalidate(zeocoinWalletProvider);
        ref.invalidate(zeocoinLedgerProvider);
        ref.invalidate(rewardSummaryProvider);
      } catch (e) {
        debugPrint('Coin redemption execution failed: $e');
      }
    }

    // 2. If this is a Recharge payment (mobile or DTH), invoke backend API to execute provider recharge
    if (widget.mobileNumber != null && widget.mobileNumber!.isNotEmpty) {
      setState(() {
        _statusMessage = 'Connecting with telecom operator...';
      });

      try {
        final rechargeRepo = ref.read(rechargeRepositoryProvider);
        final rechargeResult = await rechargeRepo.createAndFulfillRechargeOrder(
          mobileNumber: widget.mobileNumber!,
          operatorCode: widget.operatorCode ?? 'AIRTEL',
          amount: widget.baseAmount ?? widget.amount,
          circle: widget.circle,
          serviceType: widget.serviceType ?? 'MOBILE_RECHARGE',
        );

        // Update txRef with official backend reference (e.g. ZK...)
        if (rechargeResult['reference'] != null) {
          txRef = rechargeResult['reference'].toString();
        } else if (rechargeResult['order']?['external_reference'] != null) {
          txRef = rechargeResult['order']['external_reference'].toString();
        }

        final orderStatus = (rechargeResult['order_status'] ?? rechargeResult['order']?['status'] ?? '').toString().toUpperCase();
        if (orderStatus == 'FAILED') {
          isRechargeSuccess = false;
          errorMessage = rechargeResult['order']?['failure_reason'] ?? 'Recharge failed at operator gateway';
        }
      } catch (e) {
        debugPrint('Recharge backend execution error: $e');
        // If network error occurred, still report for history polling
      }
    }

    // Invalidate wallet and history providers to refresh recent transactions list
    ref.invalidate(walletTransactionsProvider(null));
    ref.invalidate(walletDataProvider);

    // Small animation delay for smooth UI transition
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      if (isRechargeSuccess) {
        context.pushReplacement('/payment/success', extra: {
          'title': widget.title,
          'amount': widget.amount,
          'reference': txRef,
          'coinsRedeemed': widget.coinsRedeemed,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Recharge could not be processed. If deducted, refund will be credited.'),
            backgroundColor: AppTheme.error,
          ),
        );
        context.pushReplacement('/payment/receipt', extra: {
          'title': widget.title,
          'amount': widget.amount,
          'reference': txRef,
          'status': 'FAILED',
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 32),
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please do not close the app or hit back.',
              style: TextStyle(color: AppTheme.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
