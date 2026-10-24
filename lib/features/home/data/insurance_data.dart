import 'package:flutter/material.dart';

class InsuranceItem {
  final String id;
  final String title;
  final String category; // '4 Wheeler', '2 Wheeler'
  final String provider;
  final String tagline;
  final String benefit;
  final String applyUrl;
  final IconData icon;
  final Color cardBg;
  final Color accentColor;
  final Color textColor;
  final String badgeText;
  final List<String> bulletPerks;
  final List<String> keyHighlights;
  final List<String> coverageDetails;
  final String claimsRatio;
  final String cashlessGaragesOrHospitals;
  final String startingPrice;
  final String ctaText;

  const InsuranceItem({
    required this.id,
    required this.title,
    required this.category,
    required this.provider,
    required this.tagline,
    required this.benefit,
    required this.applyUrl,
    required this.icon,
    required this.cardBg,
    required this.accentColor,
    required this.textColor,
    required this.badgeText,
    required this.bulletPerks,
    required this.keyHighlights,
    required this.coverageDetails,
    required this.claimsRatio,
    required this.cashlessGaragesOrHospitals,
    required this.startingPrice,
    this.ctaText = 'Get Quote',
  });
}

const List<InsuranceItem> kInsuranceOffers = [
  InsuranceItem(
    id: 'car_insurance_4w',
    title: '4 Wheeler Car Insurance',
    category: '4 Wheeler',
    provider: 'Top Insurers via BankSathi',
    tagline: 'Covers own damage, 3rd-party liability, and natural/man-made disasters',
    benefit: '6,800+ Cashless Garages • Up to 50% NCB • ₹15L Cover',
    applyUrl: 'https://leads.banksathi.com/?h=aEUwVk9iWVI4cXQ1TEo2M1hPM2tCUT09',
    icon: Icons.directions_car,
    cardBg: Color(0xFFEFF6FF),
    accentColor: Color(0xFF2563EB),
    textColor: Color(0xFF1E40AF),
    badgeText: '4 WHEELER',
    ctaText: 'Get Your Quotes',
    bulletPerks: [
      'Covers own damage, third-party liability, and natural/man-made disasters',
      '6,800+ cashless garages across India',
      'Instant policy & quick claims via app/video inspection',
      'Up to 50% No Claim Bonus (NCB) on claim-free years',
      'Personal accident cover up to ₹15 lakh',
      '24/7 roadside assistance for emergencies',
    ],
    keyHighlights: [
      '6,800+ Cashless Garages Nationwide',
      'Instant Video Inspection & App Claims',
      'Up to 50% No Claim Bonus Transfer',
      '₹15 Lakh Owner-Driver PA Cover Included',
      '24/7 Emergency Roadside Assistance',
      'Zero Depreciation Add-on Available',
    ],
    coverageDetails: [
      'Own Damage Cover (Accidents, Fire, Theft, Natural/Man-made Disasters)',
      'Third-Party Legal & Property Damage Liability',
      'Engine & Gearbox Protection Add-on',
      'Consumables & Key Replacement Assistance',
      'Emergency Towing & Roadside Assistance Service',
    ],
    claimsRatio: '98.6%',
    cashlessGaragesOrHospitals: '6,800+ Garages',
    startingPrice: 'Instant Quotes',
  ),
  InsuranceItem(
    id: 'bike_insurance_2w',
    title: 'ICICI Lombard Bike Insurance',
    category: '2 Wheeler',
    provider: 'ICICI Lombard',
    tagline: 'Protect Your Ride with ICICI Lombard Bike Insurance! 🚴‍♂️🛡️',
    benefit: 'Affordable Premiums • Comprehensive • Hassle-Free Claims',
    applyUrl: 'https://leads.banksathi.com/?h=aGdvanBFN2ViQjVkZUJ5WXJWYjF0Zz09',
    icon: Icons.two_wheeler,
    cardBg: Color(0xFFFAF5FF),
    accentColor: Color(0xFF7C3AED),
    textColor: Color(0xFF6B21A8),
    badgeText: '2 WHEELER',
    ctaText: 'Get Insured Now',
    bulletPerks: [
      'Affordable Premiums with instant digital quote',
      'Comprehensive Coverage (Own Damage + Third-Party Liability)',
      'Hassle-Free Claims with speedy settlements',
      'Don’t wait! Secure your bike today and enjoy worry-free rides 🛵💨',
      'Authorized two-wheeler cashless service centers across India',
      'Personal accident cover for owner-driver up to ₹15 lakh',
    ],
    keyHighlights: [
      'Affordable Premiums with Instant Policy Issuance',
      'Comprehensive Own Damage & 3rd Party Cover',
      'Hassle-Free & Fast Digital Claims',
      'Zero Inspection for Active Renewals',
      'Multi-Year Discounts & No Claim Bonus Protection',
      '24/7 Roadside Assistance & Breakdown Support',
    ],
    coverageDetails: [
      'Comprehensive Own Damage Cover for Two-Wheelers',
      'Mandatory Third-Party Liability Protection',
      'Accidental Damage, Theft & Fire Protection',
      'Zero Depreciation Add-on Available',
      'Personal Accident Protection up to ₹15 Lakh',
    ],
    claimsRatio: '99.1%',
    cashlessGaragesOrHospitals: '5,400+ Garages',
    startingPrice: 'Affordable Premiums',
  ),
];
