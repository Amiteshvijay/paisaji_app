import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/ai/presentation/widgets/ai_structured_card.dart';
import 'package:zeokash/features/ai/presentation/widgets/ai_suggestion_chip.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  void _sendMessage(String text) {
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _messageController.clear();
      _isTyping = true;
    });

    // Simulate AI processing
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        
        // Mocking structured intent response based on prompt
        if (text.toLowerCase().contains('hdfc')) {
          _messages.add({
            'isUser': false,
            'isStructured': true,
            'title': 'HDFC Credit Card',
            'subtitle': '•••• 4321',
            'amountTitle': 'Amount Due',
            'amount': 8500.0,
            'dateTitle': 'Due Date',
            'date': '18 Aug',
            'actionText': 'Pay Bill',
          });
        } else {
          _messages.add({
            'isUser': false,
            'isStructured': false,
            'text': 'I can help you pay bills, check balances, or find vouchers. What would you like to do?',
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.aiTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: AppTheme.aiTeal, size: 20),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ZeoAI', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                Text('Your smart payments assistant', style: TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty ? _buildEmptyState() : _buildMessageList(),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.aiTeal.withValues(alpha: 0.2),
                  AppTheme.background,
                ],
              ),
            ),
            child: const Icon(Icons.auto_awesome, size: 64, color: AppTheme.aiTeal),
          ),
          const SizedBox(height: 32),
          const Text(
            'How can I help you today?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              AiSuggestionChip(
                label: 'When is my HDFC card due?',
                onTap: () => _sendMessage('When is my HDFC card due?'),
              ),
              AiSuggestionChip(
                label: 'Recharge my Airtel number',
                onTap: () => _sendMessage('Recharge my Airtel number with the same plan.'),
              ),
              AiSuggestionChip(
                label: 'Show my unpaid bills',
                onTap: () => _sendMessage('Show my unpaid bills.'),
              ),
              AiSuggestionChip(
                label: 'Find a ₹500 Amazon voucher',
                onTap: () => _sendMessage('Find a ₹500 Amazon voucher.'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.aiTeal),
            ),
          );
        }

        final msg = _messages[index];
        final isUser = msg['isUser'] as bool;

        if (isUser) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(16).copyWith(bottomRight: const Radius.circular(4)),
              ),
              child: Text(
                msg['text'] as String,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          );
        } else {
          final isStructured = msg['isStructured'] as bool;
          
          if (isStructured) {
            return AiStructuredCard(
              title: msg['title'] as String,
              subtitle: msg['subtitle'] as String,
              amountTitle: msg['amountTitle'] as String,
              amount: msg['amount'] as double,
              dateTitle: msg['dateTitle'] as String,
              date: msg['date'] as String,
              actionText: msg['actionText'] as String,
              onActionTap: () {
                context.push('/payment/review', extra: {
                  'title': msg['title'],
                  'subtitle': msg['subtitle'],
                  'amount': msg['amount'],
                });
              },
            );
          } else {
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: const Radius.circular(4)),
                ),
                child: Text(
                  msg['text'] as String,
                  style: const TextStyle(color: AppTheme.primaryText, fontSize: 16),
                ),
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: _messageController,
              hintText: 'Ask ZeoAI anything...',
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => _sendMessage(_messageController.text),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: AppTheme.aiTeal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
