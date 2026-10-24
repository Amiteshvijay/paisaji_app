import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeokash/features/recommendations/data/recommendation_model.dart';
import 'package:zeokash/features/recommendations/presentation/widgets/coupon_code_widget.dart';

class Meal4UOfferBanner extends StatelessWidget {
  final PromotionalCampaign campaign;
  final VoidCallback? onBuyNow;

  const Meal4UOfferBanner({
    super.key,
    required this.campaign,
    this.onBuyNow,
  });

  Future<void> _launchMeal4U(BuildContext context) async {
    final uri = Uri.parse('https://meal4u.in/');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open https://meal4u.in/')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error launching MEAL4U')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF81C784)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'MEAL4U PARTNER OFFER',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const Icon(Icons.restaurant_menu, color: Color(0xFF16A34A), size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            campaign.campaignTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B5E20)),
          ),
          const SizedBox(height: 6),
          Text(
            campaign.campaignDescription ?? 'Fresh healthy bowls and juices delivered to your doorstep.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CouponCodeWidget(couponCode: campaign.couponCode, label: 'Use Code'),
              ElevatedButton(
                onPressed: () {
                  if (onBuyNow != null) {
                    onBuyNow!();
                  }
                  _launchMeal4U(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Order Now', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
