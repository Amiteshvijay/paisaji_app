import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  static const String _prefKeyUpi = 'paisaji_saved_upi_ids_v1';
  static const String _prefKeyCards = 'paisaji_saved_cards_v1';
  static const String _prefKeyInitialized = 'paisaji_payment_methods_init_v1';

  List<Map<String, String>> _upiIds = [];
  List<Map<String, String>> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isInit = prefs.getBool(_prefKeyInitialized) ?? false;

    if (!isInit) {
      // First launch seed defaults
      _upiIds = [
        {'id': 'upi_1', 'upi': 'arjun@okhdfcbank', 'label': 'Primary UPI ID'}
      ];
      _cards = [
        {'id': 'card_1', 'name': 'HDFC Bank Credit Card', 'number': '•••• 4321', 'type': 'Tokenized'}
      ];
      await _savePaymentMethods();
      await prefs.setBool(_prefKeyInitialized, true);
    } else {
      final upiJson = prefs.getString(_prefKeyUpi);
      final cardsJson = prefs.getString(_prefKeyCards);

      if (upiJson != null) {
        try {
          final List<dynamic> decoded = jsonDecode(upiJson);
          _upiIds = decoded.map((e) => Map<String, String>.from(e as Map)).toList();
        } catch (_) {
          _upiIds = [];
        }
      } else {
        _upiIds = [];
      }

      if (cardsJson != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cardsJson);
          _cards = decoded.map((e) => Map<String, String>.from(e as Map)).toList();
        } catch (_) {
          _cards = [];
        }
      } else {
        _cards = [];
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyUpi, jsonEncode(_upiIds));
    await prefs.setString(_prefKeyCards, jsonEncode(_cards));
    await prefs.setBool(_prefKeyInitialized, true);
  }

  // ==========================================
  // CREATE & EDIT MODAL
  // ==========================================
  void _showAddOrEditModal({bool isCard = false, Map<String, String>? existingItem}) {
    final isEditing = existingItem != null;
    int selectedTypeIndex = isCard ? 1 : 0;

    final initialUpi = (!isCard && existingItem != null) ? (existingItem['upi'] ?? '') : '';
    final initialLabel = (!isCard && existingItem != null) ? (existingItem['label'] ?? 'Primary UPI ID') : 'Primary UPI ID';
    final initialCardName = (isCard && existingItem != null) ? (existingItem['name'] ?? '') : '';
    final initialCardNumber = (isCard && existingItem != null) ? (existingItem['number'] ?? '') : '';
    String cardType = (isCard && existingItem != null) ? (existingItem['type'] ?? 'Tokenized') : 'Tokenized';

    final upiController = TextEditingController(text: initialUpi);
    final upiLabelController = TextEditingController(text: initialLabel);
    final cardNameController = TextEditingController(text: initialCardName);
    final cardNumberController = TextEditingController(text: initialCardNumber);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing
                              ? (isCard ? 'Edit Card' : 'Edit UPI ID')
                              : 'Add Payment Method',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A2342),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Toggle only when adding new
                    if (!isEditing) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setModalState(() => selectedTypeIndex = 0),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: selectedTypeIndex == 0 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: selectedTypeIndex == 0
                                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'UPI ID',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: selectedTypeIndex == 0 ? const Color(0xFF007BFF) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setModalState(() => selectedTypeIndex = 1),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: selectedTypeIndex == 1 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: selectedTypeIndex == 1
                                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Debit / Credit Card',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: selectedTypeIndex == 1 ? const Color(0xFF007BFF) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // UPI Input Form
                    if (selectedTypeIndex == 0) ...[
                      const Text('UPI ID', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0A2342))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: upiController,
                        decoration: InputDecoration(
                          hintText: 'e.g. mobile@upi or name@okaxis',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text('Label', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0A2342))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: upiLabelController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Primary UPI ID, Personal, Business',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ] else ...[
                      // Card Input Form
                      const Text('Card Name / Bank', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0A2342))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: cardNameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. HDFC Bank Credit Card',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text('Card Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0A2342))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: cardNumberController,
                        decoration: InputDecoration(
                          hintText: 'e.g. •••• 4321 or 16 digit card number',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text('Card Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0A2342))),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: cardType,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Tokenized', child: Text('Tokenized (RBI Compliant)')),
                          DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
                          DropdownMenuItem(value: 'Debit Card', child: Text('Debit Card')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => cardType = val);
                        },
                      ),
                    ],

                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: isEditing ? 'Save Changes' : 'Save Payment Method',
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        if (selectedTypeIndex == 0) {
                          final upiText = upiController.text.trim();
                          if (upiText.isEmpty) {
                            messenger.showSnackBar(const SnackBar(content: Text('Please enter a valid UPI ID')));
                            return;
                          }
                          final label = upiLabelController.text.trim().isNotEmpty
                              ? upiLabelController.text.trim()
                              : 'Primary UPI ID';

                          if (isEditing) {
                            final idx = _upiIds.indexWhere((item) => item['id'] == existingItem['id']);
                            if (idx != -1) {
                              _upiIds[idx] = {
                                'id': existingItem['id'] ?? 'upi_${DateTime.now().millisecondsSinceEpoch}',
                                'upi': upiText,
                                'label': label,
                              };
                            }
                          } else {
                            _upiIds.add({
                              'id': 'upi_${DateTime.now().millisecondsSinceEpoch}',
                              'upi': upiText,
                              'label': label,
                            });
                          }
                        } else {
                          final cName = cardNameController.text.trim();
                          var cNum = cardNumberController.text.trim();
                          if (cName.isEmpty || cNum.isEmpty) {
                            messenger.showSnackBar(const SnackBar(content: Text('Please enter card name and number')));
                            return;
                          }
                          if (!cNum.startsWith('••••') && cNum.length > 4) {
                            cNum = '•••• ${cNum.substring(cNum.length - 4)}';
                          }

                          if (isEditing) {
                            final idx = _cards.indexWhere((item) => item['id'] == existingItem['id']);
                            if (idx != -1) {
                              _cards[idx] = {
                                'id': existingItem['id'] ?? 'card_${DateTime.now().millisecondsSinceEpoch}',
                                'name': cName,
                                'number': cNum,
                                'type': cardType,
                              };
                            }
                          } else {
                            _cards.add({
                              'id': 'card_${DateTime.now().millisecondsSinceEpoch}',
                              'name': cName,
                              'number': cNum,
                              'type': cardType,
                            });
                          }
                        }

                        final navigator = Navigator.of(modalCtx);
                        await _savePaymentMethods();
                        if (mounted) {
                          setState(() {});
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(content: Text(isEditing ? 'Payment method updated successfully' : 'Payment method added successfully')),
                          );
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
      },
    );
  }

  // ==========================================
  // DELETE CONFIRMATION
  // ==========================================
  void _confirmDelete({required bool isCard, required Map<String, String> item}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Payment Method?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          content: Text(
            isCard
                ? 'Are you sure you want to remove ${item['name']} (${item['number']})?'
                : 'Are you sure you want to remove ${item['upi']}?',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(ctx);
                if (isCard) {
                  setState(() => _cards.removeWhere((c) => c['id'] == item['id'] || (c['number'] == item['number'] && c['name'] == item['name'])));
                } else {
                  setState(() => _upiIds.removeWhere((u) => u['id'] == item['id'] || u['upi'] == item['upi']));
                }
                await _savePaymentMethods();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(isCard ? 'Card removed successfully' : 'UPI ID removed successfully')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF0A2342))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0A2342)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F5F9), height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Saved UPI IDs Section
                        const Text(
                          'Saved UPI IDs',
                          style: TextStyle(
                            color: AppTheme.secondaryText,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_upiIds.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Center(
                              child: Text(
                                'No saved UPI IDs. Tap below to add one.',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              ),
                            ),
                          )
                        else
                          ..._upiIds.map((u) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF007BFF).withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primaryBlue, size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            u['upi'] ?? '',
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF0A2342)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            u['label'] ?? 'UPI ID',
                                            style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          _showAddOrEditModal(isCard: false, existingItem: u);
                                        } else if (val == 'delete') {
                                          _confirmDelete(isCard: false, item: u);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0A2342)),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                                              SizedBox(width: 8),
                                              Text('Delete', style: TextStyle(color: AppTheme.error)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),

                        const SizedBox(height: 20),

                        // Saved Cards Section
                        const Text(
                          'Saved Cards',
                          style: TextStyle(
                            color: AppTheme.secondaryText,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_cards.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Center(
                              child: Text(
                                'No saved cards. Tap below to add one.',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              ),
                            ),
                          )
                        else
                          ..._cards.map((c) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0A2342).withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.credit_card_rounded, color: AppTheme.primaryNavy, size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c['name'] ?? '',
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF0A2342)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${c['number'] ?? ''} • ${c['type'] ?? 'Tokenized'}',
                                            style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          _showAddOrEditModal(isCard: true, existingItem: c);
                                        } else if (val == 'delete') {
                                          _confirmDelete(isCard: true, item: c);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0A2342)),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                                              SizedBox(width: 8),
                                              Text('Delete', style: TextStyle(color: AppTheme.error)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                  ),
                  child: SafeArea(
                    top: false,
                    child: PrimaryButton(
                      text: 'Add Payment Method',
                      onPressed: () => _showAddOrEditModal(isCard: false),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
