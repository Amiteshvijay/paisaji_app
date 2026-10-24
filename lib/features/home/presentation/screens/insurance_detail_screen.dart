import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/home/data/insurance_data.dart';

class InsuranceDetailScreen extends StatelessWidget {
  final InsuranceItem insurance;

  const InsuranceDetailScreen({
    super.key,
    required this.insurance,
  });

  Future<void> _launchApplyUrl(BuildContext context) async {
    try {
      final uri = Uri.parse(insurance.applyUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open insurance partner link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          insurance.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Open in Browser',
            icon: const Icon(Icons.open_in_new, color: Colors.white70),
            onPressed: () => _launchApplyUrl(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Realistic Hero Showcase Card
                    _buildHeroCard(context),

                    const SizedBox(height: 16),

                    // 2. Trust Badges Row
                    _buildTrustBadgesRow(),

                    const SizedBox(height: 20),

                    // 3. Key Highlights Grid
                    _buildSectionHeader('Key Highlights', Icons.stars_rounded),
                    const SizedBox(height: 10),
                    _buildHighlightsGrid(),

                    const SizedBox(height: 24),

                    // 4. Bullet Perks / Features List
                    _buildSectionHeader('Policy Features & Coverage', Icons.verified_user_outlined),
                    const SizedBox(height: 10),
                    _buildBulletPerksList(),

                    const SizedBox(height: 24),

                    // 5. Detailed Coverage Breakdown
                    _buildSectionHeader('What is Covered', Icons.shield_outlined),
                    const SizedBox(height: 10),
                    _buildCoverageBreakdownCard(),

                    const SizedBox(height: 24),

                    // 6. Simple 3-Step Process
                    _buildSectionHeader('Simple 3-Step Process', Icons.touch_app_outlined),
                    const SizedBox(height: 10),
                    _buildHowItWorksCard(),

                    const SizedBox(height: 24),

                    // 7. Regulatory & Partner Disclaimer
                    _buildDisclaimerCard(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA Bar
            _buildStickyBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            insurance.accentColor.withValues(alpha: 0.35),
            const Color(0xFF1E293B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: insurance.accentColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: insurance.accentColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  insurance.badgeText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.verified, size: 18, color: AppTheme.success),
                  const SizedBox(width: 4),
                  Text(
                    insurance.provider,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Icon(insurance.icon, size: 36, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insurance.title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insurance.tagline,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on, size: 16, color: Colors.amberAccent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    insurance.benefit,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadgesRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBadgeItem(Icons.car_repair, insurance.cashlessGaragesOrHospitals, 'Cashless Network'),
          Container(width: 1, height: 28, color: Colors.white12),
          _buildBadgeItem(Icons.thumb_up_alt_outlined, insurance.claimsRatio, 'Claims Settlement'),
          Container(width: 1, height: 28, color: Colors.white12),
          _buildBadgeItem(Icons.bolt, '100% Digital', 'Instant Issuance'),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.cyanAccent),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 10, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: insurance.keyHighlights.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.8,
      ),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insurance.keyHighlights[index],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBulletPerksList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: insurance.bulletPerks.map((perk) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified, size: 18, color: Color(0xFF38BDF8)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    perk,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCoverageBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: insurance.coverageDetails.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                const Icon(Icons.shield, size: 16, color: Colors.greenAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHowItWorksCard() {
    final steps = [
      {'step': '1', 'title': 'Click "${insurance.ctaText}"', 'desc': 'Navigate directly to our verified partner portal.'},
      {'step': '2', 'title': 'Enter Vehicle Number', 'desc': 'View pre-calculated quotes, adjust IDV & choose add-ons.'},
      {'step': '3', 'title': 'Instant Policy Delivery', 'desc': 'Pay securely and receive your policy on WhatsApp & Email.'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: steps.map((s) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: insurance.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    s['step']!,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['title']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(s['desc']!, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.white60),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Insurance policies are solicited and underwritten by IRDAI-registered insurance companies. Paisaजी acts as a technology facilitator partnering with BankSathi.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: const Border(
          top: BorderSide(color: Colors.white12, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  insurance.startingPrice,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '100% Paperless • 2 Min Issuance',
                  style: TextStyle(fontSize: 10, color: Colors.white60),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: ElevatedButton.icon(
              onPressed: () => _launchApplyUrl(context),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(
                insurance.ctaText,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: insurance.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
