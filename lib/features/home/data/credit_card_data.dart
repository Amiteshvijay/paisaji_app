import 'package:flutter/material.dart';

class CreditCardItem {
  final String id;
  final String name;
  final String bank;
  final String tagline;
  final String highlightPerk;
  final String secondaryPerk;
  final String network;
  final String maskedNumber;
  final String expiry;
  final String imagePath;
  final String applyUrl;
  final String feeText;
  final String joiningFee;
  final String annualFee;
  final String welcomeOffer;
  final List<String> bulletPerks;
  final List<String> detailedBenefits;
  final List<String> eligibilityCriteria;
  final List<Color> gradient;

  const CreditCardItem({
    required this.id,
    required this.name,
    required this.bank,
    required this.tagline,
    required this.highlightPerk,
    required this.secondaryPerk,
    required this.network,
    required this.maskedNumber,
    required this.expiry,
    required this.imagePath,
    required this.applyUrl,
    required this.feeText,
    required this.joiningFee,
    required this.annualFee,
    required this.welcomeOffer,
    required this.bulletPerks,
    required this.detailedBenefits,
    required this.eligibilityCriteria,
    required this.gradient,
  });
}

const List<CreditCardItem> kCreditCardOffers = [
  CreditCardItem(
    id: 'hdfc_rewards',
    name: 'HDFC Bank Credit Card',
    bank: 'HDFC Bank',
    tagline: 'The Most Rewarding Card For Everyday Spends',
    highlightPerk: 'Free 1-Yr Amazon Prime + Airport Lounge Access',
    secondaryPerk: 'Cashback On Every Purchase & Grocery Discounts',
    network: 'VISA',
    maskedNumber: 'XXXX  XXXX  XXXX  8820',
    expiry: '10/29',
    imagePath: 'assets/images/hdfc_card.jpg',
    applyUrl: 'https://leads.banksathi.com/?h=OHZZV3l2VUJ3N1VEbHE1TG5JTjdRUT09',
    feeText: 'Annual Fee waiver on ₹1L annual spends',
    joiningFee: '₹500 (Welcome voucher included)',
    annualFee: '₹500 (Waived on annual spends > ₹1 Lakh)',
    welcomeOffer: 'Free 1-Year Membership of Amazon Prime & exciting gift vouchers upon card activation.',
    bulletPerks: [
      'Free 1-Year Membership of Amazon Prime & more!',
      'Complimentary Airport Lounge Access across India',
      'Exciting Gift Vouchers on joining',
      'Discount on Grocery, Movies, & Shopping',
      'Cashback On Every Purchase with accelerated points',
    ],
    detailedBenefits: [
      'Rewards: 4X reward points on online shopping, grocery, and dining.',
      'Travel: 4 complimentary domestic airport lounge visits per calendar year.',
      'Entertainment: 1+1 movie ticket offers on BookMyShow every month.',
      'Fuel: 1% fuel surcharge waiver across all authorized fuel outlets.',
      'EMIs: Convert transactions above ₹2,500 into easy, flexible monthly EMIs.',
    ],
    eligibilityCriteria: [
      'Age between 21 and 60 years',
      'Indian resident with valid PAN & Aadhaar',
      'Net monthly income of ₹25,000+ for salaried or ITR of ₹4L+ for self-employed',
      'Good credit / CIBIL score (700+ recommended)',
    ],
    gradient: [Color(0xFF003865), Color(0xFF0A192F)],
  ),
  CreditCardItem(
    id: 'scapia_axis',
    name: 'Scapia Axis Bank Card',
    bank: 'Axis Bank',
    tagline: '5% Rewards on UPI Spends • Zero Forex Markup',
    highlightPerk: 'Zero Joining Fee – 100% Lifetime Free',
    secondaryPerk: 'Unlimited Lounge Access & 10% Coins Back',
    network: 'RUPAY',
    maskedNumber: 'XXXX  XXXX  XXXX  4192',
    expiry: '09/30',
    imagePath: 'assets/images/scapia_card.jpg',
    applyUrl: 'https://leads.banksathi.com/?h=Qm5LRkxGcG5QemV2czdlNmtpMVMwdz09',
    feeText: '100% Lifetime Free (Zero Joining & Annual Fee)',
    joiningFee: '₹0 (Zero Joining Fee)',
    annualFee: '₹0 (Lifetime Free - No Annual Fee)',
    welcomeOffer: 'Instant activation with 5% rewards on all RuPay UPI merchant transactions.',
    bulletPerks: [
      'Zero Joining Fee – No hidden costs!',
      'Unlimited Domestic Airport Lounge Access',
      'Zero Forex Markup – Travel worldwide without extra currency charges!',
      '10% Coins Back (5 Coins = ₹1 cash value)',
      '100% Digital & Instant In-App Approval',
    ],
    detailedBenefits: [
      'RuPay UPI: Link directly to PhonePe, Paytm, or GPay for 5% rewards on QR scans.',
      'Zero Forex: Save 3.5% currency markup fees on all international travel & websites.',
      'Lounge Access: Unlimited complimentary domestic lounge access on meeting monthly spend criteria.',
      'Coins Rewards: Coins never expire and can be redeemed directly for flight & hotel bookings.',
      'No Paperwork: Entire onboarding completed within 5 minutes via video KYC.',
    ],
    eligibilityCriteria: [
      'Age between 21 and 65 years',
      'Indian citizen with active bank account & mobile-linked Aadhaar',
      'Salaried or Self-Employed individuals',
      'Existing credit card or CIBIL score of 720+',
    ],
    gradient: [Color(0xFF047857), Color(0xFF064E3B)],
  ),
  CreditCardItem(
    id: 'axis_rewards',
    name: 'Axis Bank Credit Card',
    bank: 'Axis Bank',
    tagline: 'Select a Card & Choose Your Perks',
    highlightPerk: 'Welcome Benefits Worth ₹600 + ₹500 Flipkart Voucher',
    secondaryPerk: 'SonyLIV Annual Subscription + 50% Off Food Delivery',
    network: 'VISA',
    maskedNumber: 'XXXX  XXXX  XXXX  7890',
    expiry: '04/28',
    imagePath: 'assets/images/axis_card.jpg',
    applyUrl: 'https://leads.banksathi.com/?h=U0szVk42cVptcGJHVVJ2Q003Z3ZEZz09',
    feeText: 'Welcome Benefits Worth ₹600+',
    joiningFee: '₹500 + GST (Welcome Benefits Worth ₹1,500+)',
    annualFee: '₹500 (Waived on annual spends > ₹1.5 Lakhs)',
    welcomeOffer: 'Flipkart e-voucher worth ₹500 + SonyLIV 1-year annual subscription worth ₹999.',
    bulletPerks: [
      'Earn Cashback & Accelerated Rewards on Every Purchase',
      'Up to 50% OFF on Online Food Orders on Swiggy/Zomato',
      'Welcome Benefits Worth ₹600 + Flipkart Voucher ₹500',
      'SonyLIV Annual Subscription worth ₹999 Included',
      'FREE Airport Lounge Access & Fuel Cashback up to ₹500',
    ],
    detailedBenefits: [
      'Cashback: Unlimited cashback on daily commute, utility bills, and shopping.',
      'Dining Delights: Up to 20% discount across 10,000+ partner restaurants via Dining Delights.',
      'Entertainment: Buy 1 Get 1 free movie ticket offers on Paytm Movies.',
      'SonyLIV Premium: Free 12 months access to blockbuster sports, shows, and movies.',
      'Fuel: 1% fuel surcharge waiver up to ₹500 cashback per month.',
    ],
    eligibilityCriteria: [
      'Age: 18 - 70 years',
      'Valid PAN, Aadhaar & address proof',
      'Minimum monthly income ₹15,000 (Salaried) or ITR ₹3.6L (Self-Employed)',
      'Pre-approved for existing Axis Bank account holders',
    ],
    gradient: [Color(0xFF881337), Color(0xFF4C0519)],
  ),
  CreditCardItem(
    id: 'indus_easy',
    name: 'IndusInd Easy Credit Card',
    bank: 'IndusInd Bank',
    tagline: 'Lifetime Free Card • No Annual Fee Ever',
    highlightPerk: '100% Lifetime Free • Reward Points Never Expire',
    secondaryPerk: 'Complimentary Airport Lounge + Fuel Surcharge Waiver',
    network: 'VISA',
    maskedNumber: 'XXXX  XXXX  XXXX  2345',
    expiry: '08/29',
    imagePath: 'assets/images/indusind_card.jpg',
    applyUrl: 'https://leads.banksathi.com/?h=ZEFHREU3VDUrTjQxRDdFVFUvclFldz09',
    feeText: 'Lifetime Free (No Joining / No Annual Fee)',
    joiningFee: '₹0 (Zero Joining Fee)',
    annualFee: '₹0 (Lifetime Free - No Annual Renewal Fee)',
    welcomeOffer: 'Lifetime free credit card with instant virtual card activation and reward points that never expire.',
    bulletPerks: [
      'Indus Easy credit card - 100% Lifetime Free card',
      'Earn attractive reward points & cashback on all spends',
      'Reward points never expire – Redeem anytime you want',
      'Complimentary Domestic Airport Lounge Access',
      'Fuel Surcharge Waiver at all petrol pumps nationwide',
    ],
    detailedBenefits: [
      'Forever Free: No joining fees, no annual fees, and no minimum spend commitments.',
      'Eternal Rewards: Flexible reward points that never expire and can be converted into cash.',
      'Travel Perks: Access to participating airport lounges across metro airports in India.',
      'Automotive: 1% fuel surcharge waiver across HPCL, IOCL, and BPCL petrol pumps.',
      'Contactless: Instant tap-to-pay functionality for fast everyday merchant payments.',
    ],
    eligibilityCriteria: [
      'Age: 21 to 65 years',
      'Resident Indian citizen',
      'Salaried or business professionals with regular income',
      'CIBIL / Experian score of 730+',
    ],
    gradient: [Color(0xFF991B1B), Color(0xFF450A0A)],
  ),
  CreditCardItem(
    id: 'hdfc_upi_rupay',
    name: 'HDFC UPI RuPay Card',
    bank: 'HDFC Bank',
    tagline: 'Up to 3% CashPoints on UPI Spends',
    highlightPerk: '3% CashPoints on Grocery & Utilities on UPI',
    secondaryPerk: 'Zero Fuel Surcharge • Up to 50 Days Interest-Free',
    network: 'RUPAY',
    maskedNumber: 'XXXX  XXXX  XXXX  6514',
    expiry: '11/30',
    imagePath: 'assets/images/hdfc_rupay_card.jpg',
    applyUrl: 'https://leads.banksathi.com/?h=NytqZmpZekdqYithOGJMTXVlMVJ5QT09',
    feeText: 'Seamless UPI Linking on PhonePe, GPay, Paytm',
    joiningFee: '₹250 + GST (Waived on first UPI transaction)',
    annualFee: '₹250 (Waived on annual spends > ₹25,000)',
    welcomeOffer: 'Earn 100 CashPoints on linking your card to UPI within the first 30 days.',
    bulletPerks: [
      '3% CashPoints on Grocery, Supermarkets & more via UPI',
      '2% CashPoints on Utility bill payments and recharges',
      '1% CashPoints on all other merchant spend categories',
      'Zero fuel surcharge across all petrol pumps in India',
      'Enjoy up to 50 days of Interest-free credit period',
    ],
    detailedBenefits: [
      'UPI Integration: Seamlessly make QR code payments through PhonePe, Google Pay, and Paytm.',
      'CashPoints: 1 CashPoint = ₹0.25, redeemable directly for statement credit or flight bookings.',
      'Interest-Free Window: Enjoy up to 50 days of credit without interest charges.',
      'Fuel Savings: 1% fuel surcharge waiver on transactions between ₹400 and ₹5,000.',
      'Virtual Instant Card: Digital card issued instantly for immediate online & UPI use.',
    ],
    eligibilityCriteria: [
      'Age: 21 to 60 years',
      'Existing HDFC Bank account holders or new-to-credit customers with Aadhaar OTP',
      'Gross monthly income of ₹20,000+ or ITR of ₹3L+',
      'Active UPI profile on mobile device',
    ],
    gradient: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
  ),
];
