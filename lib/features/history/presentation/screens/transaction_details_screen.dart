import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/payments/services/receipt_pdf_service.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/buttons/secondary_button.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  void _showDownloadReceiptOptions(
    BuildContext context, {
    required String title,
    required String ref,
    required double amount,
    required String displayAmount,
    required String date,
    required String type,
    required bool isSuccess,
    required bool isReward,
    String? cleanTitle,
    String? operatorName,
    String? circle,
    String? planName,
    String? consumerMobile,
    double? baseAmount,
    double? instantDiscount,
    double? gCoinDiscount,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Transaction Receipt',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ref: $ref',
                  style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long, color: AppTheme.primaryBlue),
                  ),
                  title: const Text('View Full Digital Receipt', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Inspect verified payment voucher & biller details', style: TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                  onTap: () {
                    Navigator.pop(modalContext);
                    context.push('/payment/receipt', extra: {
                      'title': cleanTitle,
                      'amount': amount,
                      'reference': ref,
                      'date': date,
                      'type': type,
                      'status': isSuccess ? 'SUCCESS' : 'FAILED',
                      'paymentMode': 'PaisaJi Secure Wallet / UPI',
                      'merchant': 'PaisaJi Verified Gateway',
                      'operatorName': operatorName,
                      'circle': circle,
                      'planName': planName,
                      'mobileNumber': consumerMobile,
                      'baseAmount': baseAmount,
                      'instantDiscount': instantDiscount,
                      'gCoinDiscount': gCoinDiscount,
                    });
                  },
                ),
                const Divider(color: AppTheme.border, height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.primaryBlue),
                  ),
                  title: const Text('Download / Share PDF Receipt', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Official formatted PDF invoice with complete discount breakdown', style: TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                  onTap: () async {
                    Navigator.pop(modalContext);
                    ReceiptPdfService.downloadOrShareReceipt(
                      context,
                      title: cleanTitle ?? title,
                      amount: amount,
                      reference: ref,
                      date: date,
                      status: isSuccess ? 'SUCCESS' : 'FAILED',
                      paymentMode: isReward ? 'PaisaJi Rewards' : 'PaisaJi Secure Wallet / UPI',
                      merchant: 'PaisaJi Verified Gateway',
                      operatorName: operatorName,
                      circle: circle,
                      planName: planName,
                      mobileNumber: consumerMobile,
                      baseAmount: baseAmount,
                      instantDiscount: instantDiscount,
                      gCoinDiscount: gCoinDiscount,
                    );
                  },
                ),
                const Divider(color: AppTheme.border, height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.print_outlined, color: AppTheme.primaryBlue),
                  ),
                  title: const Text('Print Receipt / Save Document', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Print directly via airprint or standard PDF print dialog', style: TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                  onTap: () async {
                    Navigator.pop(modalContext);
                    ReceiptPdfService.printReceipt(
                      title: cleanTitle ?? title,
                      amount: amount,
                      reference: ref,
                      date: date,
                      status: isSuccess ? 'SUCCESS' : 'FAILED',
                      paymentMode: isReward ? 'PaisaJi Rewards' : 'PaisaJi Secure Wallet / UPI',
                      merchant: 'PaisaJi Verified Gateway',
                      operatorName: operatorName,
                      circle: circle,
                      planName: planName,
                      mobileNumber: consumerMobile,
                      baseAmount: baseAmount,
                      instantDiscount: instantDiscount,
                      gCoinDiscount: gCoinDiscount,
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGetHelpOptions(
    BuildContext context, {
    required String title,
    required String ref,
    required String displayAmount,
    required String date,
    required String type,
    required bool isSuccess,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Support & Help',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Need assistance with this transaction? Contact PaisaJi Support 24x7.',
                  style: TextStyle(color: AppTheme.secondaryText, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                  ),
                  title: const Text('Chat with WhatsApp Support', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('+91 8448302749 (Quick resolution in minutes)', style: TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                  onTap: () async {
                    Navigator.pop(modalContext);
                    final message = Uri.encodeComponent(
                      'Hello PaisaJi Support Team,\n\nI need help regarding this transaction:\n'
                      '- Reference ID: $ref\n'
                      '- Service: $title\n'
                      '- Amount: $displayAmount\n'
                      '- Date: $date\n'
                      '- Status: ${isSuccess ? 'Success' : 'Failed'}\n\n'
                      'Please check and assist me.'
                    );
                    final uri = Uri.parse('https://wa.me/918448302749?text=$message');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open WhatsApp. Please WhatsApp to +91 8448302749')),
                        );
                      }
                    }
                  },
                ),
                const Divider(color: AppTheme.border, height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mail_outline, color: Colors.teal),
                  ),
                  title: const Text('Email Support Desk', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('support@paisaji.com (Official grievance desk)', style: TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                  onTap: () async {
                    Navigator.pop(modalContext);
                    final subject = Uri.encodeComponent('Help with Transaction $ref');
                    final body = Uri.encodeComponent(
                      'Hello PaisaJi Support,\n\nI need help regarding this transaction:\n'
                      '- Reference ID: $ref\n'
                      '- Service: $title\n'
                      '- Amount: $displayAmount\n'
                      '- Date: $date\n'
                      '- Status: ${isSuccess ? 'Success' : 'Failed'}\n\n'
                      'Description of issue:\n\n'
                    );
                    final uri = Uri.parse('mailto:support@paisaji.com?subject=$subject&body=$body');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please contact support@paisaji.com')),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleTryAgain(BuildContext context, String type) {
    final typeLower = type.toLowerCase();
    if (typeLower.contains('recharge') || typeLower.contains('mobile')) {
      context.push('/recharge/mobile');
    } else if (typeLower.contains('dth')) {
      context.push('/recharge/dth');
    } else if (typeLower.contains('electricity')) {
      context.push('/electricity/providers');
    } else if (typeLower.contains('fastag')) {
      context.push('/fastag/providers');
    } else if (typeLower.contains('credit')) {
      context.push('/credit-card/providers');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = transaction['isSuccess'] as bool? ?? true;
    final dynamic rawAmount = transaction['amount'];
    final double amount = (rawAmount is num) ? rawAmount.toDouble() : double.tryParse(rawAmount?.toString() ?? '') ?? 0.0;
    final title = transaction['title']?.toString() ?? 'Transaction';
    final date = transaction['date']?.toString() ?? '';
    final ref = transaction['ref']?.toString() ?? '';
    final type = transaction['type']?.toString() ?? '';
    final isReward = transaction['isReward'] == true || type.toUpperCase().contains('REWARD');

    // Clean service title
    String cleanTitle = title;
    if (cleanTitle.contains('for MOBILE_RECHARGE') || cleanTitle.toLowerCase().contains('wallet spend')) {
      cleanTitle = 'Mobile Prepaid Recharge';
    }

    String operatorName = transaction['operatorName']?.toString() ?? transaction['operator']?.toString() ?? '';
    if (operatorName.isEmpty) {
      final l = title.toLowerCase();
      if (l.contains('airtel')) {
        operatorName = 'Airtel';
      } else if (l.contains('jio')) {
        operatorName = 'Jio';
      } else if (l.contains('vi')) {
        operatorName = 'Vi';
      } else if (l.contains('bsnl')) {
        operatorName = 'BSNL';
      } else {
        operatorName = 'Airtel';
      }
    }

    String circle = transaction['circle']?.toString() ?? 'Delhi NCR';
    String planName = transaction['planName']?.toString() ?? 'Prepaid Recharge Plan';
    String consumerMobile = transaction['mobileNumber']?.toString() ?? transaction['mobile']?.toString() ?? '';
    if (consumerMobile.isEmpty) {
      final match = RegExp(r'(\+?91)?[6-9]\d{9}').firstMatch(title);
      consumerMobile = match != null ? match.group(0)! : '+91 8448302749';
    }

    // Breakdown derivation: Recharge 10 -> Disc 0.10, Gcoin 0.50, Net 9.40
    final breakdown = ReceiptPdfService.deriveRechargeBreakdown(
      amount,
      operatorName: operatorName,
      baseAmount: (transaction['baseAmount'] as num?)?.toDouble() ?? (transaction['planAmount'] as num?)?.toDouble(),
      instantDiscount: (transaction['instantDiscount'] as num?)?.toDouble(),
      gCoinDiscount: (transaction['gCoinDiscount'] as num?)?.toDouble() ?? (transaction['zeocoinDiscount'] as num?)?.toDouble(),
    );
    final discountPct = ReceiptPdfService.getOperatorDiscountPercentText(operatorName);

    final double baseAmount = breakdown['planAmount']!;
    final double instantDiscount = breakdown['instantDiscount']!;
    final double gCoinDiscount = breakdown['gCoinDiscount']!;
    final double netAmount = breakdown['netPaid']!;

    final lowerTitle = title.toLowerCase();
    final isRechargeOrBill = lowerTitle.contains('recharge') ||
        lowerTitle.contains('airtel') ||
        lowerTitle.contains('jio') ||
        lowerTitle.contains('vi') ||
        lowerTitle.contains('bsnl') ||
        lowerTitle.contains('dth') ||
        type.toLowerCase().contains('recharge');

    final hasBreakdown = isRechargeOrBill;
    final isReversal = type.toUpperCase() == 'REFUND' ||
        title.toLowerCase().contains('reversal') ||
        ref.toLowerCase().contains('reversal');

    String statusTitle;
    if (!isSuccess) {
      statusTitle = 'Transaction Failed';
    } else if (isReversal) {
      statusTitle = 'Coins Reversed';
    } else if (isReward) {
      statusTitle = 'Reward Credited';
    } else {
      statusTitle = 'Payment Successful';
    }

    String cleanRef = ref;
    final parenMatch = RegExp(r'\(([^)]+)\)').firstMatch(ref);
    if (parenMatch != null && parenMatch.group(1) != null) {
      cleanRef = parenMatch.group(1)!;
    }

    final amtFormatted = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    final displayAmount = isReward ? '$amtFormatted G Coins' : '₹$amtFormatted';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              isReward
                  ? Container(
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFDE68A), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD97706).withValues(alpha: 0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/rewards/g_coins/64/g_coin_01.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.stars_rounded,
                          color: Color(0xFFD97706),
                          size: 44,
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSuccess ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSuccess ? Icons.check_circle : Icons.error,
                        color: isSuccess ? AppTheme.success : AppTheme.error,
                        size: 48,
                      ),
                    ),
              const SizedBox(height: 14),
              Text(
                statusTitle,
                style: TextStyle(
                  color: isSuccess ? (isReversal ? const Color(0xFFB45309) : AppTheme.success) : AppTheme.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              isReward
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          amount == amount.roundToDouble() ? '${amount.toInt()}' : amount.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: const Color(0xFF92400E),
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/rewards/g_coins/64/g_coin_01.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Text(
                            'G Coins',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    )
                  : Text(displayAmount, style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15), textAlign: TextAlign.center),

              // Complete Recharge Plan & Discount Breakdown Card
              if (hasBreakdown) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Payment & Plan Breakdown',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Discounts Applied',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildBreakdownRow(
                        label: 'Recharge Plan Amount',
                        amountText: '₹${baseAmount.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                      if (instantDiscount > 0) ...[
                        const SizedBox(height: 8),
                        _buildBreakdownRow(
                          label: 'Instant Discount ($discountPct)',
                          amountText: '-₹${instantDiscount.toStringAsFixed(2)}',
                          valueColor: AppTheme.success,
                          leadingIcon: Icons.local_offer_outlined,
                        ),
                      ],
                      if (gCoinDiscount > 0) ...[
                        const SizedBox(height: 8),
                        _buildBreakdownRow(
                          label: 'G Coins Discount (5%)',
                          amountText: '-₹${gCoinDiscount.toStringAsFixed(2)}',
                          valueColor: Colors.amber.shade800,
                          leadingIcon: Icons.stars_rounded,
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: AppTheme.border, height: 1),
                      ),
                      _buildBreakdownRow(
                        label: 'Total Net Paid (Wallet Deducted)',
                        amountText: '₹${netAmount.toStringAsFixed(2)}',
                        isBold: true,
                        valueColor: AppTheme.primaryBlue,
                        fontSize: 15,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Date & Time', date),
                    const Divider(color: AppTheme.border, height: 1),
                    _buildDetailRow('Reference ID', cleanRef),
                    const Divider(color: AppTheme.border, height: 1),
                    _buildDetailRow('Category', isReversal ? 'G Coin Reversal' : (isReward ? 'G Coin Reward' : (type.isNotEmpty ? type : 'Payment'))),
                    if (hasBreakdown) ...[
                      const Divider(color: AppTheme.border, height: 1),
                      _buildDetailRow('Recharge Plan', '₹${baseAmount.toStringAsFixed(2)}'),
                    ],
                    if (!isSuccess) ...[
                      const Divider(color: AppTheme.border, height: 1),
                      _buildDetailRow('Status', 'Failed'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (isSuccess)
                SecondaryButton(
                  text: 'Download Receipt',
                  onPressed: () {
                    _showDownloadReceiptOptions(
                      context,
                      title: title,
                      ref: ref,
                      amount: amount,
                      displayAmount: displayAmount,
                      date: date,
                      type: type,
                      isSuccess: isSuccess,
                      isReward: isReward,
                      cleanTitle: cleanTitle,
                      operatorName: operatorName,
                      circle: circle,
                      planName: planName,
                      consumerMobile: consumerMobile,
                      baseAmount: baseAmount,
                      instantDiscount: instantDiscount,
                      gCoinDiscount: gCoinDiscount,
                    );
                  },
                )
              else
                PrimaryButton(
                  text: 'Try Again',
                  onPressed: () => _handleTryAgain(context, type),
                ),
              const SizedBox(height: 14),
              SecondaryButton(
                text: 'Get Help',
                onPressed: () {
                  _showGetHelpOptions(
                    context,
                    title: title,
                    ref: ref,
                    displayAmount: displayAmount,
                    date: date,
                    type: type,
                    isSuccess: isSuccess,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow({
    required String label,
    required String amountText,
    bool isBold = false,
    Color? valueColor,
    IconData? leadingIcon,
    double fontSize = 13.5,
  }) {
    return Row(
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 16, color: valueColor ?? AppTheme.secondaryText),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: isBold ? AppTheme.primaryText : AppTheme.secondaryText,
            ),
          ),
        ),
        Text(
          amountText,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isBold ? AppTheme.primaryText : AppTheme.secondaryText),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.secondaryText)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

