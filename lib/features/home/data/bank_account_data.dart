import 'package:flutter/material.dart';

class BankAccountItem {
  final String id;
  final String name;
  final String bank;
  final String tagline;
  final String highlightPerk;
  final String secondaryPerk;
  final String interestRate;
  final String minimumBalance;
  final String debitCardType;
  final String network;
  final String maskedNumber;
  final String expiry;
  final String imagePath;
  final String applyUrl;
  final String feeText;
  final String welcomeOffer;
  final List<String> bulletPerks;
  final List<String> detailedBenefits;
  final List<String> eligibilityCriteria;
  final List<Color> gradient;

  const BankAccountItem({
    required this.id,
    required this.name,
    required this.bank,
    required this.tagline,
    required this.highlightPerk,
    required this.secondaryPerk,
    required this.interestRate,
    required this.minimumBalance,
    required this.debitCardType,
    required this.network,
    required this.maskedNumber,
    required this.expiry,
    required this.imagePath,
    required this.applyUrl,
    required this.feeText,
    required this.welcomeOffer,
    required this.bulletPerks,
    required this.detailedBenefits,
    required this.eligibilityCriteria,
    required this.gradient,
  });
}

const List<BankAccountItem> kBankAccountOffers = [
  BankAccountItem(
    id: 'kotak_811',
    name: 'Kotak 811 Super Savings Account',
    bank: 'Kotak Mahindra Bank',
    tagline: 'Zero Balance Account • Up to ₹6,000 Cashback',
    highlightPerk: 'Up to ₹6,000 Cashback on Debit Card Spends*',
    secondaryPerk: 'Free Platinum Debit Card & ₹1 Lakh Daily ATM Limit',
    interestRate: 'Up to 4.0% p.a.',
    minimumBalance: '₹0 (100% Zero Balance Account)',
    debitCardType: 'Visa Platinum Debit Card',
    network: 'VISA',
    maskedNumber: 'XXXX  XXXX  XXXX  8110',
    expiry: '10/29',
    imagePath: 'assets/images/kotak_811_card.jpg',
    applyUrl: 'https://leads.banksathi.com/?h=ejZLQlJEclM2Tm1yLzZ0NTBPdDQrUT09',
    feeText: 'Zero Balance Account (No Minimum Balance Required)',
    welcomeOffer: 'Open your account in 3 minutes & get up to ₹6,000 cashback on debit card merchant spends.',
    bulletPerks: [
      'Get up to ₹6,000 cashback on debit card spends*',
      'Free Platinum Debit Card with high transaction limits',
      'Higher ATM withdrawal limit – up to ₹1 lakh/day',
      'Complimentary Insurance cover up to ₹80 lakh',
      'Dedicated 24x7 customer support & instant UPI activation',
    ],
    detailedBenefits: [
      'Zero Balance Freedom: No penalty or charges for non-maintenance of minimum balance.',
      'Cashback Rewards: Earn accelerated cashback on online shopping, fuel, and utility bills.',
      'Platinum Debit Card: Instant virtual card on mobile app plus optional contactless physical card.',
      'High Withdrawal Limit: Withdraw up to ₹1,00,000 per day at ATMs across India.',
      'Comprehensive Insurance: Accidental cover up to ₹80 Lakh with lost card liability insurance.',
      'Instant Video KYC: 100% paperless account opening completed right from your smartphone.',
    ],
    eligibilityCriteria: [
      'Resident Indian citizen aged 18 years and above',
      'Valid PAN Card and Aadhaar linked with mobile number',
      'No existing Kotak Mahindra Bank account',
      'Smartphone with camera & microphone for quick video KYC',
    ],
    gradient: [Color(0xFF881337), Color(0xFF4C0519)],
  ),
  BankAccountItem(
    id: 'idfc_savings',
    name: 'IDFC FIRST Bank Savings Account',
    bank: 'IDFC FIRST Bank',
    tagline: 'Up to 6.5% Interest Rates p.a. • Free Unlimited ATM',
    highlightPerk: 'Up to 6.5% Interest Rates per Annum',
    secondaryPerk: 'Free & Unlimited ATM Withdrawals Everywhere',
    interestRate: 'Up to 6.5% p.a. with Monthly Interest Credit',
    minimumBalance: 'Digital Account with Zero Hidden Fees',
    debitCardType: 'Visa Signature Contactless Debit Card',
    network: 'VISA',
    maskedNumber: 'XXXX  XXXX  XXXX  4589',
    expiry: '11/30',
    imagePath: 'assets/images/idfc_savings_card.jpg',
    applyUrl: 'https://leads.banksathi.com/?h=WGxtRjRVKzRKbUkyQ1J6SkhJYms0QT09',
    feeText: 'Zero Hidden Fees • Monthly Interest Payout',
    welcomeOffer: 'Earn monthly interest payouts with interest rates up to 6.5% p.a. and free unlimited ATM withdrawals.',
    bulletPerks: [
      'Up to 6.5% Interest rates per annum with monthly credit',
      'Free & unlimited ATM withdrawals at all bank ATMs in India',
      'Exciting rewards and cashback on all merchant transactions',
      'Accidental insurance cover and lost card liability cover',
      'Pre-approved instant personal loan and credit card offers',
    ],
    detailedBenefits: [
      'Monthly Interest Credit: Earn interest credited to your account every single month instead of quarterly.',
      'Unlimited ATM Access: Free ATM transactions at all domestic ATMs with zero surcharge.',
      'Signature Debit Card: Complimentary airport lounge access, dining deals, and high daily spend limits.',
      'Security & Insurance: Personal accident insurance cover up to ₹35 Lakh and purchase protection.',
      'Pre-Approved Lending: Instant access to pre-approved personal loans, car loans, and credit cards.',
      'Zero Fee Banking: 28 commonly charged banking services completely free.',
    ],
    eligibilityCriteria: [
      'Indian Resident citizen aged 18 years or older',
      'Original PAN Card and Aadhaar Card',
      'Active mobile number linked with Aadhaar for OTP verification',
      'Initial funding via NetBanking / UPI during setup',
    ],
    gradient: [Color(0xFF7F1D1D), Color(0xFF450A0A)],
  ),
  BankAccountItem(
    id: 'axis_savings',
    name: 'Axis Bank Digital Savings Account',
    bank: 'Axis Bank',
    tagline: '10% Cashback on Amazon & Flipkart • Free Movies',
    highlightPerk: '10% Cashback on Amazon & Flipkart Spends',
    secondaryPerk: '₹500 Grab Deals Voucher + Free Movie Ticket Monthly',
    interestRate: 'Up to 3.5% p.a.',
    minimumBalance: 'Full-KYC Digital Savings Account',
    debitCardType: 'Complimentary Virtual e-Debit Card',
    network: 'VISA',
    maskedNumber: 'XXXX  XXXX  XXXX  3108',
    expiry: '06/29',
    imagePath: 'assets/images/axis_savings_card.jpg',
    applyUrl: 'https://leads.banksathi.com/?h=Uml3bjdGbkxTbml1bklXcjZISWwzdz09',
    feeText: 'Instant Account Number • Free Virtual e-Debit Card',
    welcomeOffer: 'Get ₹500 Grab Deals Shopping Voucher + 10% Cashback on Amazon & Flipkart every month.',
    bulletPerks: [
      '10% Cashback on Amazon & Flipkart online purchases',
      '₹500 Shopping Voucher via Axis Grab Deals portal',
      'Free Movie Ticket every month on BookMyShow',
      'Complimentary Virtual e-Debit Card generated instantly',
      '1% Flat Cashback on all online transactions',
    ],
    detailedBenefits: [
      'E-Commerce Perks: 10% accelerated cashback across top shopping apps including Amazon, Flipkart, & Myntra.',
      'Entertainment: Buy 1 Get 1 free movie ticket offer every month on BookMyShow.',
      'Grab Deals Portal: Exclusive partner discounts and ₹500 welcome voucher on first shopping transaction.',
      'Instant Virtual Card: Start transacting and linking to UPI / Google Pay / PhonePe immediately.',
      'Dining Privileges: Up to 20% discount at 10,000+ partner restaurants across India.',
      'Bank Smart: 100% digital account opening from home via video KYC in under 5 minutes.',
    ],
    eligibilityCriteria: [
      'Indian resident aged 18 to 60 years',
      'Valid PAN card and Aadhaar linked with mobile number',
      'Original PAN card required during video KYC session',
      'Selfie & video verification on mobile browser',
    ],
    gradient: [Color(0xFF4A044E), Color(0xFF1E1B4B)],
  ),
];
