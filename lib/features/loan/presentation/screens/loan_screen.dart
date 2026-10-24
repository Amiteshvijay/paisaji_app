import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/loan/presentation/screens/loan_detail_screen.dart';

class LoanPartnerOffer {
  final String id;
  final String name;
  final String subtitle;
  final String yearlyInterest;
  final double flatRatePercent;
  final double maxLimit;
  final String applyUrl;
  final String? badge;
  final IconData icon;
  final Color brandColor;
  final String eligibility;
  final String documents;
  final List<String> features;

  const LoanPartnerOffer({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.yearlyInterest,
    required this.flatRatePercent,
    required this.maxLimit,
    required this.applyUrl,
    this.badge,
    required this.icon,
    required this.brandColor,
    required this.eligibility,
    required this.documents,
    required this.features,
  });

  int calculateEmi(double principal, int tenureMonths) {
    if (tenureMonths <= 0) return 0;
    final totalInterest = principal * (flatRatePercent / 100.0) * (tenureMonths / 12.0);
    final totalPayable = principal + totalInterest;
    return (totalPayable / tenureMonths).round();
  }

  // Convert to LoanOffer for LoanDetailScreen with unique description
  LoanOffer toLoanOffer() {
    return LoanOffer(
      title: name,
      subtitle: subtitle,
      maxAmount: 'Up to ₹${(maxLimit / 100000).toStringAsFixed(0)} Lakhs',
      eligibility: eligibility,
      documents: documents,
      features: features,
      applyUrl: applyUrl,
      icon: icon,
      color: brandColor,
      partnerName: name,
    );
  }
}

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  static const double _minLoan = 5000;
  static const double _maxLoan = 500000;
  static const double _step = 10000;

  double _loanAmount = 100000;
  int _selectedDuration = 12;

  final List<int> _durations = [6, 9, 12, 18, 24, 36, 48];

  final List<LoanPartnerOffer> _offers = const [
    LoanPartnerOffer(
      id: 'credit91_standard',
      name: 'Credit91 Personal Loan',
      subtitle: 'Need Funds? Check Your Loan Eligibility Online!',
      yearlyInterest: '14.5%',
      flatRatePercent: 6.8,
      maxLimit: 200000,
      applyUrl: 'https://leads.banksathi.com/?h=c2NIcGsvV2pwZW8rNkFreHFRTnEvQT09',
      badge: 'Recommended',
      icon: Icons.bolt,
      brandColor: Color(0xFF1E3A8A),
      eligibility: 'Age 21–55 | Salaried / Working Individuals | Regular Income',
      documents: 'PAN Card, Aadhaar/KYC & Bank Details',
      features: [
        'Quick & Easy Application Process',
        '100% Online & Digital Verification',
        'Transparent Loan Offers with No Hidden Fees',
        'Secure KYC & Instant Approval',
        'EMI & Charges Shown Before Acceptance',
        'Loans through Regulated Lending Partners'
      ],
    ),
    LoanPartnerOffer(
      id: 'stashfin',
      name: 'Stashfin Personal Loan',
      subtitle: 'Digital & hassle-free personal credit line',
      yearlyInterest: '13.5%',
      flatRatePercent: 6.2,
      maxLimit: 500000,
      applyUrl: 'https://leads.banksathi.com/?h=UFM4cStaU3RIUFFQbUtibTdvSUhxZz09',
      badge: 'Instant Disbursal',
      icon: Icons.account_balance_wallet_outlined,
      brandColor: Color(0xFF4338CA),
      eligibility: 'Age 21–60 | Salaried / Self-Employed Individuals',
      documents: 'PAN Card, Aadhaar & Income Proof',
      features: [
        'Loan up to ₹5 Lakh Credit Line',
        '100% Digital & Hassle-Free Process',
        'No Collateral or Security Required',
        'Flexible Tenure up to 48 Months',
        'Instant Disbursal directly to Bank Account'
      ],
    ),
    LoanPartnerOffer(
      id: 'poonawalla',
      name: 'Poonawalla Fincorp',
      subtitle: 'Quick approval & zero hidden charges',
      yearlyInterest: '15.0%',
      flatRatePercent: 7.0,
      maxLimit: 500000,
      applyUrl: 'https://leads.banksathi.com/?h=Q0xOcnZYampEUHg3a20vYjVBWVIxZz09',
      badge: 'Zero Hidden Charges',
      icon: Icons.verified_user_outlined,
      brandColor: Color(0xFF1E293B),
      eligibility: 'Age 21–60 | Salaried / Self-Employed Professionals',
      documents: 'PAN, Aadhaar & Bank Statements',
      features: [
        'Quick Approval – No long waits',
        'Zero Hidden Charges – 100% transparency',
        'Collateral-Free Loan – No security needed',
        'Minimal Documentation – Hassle-free process',
        'No Foreclosure Charges – Close anytime without penalty'
      ],
    ),
    LoanPartnerOffer(
      id: 'tatanew',
      name: 'Tata Neu Personal Loan',
      subtitle: 'Turn dreams into reality with Tata Neu!',
      yearlyInterest: '12.5%',
      flatRatePercent: 5.8,
      maxLimit: 500000,
      applyUrl: 'https://leads.banksathi.com/?h=b29pNTJSWG5PWmkybGk2c0hubXVNdz09',
      badge: '10 Mins Approval',
      icon: Icons.star_outline,
      brandColor: Color(0xFF003366),
      eligibility: 'Age 21–60 | Salaried Professionals & Regular Earners',
      documents: 'PAN, Aadhaar & Income Proof',
      features: [
        'Get funds in just 10 minutes ⏳',
        '100% Digital & Paperless 📲',
        'Higher Loan Amount up to ₹10 Lakhs 💸',
        'Affordable Interest Rates & Flexible EMI'
      ],
    ),
    LoanPartnerOffer(
      id: 'hdfccash',
      name: 'HDFC CC Instant Loan',
      subtitle: 'Get a Loan on Your HDFC Credit Card – Instantly!',
      yearlyInterest: '11.0%',
      flatRatePercent: 5.2,
      maxLimit: 500000,
      applyUrl: 'https://leads.banksathi.com/?h=Tzd5UnhTeGt4OTZvMnNaTU1kTFQyQT09',
      badge: 'Pre-Approved',
      icon: Icons.credit_card,
      brandColor: Color(0xFF004C8F),
      eligibility: 'HDFC Credit Card Holder with Pre-approved Offer',
      documents: 'Zero Documentation – 100% Hassle-Free',
      features: [
        'Instant money credited within seconds',
        'Attractive & personalized interest rates',
        'Flexible tenure: 12 to 60 months',
        'Easy EMIs for stress-free repayment',
        'Zero documentation – 100% hassle-free'
      ],
    ),
    LoanPartnerOffer(
      id: 'credit91_quick',
      name: 'Credit91 Quick Cash',
      subtitle: 'Minimal documentation & direct bank disbursal',
      yearlyInterest: '16.0%',
      flatRatePercent: 7.5,
      maxLimit: 200000,
      applyUrl: 'https://leads.banksathi.com/?h=Vko4NnJOL1llWGNnOXVwVlN1WnpTZz09',
      icon: Icons.flash_on,
      brandColor: Color(0xFF0F172A),
      eligibility: 'Age 21–55 | Salaried / Working Individuals',
      documents: 'PAN, Aadhaar/KYC & Bank Details',
      features: [
        'Quick & Easy Online Process',
        'Minimal Documentation Required',
        'Flexible Repayment Options',
        'Secure KYC & Verification',
        'Direct Bank Disbursal'
      ],
    ),
    LoanPartnerOffer(
      id: 'herofincorp',
      name: 'Hero Fincorp',
      subtitle: 'Quick, easy loans with Hero Fincorp',
      yearlyInterest: '18.0%',
      flatRatePercent: 8.2,
      maxLimit: 500000,
      applyUrl: 'https://leads.banksathi.com/?h=T1RaRjh6MzVQRUVyYXhiNzEzdTlzdz09',
      icon: Icons.motorcycle_outlined,
      brandColor: Color(0xFFDC2626),
      eligibility: 'Age 21–58 | Salaried / Self-Employed',
      documents: 'PAN, Aadhaar & Income Proof',
      features: [
        'Quick, easy loans up to ₹5,00,000',
        'Avail collateral-free loans',
        '100% digital and paperless process',
        'Direct bank transfer upon approval'
      ],
    ),
    LoanPartnerOffer(
      id: 'instamoney',
      name: 'InstaMoney Personal Loan',
      subtitle: 'Quick Solution to Quicker Needs!',
      yearlyInterest: '21.0%',
      flatRatePercent: 9.5,
      maxLimit: 100000,
      applyUrl: 'https://leads.banksathi.com/?h=cGZxRGJ4MjQ0L2t6VFBZRzNhNmJDdz09',
      badge: '2-Hour Disbursal',
      icon: Icons.speed,
      brandColor: Color(0xFF0284C7),
      eligibility: 'Age 21–55 | Salaried Individuals',
      documents: 'PAN, Aadhaar & Bank Statement',
      features: [
        'Fast Disbursal – Get money in as little as 2 hours',
        '100% Digital Process – Apply anytime, anywhere',
        'Flexible Loan Tenure – Choose a tenure that suits you',
        'Direct Bank Transfer – Amount credited directly',
        'Pay Interest Only on What You Withdraw'
      ],
    ),
    LoanPartnerOffer(
      id: 'payme',
      name: 'PayMe Personal Loan',
      subtitle: 'PAYME PERSONAL LOAN IS LIVE! 🔥',
      yearlyInterest: '22.0%',
      flatRatePercent: 10.0,
      maxLimit: 500000,
      applyUrl: 'https://leads.banksathi.com/?h=UXRDRW41K05vOUcwWDNQcWRUSmlOUT09',
      icon: Icons.payments_outlined,
      brandColor: Color(0xFF16A34A),
      eligibility: 'Age 21–55 | Salaried Individuals',
      documents: 'PAN, Aadhaar & Income Proof',
      features: [
        'Quick & Easy Application',
        '100% Digital Process',
        'Minimal Paperwork',
        'Fast Loan Processing'
      ],
    ),
    LoanPartnerOffer(
      id: 'nira',
      name: 'NIRA Instant Loan',
      subtitle: 'Get instant personal loan in 3 easy steps',
      yearlyInterest: '24.0%',
      flatRatePercent: 11.0,
      maxLimit: 100000,
      applyUrl: 'https://leads.banksathi.com/?h=UG9BTDB4aFZ2LzFIZEV6UGsvVkkyQT09',
      icon: Icons.layers_outlined,
      brandColor: Color(0xFF9333EA),
      eligibility: 'Age 21–55 | Salaried / Self-Employed',
      documents: 'PAN & Bank Statements',
      features: [
        'Get instant approval NIRA instant loan app',
        'Upload docs to complete the process',
        'Setup auto-debit and avail credit',
        'Voila! Your Loan is Approved!'
      ],
    ),
    LoanPartnerOffer(
      id: 'b4salary',
      name: 'B4Salary Personal Loan',
      subtitle: 'Quick approval up to ₹1,00,000',
      yearlyInterest: '20.0%',
      flatRatePercent: 9.0,
      maxLimit: 100000,
      applyUrl: 'https://leads.banksathi.com/?h=UW03VE9EQy9yaDJiU2JxeDUrdkpVQT09',
      icon: Icons.schedule,
      brandColor: Color(0xFFEA580C),
      eligibility: 'Salaried Individuals with Regular Income',
      documents: 'PAN, Aadhaar & Salary Slips',
      features: [
        'Quick Approval – No long waits',
        'Zero Hidden Charges – 100% transparency',
        'Collateral-Free Loan – No security needed',
        'Minimal Documentation – Hassle-free process',
        'No Foreclosure Charges – Close anytime without penalty'
      ],
    ),
  ];

  String _formatIndianCurrency(num amount) {
    final int val = amount.round();
    final String s = val.toString();
    if (s.length <= 3) return '₹$s';
    final String lastThree = s.substring(s.length - 3);
    final String otherDigits = s.substring(0, s.length - 3);
    final StringBuffer formatted = StringBuffer();
    for (int i = 0; i < otherDigits.length; i++) {
      if (i > 0 && (otherDigits.length - i) % 2 == 0) {
        formatted.write(',');
      }
      formatted.write(otherDigits[i]);
    }
    return '₹${formatted.toString()},$lastThree';
  }

  void _incrementLoan() {
    setState(() {
      _loanAmount = math.min(_maxLoan, _loanAmount + _step);
    });
  }

  void _decrementLoan() {
    setState(() {
      _loanAmount = math.max(_minLoan, _loanAmount - _step);
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open loan application link.')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error launching application link.')),
        );
      }
    }
  }

  void _showHelpBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personal Loan Features',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureBullet(Icons.check_circle_outline, 'Loan Amount up to ₹5 Lakhs'),
            _buildFeatureBullet(Icons.check_circle_outline, '100% Digital & Paperless Process'),
            _buildFeatureBullet(Icons.check_circle_outline, 'Quick & Easy Application'),
            _buildFeatureBullet(Icons.check_circle_outline, 'Flexible Tenure (6 to 48 Months)'),
            _buildFeatureBullet(Icons.timer_outlined, 'Instant Disbursal via BankSathi Partners'),
            _buildFeatureBullet(Icons.verified_user_outlined, 'No Collateral Required'),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _launchUrl(_offers.first.applyUrl);
              },
              child: const Text('Apply Now (Up to ₹5L)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBullet(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.success, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.primaryNavy)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOffers = _offers.where((o) => o.maxLimit >= _loanAmount).toList();
    if (filteredOffers.isEmpty) {
      filteredOffers.addAll(_offers);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryNavy),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.primaryNavy, size: 26),
            onPressed: _showHelpBottomSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            // Select Loan Amount Label
            Text(
              'Select loan amount',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),

            // Stepper and Display Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircleButton(icon: Icons.remove, onTap: _decrementLoan),
                  Expanded(
                    child: Text(
                      _formatIndianCurrency(_loanAmount),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  _buildCircleButton(icon: Icons.add, onTap: _incrementLoan),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Green Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF16A34A),
                  inactiveTrackColor: const Color(0xFFE2E8F0),
                  trackHeight: 6.0,
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 14.0,
                    elevation: 3.0,
                  ),
                  overlayColor: const Color(0xFF16A34A).withValues(alpha: 0.15),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
                ),
                child: Slider(
                  value: _loanAmount,
                  min: _minLoan,
                  max: _maxLoan,
                  divisions: ((_maxLoan - _minLoan) / _step).round(),
                  onChanged: (val) {
                    setState(() {
                      _loanAmount = val;
                    });
                  },
                ),
              ),
            ),

            // Slider Range Labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatIndianCurrency(_minLoan),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    _formatIndianCurrency(_maxLoan),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Dashed Divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: _DashedLine(color: Color(0xFFE2E8F0)),
            ),

            const SizedBox(height: 24),

            // Select Loan Duration Label
            Text(
              'Select Loan duration',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),

            // Duration Horizontal List
            SizedBox(
              height: 86,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                scrollDirection: Axis.horizontal,
                itemCount: _durations.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 14),
                itemBuilder: (ctx, index) {
                  final duration = _durations[index];
                  final isSelected = duration == _selectedDuration;
                  return _buildDurationCard(duration, isSelected);
                },
              ),
            ),

            const SizedBox(height: 24),

            // Loan Offers Section with Light Gray Container
            Container(
              width: double.infinity,
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
                    child: Text(
                      'Eligible BankSathi Offers (${filteredOffers.length})',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                  ...filteredOffers.map((offer) {
                    final emi = offer.calculateEmi(_loanAmount, _selectedDuration);
                    return _buildOfferCard(offer, emi);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, color: const Color(0xFF334155), size: 24),
        ),
      ),
    );
  }

  Widget _buildDurationCard(int months, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDuration = months;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 80,
        height: 84,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDCFCE7) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$months',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'months',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF166534) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(LoanPartnerOffer offer, int emi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context.push('/loan/detail', extra: offer.toLoanOffer()),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (offer.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1D4ED8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  child: Text(
                    offer.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: offer.brandColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(offer.icon, color: offer.brandColor, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  offer.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _launchUrl(offer.applyUrl),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE9FE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Apply Now',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF6D28D9),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const _DashedLine(color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EMI',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatIndianCurrency(emi),
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yearly interest',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              offer.yearlyInterest,
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  final Color color;

  const _DashedLine({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const double height = 1.0;
    const double dashWidth = 5.0;
    const double dashSpace = 4.0;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFCBD5E1)),
              ),
            );
          }),
        );
      },
    );
  }
}
