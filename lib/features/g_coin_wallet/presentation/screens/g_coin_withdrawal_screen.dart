import 'package:zeokash/core/network/api_client.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/g_coin_wallet/data/g_coin_withdrawal_models.dart';
import 'package:zeokash/features/g_coin_wallet/presentation/providers/g_coin_withdrawal_provider.dart';
import 'package:zeokash/features/rewards/widgets/g_coin_widget.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class GCoinWithdrawalScreen extends ConsumerStatefulWidget {
  const GCoinWithdrawalScreen({super.key});

  @override
  ConsumerState<GCoinWithdrawalScreen> createState() => _GCoinWithdrawalScreenState();
}

class _GCoinWithdrawalScreenState extends ConsumerState<GCoinWithdrawalScreen> {
  int? _selectedCoins = 5000; // Default ₹500 (5,000 G Coins)
  bool _isCustomSelected = false;
  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _mpinController = TextEditingController();
  bool _isSubmitting = false;
  String? _customError;

  @override
  void dispose() {
    _customAmountController.dispose();
    _mpinController.dispose();
    super.dispose();
  }

  void _onSelectPreset(int coins) {
    setState(() {
      _selectedCoins = coins;
      _isCustomSelected = false;
      _customError = null;
      _customAmountController.clear();
    });
  }

  void _onCustomAmountChanged(String val, double availableBalance, double maxTxLimit) {
    final parsedInr = int.tryParse(val.trim());
    if (parsedInr == null) {
      setState(() {
        _selectedCoins = null;
        _customError = 'Enter a valid integer rupee amount';
      });
      return;
    }

    if (parsedInr <= 1000) {
      setState(() {
        _selectedCoins = null;
        _customError = 'Custom amount must be greater than ₹1,000';
      });
      return;
    }

    if (parsedInr > maxTxLimit) {
      setState(() {
        _selectedCoins = null;
        _customError = 'Amount exceeds transaction limit of ₹${maxTxLimit.toInt()}';
      });
      return;
    }

    final coinsRequired = parsedInr * 10;
    if (coinsRequired > availableBalance) {
      setState(() {
        _selectedCoins = null;
        _customError = 'Insufficient balance (${coinsRequired.toString()} coins required)';
      });
      return;
    }

    setState(() {
      _selectedCoins = coinsRequired;
      _customError = null;
    });
  }

  void _showMpinModal(BuildContext context, WithdrawalEligibility eligibility, BankAccountItem bank) {
    _mpinController.clear();
    String? localError;

    final quote = _selectedCoins != null
        ? _calculateLocalQuote(_selectedCoins!)
        : null;

    if (quote == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Authorize Withdrawal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(modalContext),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Transfer ₹${quote.netPayout.toStringAsFixed(2)} to ${bank.bankName} (${bank.maskedAccountNumber})',
                style: const TextStyle(fontSize: 13, color: AppTheme.secondaryText),
              ),
              const SizedBox(height: 20),

              if (localError != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(localError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              const Text('Enter 4-Digit M-PIN', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryText)),
              const SizedBox(height: 8),
              TextField(
                controller: _mpinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 14, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: PrimaryButton(
                  text: 'Confirm & Transfer ₹${quote.netPayout.toStringAsFixed(2)}',
                  isLoading: _isSubmitting,
                  onPressed: () async {
                    if (_mpinController.text.length < 4) {
                      setModalState(() => localError = 'Please enter a valid 4-digit M-PIN');
                      return;
                    }

                    setModalState(() => _isSubmitting = true);
                    final idempotencyKey = 'wdl_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';

                    try {
                      final repo = ref.read(gCoinWithdrawalRepositoryProvider);
                      final withdrawal = await repo.submitWithdrawal(
                        gCoins: quote.gCoins,
                        bankAccountId: bank.id,
                        mpin: _mpinController.text,
                        idempotencyKey: idempotencyKey,
                      );

                      ref.invalidate(gCoinWithdrawalEligibilityProvider);
                      ref.invalidate(withdrawalHistoryProvider);

                      if (modalContext.mounted) {
                        Navigator.pop(modalContext);
                      }

                      if (context.mounted) {
                        context.push('/g-coins/result', extra: withdrawal);
                      }
                    } catch (e) {
                      setModalState(() {
                        _isSubmitting = false;
                        localError = e.toString().replaceAll('Exception:', '').trim();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  WithdrawalQuote _calculateLocalQuote(int coins) {
    final gross = coins / 10.0;
    // 7.5% conversion fee rounded half-up
    final conversionFee = (gross * 0.075 * 100).round() / 100.0;
    // 4.5% convenience fee rounded half-up
    final convenienceFee = (gross * 0.045 * 100).round() / 100.0;
    final totalCharges = conversionFee + convenienceFee;
    final netPayout = gross - totalCharges;

    return WithdrawalQuote(
      gCoins: coins,
      grossAmount: gross,
      conversionFee: conversionFee,
      convenienceFee: convenienceFee,
      totalCharges: totalCharges,
      gstAmount: 0.0,
      netPayout: max(0.0, netPayout),
    );
  }

  void _showKycVerificationDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final panCtrl = TextEditingController();
    final dobCtrl = TextEditingController(text: '1995-08-15');
    bool isSubmittingKyc = false;
    String? kycErr;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: AppTheme.primaryNavy, size: 24),
                  SizedBox(width: 10),
                  Text('Complete KYC Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy)),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Identity verification is mandated by regulatory guidelines before reward payouts.', style: TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
              const SizedBox(height: 16),

              if (kycErr != null) ...[
                Text(kycErr!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                const SizedBox(height: 10),
              ],

              const Text('Full Legal Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  hintText: 'As per PAN card',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              const Text('PAN Card Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: panCtrl,
                textCapitalization: TextCapitalization.characters,
                maxLength: 10,
                decoration: InputDecoration(
                  hintText: 'e.g. ABCDE1234F',
                  counterText: '',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              const Text('Date of Birth (YYYY-MM-DD)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: dobCtrl,
                decoration: InputDecoration(
                  hintText: '1995-08-15',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: PrimaryButton(
                  text: 'Submit & Verify KYC',
                  isLoading: isSubmittingKyc,
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty || panCtrl.text.trim().length != 10) {
                      setModalState(() => kycErr = 'Please enter valid Full Name and 10-digit PAN.');
                      return;
                    }
                    setModalState(() => isSubmittingKyc = true);
                    try {
                      final dio = ref.read(dioProvider);
                      await dio.post('profile/kyc/verify/', data: {
                        'full_legal_name': nameCtrl.text.trim(),
                        'pan_number': panCtrl.text.trim().toUpperCase(),
                        'dob': dobCtrl.text.trim(),
                      });
                      // Auto refresh eligibility
                      ref.invalidate(gCoinWithdrawalEligibilityProvider);
                      if (modalCtx.mounted) Navigator.pop(modalCtx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(backgroundColor: AppTheme.success, content: Text('KYC Verified successfully!')),
                        );
                      }
                    } catch (e) {
                      setModalState(() {
                        isSubmittingKyc = false;
                        kycErr = e.toString();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eligibilityAsync = ref.watch(gCoinWithdrawalEligibilityProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Text('Withdraw G Coins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(width: 6),
            Text('Paisaजी', style: TextStyle(fontSize: 14, color: AppTheme.primaryBlue, fontWeight: FontWeight.w900)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Withdrawal History',
            onPressed: () => context.push('/g-coins/history'),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(gCoinWithdrawalEligibilityProvider);
          ref.invalidate(userBankAccountsProvider);
        },
        child: eligibilityAsync.when(
          data: (eligibility) {
            final activeBank = eligibility.defaultBankAccount;
            final quote = _selectedCoins != null
                ? _calculateLocalQuote(_selectedCoins!)
                : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle
                  const Text(
                    'Transfer eligible G Coin rewards to your verified bank account.',
                    style: TextStyle(color: AppTheme.secondaryText, fontSize: 13),
                  ),
                  const SizedBox(height: 14),

                  // 1. Balance Card (Section 2 & 3)
                  _buildBalanceCard(eligibility),
                  const SizedBox(height: 16),

                  // Compliance Feature Flag Banner (Section 1 & 8)
                  if (!eligibility.featureEnabled) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, color: Color(0xFFD97706), size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'G Coin bank withdrawals are currently disabled pending regulatory compliance approval. Payouts will unlock upon authorized provider activation.',
                              style: TextStyle(color: Color(0xFF92400E), fontSize: 12, height: 1.4, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 2. Mandatory KYC Status Card (Section 4)
                  _buildKycCard(eligibility),
                  const SizedBox(height: 16),

                  // 3. Bank Account Selection / Registration Card (Section 5 & 6)
                  _buildBankAccountCard(activeBank),
                  const SizedBox(height: 20),

                  // 4. Withdrawal Amount Selection (Section 3 & Preset Rules)
                  const Text(
                    'Select Withdrawal Amount',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryNavy),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose a preset denomination or specify custom amount (10 G Coins = ₹1).',
                    style: TextStyle(fontSize: 12, color: AppTheme.secondaryText),
                  ),
                  const SizedBox(height: 12),

                  _buildPresetCards(eligibility),
                  const SizedBox(height: 14),

                  // Custom Amount Section
                  _buildCustomAmountSection(eligibility),
                  const SizedBox(height: 20),

                  // 5. Withdrawal Summary (Section 3 & Fee Breakdown)
                  if (quote != null) ...[
                    _buildWithdrawalSummary(quote, activeBank),
                    const SizedBox(height: 24),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: PrimaryButton(
                        text: 'Withdraw ₹${quote.netPayout.toStringAsFixed(2)}',
                        onPressed: (eligibility.featureEnabled &&
                                eligibility.isKycVerified &&
                                activeBank != null &&
                                eligibility.availableBalance >= quote.gCoins &&
                                quote.grossAmount >= eligibility.minWithdrawalInr)
                            ? () => _showMpinModal(context, eligibility, activeBank)
                            : null,
                      ),
                    ),
                    if (!eligibility.isKycVerified || activeBank == null || !eligibility.featureEnabled) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          !eligibility.featureEnabled
                              ? 'Feature disabled by server regulatory flag'
                              : !eligibility.isKycVerified
                                  ? 'Complete KYC above to enable withdrawal'
                                  : 'Link and verify a bank account to proceed',
                          style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text('Error loading withdrawal details: $err', style: const TextStyle(color: Colors.red)),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildBalanceCard(WithdrawalEligibility data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${data.availableBalance.toInt()} G Coins',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Equivalent Value: ₹${data.inrEquivalent.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const GCoinWidget(
                value: 50,
                size: 52,
                showGlow: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceSubItem('Locked Coins', '${data.reservedBalance.toInt()} G Coins'),
              _buildBalanceSubItem('Min Withdrawal', '₹${data.minWithdrawalInr.toInt()} (1,000 Coins)'),
              _buildBalanceSubItem('Conversion', '10 Coins = ₹1'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSubItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildKycCard(WithdrawalEligibility data) {
    final isVerified = data.isKycVerified;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVerified ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isVerified ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVerified ? Icons.verified_user_rounded : Icons.pending_actions_rounded,
              color: isVerified ? const Color(0xFF16A34A) : const Color(0xFFD97706),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isVerified ? 'KYC Verified' : 'Complete Your KYC',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isVerified ? const Color(0xFF166534) : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isVerified ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data.kycStatus,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isVerified
                      ? 'Identity is confirmed. Bank withdrawals enabled.'
                      : 'Verify your identity to enable G Coin withdrawals.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isVerified ? const Color(0xFF15803D) : const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
          if (!isVerified)
            TextButton(
              onPressed: () => _showKycVerificationDialog(context),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Complete KYC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildBankAccountCard(BankAccountItem? bank) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Beneficiary Bank Account',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy),
              ),
              InkWell(
                onTap: () async {
                  await context.push('/g-coins/add-bank');
                  ref.invalidate(gCoinWithdrawalEligibilityProvider);
                },
                child: Text(
                  bank != null ? 'Change Bank' : '+ Add Bank',
                  style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (bank != null)
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFEFF6FF),
                  child: const Icon(Icons.account_balance_rounded, color: AppTheme.primaryNavy, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bank.bankName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(
                        'Account: ${bank.maskedAccountNumber} • IFSC: ${bank.ifsc}',
                        style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12),
                      ),
                      Text(
                        'Beneficiary: ${bank.accountHolderName}',
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'VERIFIED',
                    style: TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          else
            InkWell(
              onTap: () async {
                await context.push('/g-coins/add-bank');
                ref.invalidate(gCoinWithdrawalEligibilityProvider);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: AppTheme.primaryBlue, size: 18),
                    SizedBox(width: 8),
                    Text(' Tap to link bank account.', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPresetCards(WithdrawalEligibility data) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.15,
      children: data.presets.map((preset) {
        final isSelected = !_isCustomSelected && _selectedCoins == preset.gCoinsRequired;
        final isAffordable = preset.isAffordable;

        return InkWell(
          onTap: isAffordable ? () => _onSelectPreset(preset.gCoinsRequired) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF1565D8)
                  : isAffordable
                      ? Colors.white
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF1565D8)
                    : isAffordable
                        ? AppTheme.border
                        : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF1565D8).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '₹${preset.inrAmount}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : isAffordable
                            ? AppTheme.primaryNavy
                            : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${preset.gCoinsRequired.toString()} Coins',
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? Colors.white70
                        : isAffordable
                            ? AppTheme.secondaryText
                            : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get ₹${preset.netPayout.toInt()}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.amberAccent
                        : isAffordable
                            ? const Color(0xFF16A34A)
                            : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomAmountSection(WithdrawalEligibility data) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCustomSelected ? AppTheme.primaryBlue : AppTheme.border,
          width: _isCustomSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Custom Amount (> ₹1,000)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy),
              ),
              if (_isCustomSelected)
                const Text(
                  'ACTIVE',
                  style: TextStyle(color: AppTheme.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryNavy),
              hintText: 'Enter amount above ₹1,000 (e.g. 1500)',
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            onTap: () {
              setState(() {
                _isCustomSelected = true;
              });
            },
            onChanged: (val) => _onCustomAmountChanged(val, data.availableBalance, data.maxWithdrawalPerTxInr),
          ),
          if (_customError != null) ...[
            const SizedBox(height: 6),
            Text(_customError!, style: const TextStyle(color: Colors.red, fontSize: 11)),
          ],
        ],
      ),
    );
  }

  Widget _buildWithdrawalSummary(WithdrawalQuote quote, BankAccountItem? bank) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Withdrawal Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy),
          ),
          const SizedBox(height: 14),

          _buildSummaryLine('G Coins Required', '${quote.gCoins.toString()} Coins'),
          const SizedBox(height: 8),
          _buildSummaryLine('Gross Reward Value', '₹${quote.grossAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryLine(
            'Standard Conversion Fee (7.5%)',
            '−₹${quote.conversionFee.toStringAsFixed(2)}',
            isDeduction: true,
          ),
          const SizedBox(height: 8),
          _buildSummaryLine(
            'Convenience Fee (4.5%)',
            '−₹${quote.convenienceFee.toStringAsFixed(2)}',
            isDeduction: true,
          ),
          const SizedBox(height: 8),
          _buildSummaryLine(
            'Total Charges (12%)',
            '−₹${quote.totalCharges.toStringAsFixed(2)}',
            isDeduction: true,
            isBold: true,
          ),
          const Divider(height: 22, color: AppTheme.border),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'You Will Receive:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              Text(
                '₹${quote.netPayout.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.account_balance, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  bank != null
                      ? 'Destination: ${bank.bankName} (${bank.maskedAccountNumber})'
                      : 'Destination: No bank account selected',
                  style: const TextStyle(fontSize: 11, color: AppTheme.secondaryText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value, {bool isDeduction = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isBold ? AppTheme.primaryNavy : AppTheme.secondaryText,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isDeduction
                ? const Color(0xFFDC2626)
                : isBold
                    ? AppTheme.primaryNavy
                    : AppTheme.primaryText,
          ),
        ),
      ],
    );
  }
}
