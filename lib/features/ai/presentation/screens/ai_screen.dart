import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/paisaji_brand.dart';
import 'package:zeokash/features/ai/data/ji_ai_repository.dart';
import 'package:zeokash/features/ai/presentation/widgets/ai_structured_card.dart';
import 'package:zeokash/features/ai/presentation/widgets/ji_ai_mascot.dart';
import 'package:zeokash/features/ai/presentation/widgets/ji_ai_suggestion_card.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  String? _conversationId;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add({'isUser': true, 'text': query});
      _messageController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final repo = ref.read(jiAiRepositoryProvider);
      final response = await repo.sendMessage(query, conversationId: _conversationId);

      if (!mounted) return;

      setState(() {
        _isTyping = false;
        if (response.conversationId != null) {
          _conversationId = response.conversationId;
        }

        _messages.add({
          'isUser': false,
          'isStructured': false,
          'text': response.reply,
        });

        if (response.action != null) {
          final act = response.action!;
          _messages.add({
            'isUser': false,
            'isStructured': true,
            'title': act.title,
            'subtitle': act.subtitle,
            'amountTitle': act.actionType == 'RECHARGE' ? 'Plan Value' : 'Amount',
            'amount': act.amount,
            'dateTitle': 'Status',
            'date': 'Verified',
            'actionText': act.actionText,
            'route': act.route,
            'routeExtra': null,
          });
        }
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({
          'isUser': false,
          'isStructured': false,
          'text': 'Unable to connect to PaisaJi assistant right now. Please check your connection and try again.',
        });
      });
      _scrollToBottom();
    }
  }

  void _resetChat() {
    setState(() {
      _messages.clear();
      _isTyping = false;
      _conversationId = null;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Response copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = _messages.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFF1F5F9),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Image.asset(
                    PaisaJiBrand.monogram,
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Inter',
                              color: Color(0xFF0A2342),
                            ),
                            children: [
                              TextSpan(text: 'PaisaJi '),
                              TextSpan(
                                text: 'AI',
                                style: TextStyle(color: Color(0xFF007BFF)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Your smart personal financial assistant',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Inter',
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isEmpty)
                    IconButton(
                      tooltip: 'New Chat',
                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0A2342), size: 22),
                      onPressed: _resetChat,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isEmpty ? _buildEmptyState() : _buildMessageList(),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Center(
            child: JiAiMascot(size: 230),
          ),
          const SizedBox(height: 14),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
                color: Color(0xFF0A2342),
              ),
              children: [
                TextSpan(text: 'How can I help you '),
                TextSpan(
                  text: 'today?',
                  style: TextStyle(color: Color(0xFF007BFF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Suggested Action 1: Failed Recharge Troubleshooting
          JiAiSuggestionCard(
            icon: Icons.sync_problem_rounded,
            text: 'Why did my recharge fail?',
            onTap: () => _sendMessage('Why did my recharge fail?'),
          ),
          // Suggested Action 2: Wallet & G Coins
          JiAiSuggestionCard(
            icon: Icons.account_balance_wallet_outlined,
            text: 'Show my wallet balance & G Coins',
            onTap: () => _sendMessage('What is my wallet balance and how many G coins do I have?'),
          ),
          // Suggested Action 3: Recharge Validity & Expiry
          JiAiSuggestionCard(
            icon: Icons.timer_outlined,
            text: 'When will my recharge expire?',
            onTap: () => _sendMessage('When will my recharge expire and remind me?'),
          ),
          // Suggested Action 4: Monthly Expense
          JiAiSuggestionCard(
            icon: Icons.pie_chart_outline_rounded,
            text: 'How much did I spend this month?',
            onTap: () => _sendMessage('How much did I spend this month?'),
          ),
          // Suggested Action 5: Unpaid Bills
          JiAiSuggestionCard(
            icon: Icons.receipt_long_outlined,
            text: 'Show my unpaid bills',
            onTap: () => _sendMessage('Show my unpaid bills and due dates'),
          ),
          // Suggested Action 6: Guide
          JiAiSuggestionCard(
            icon: Icons.help_outline_rounded,
            text: 'How can PaisaJi help me?',
            onTap: () => _sendMessage('How can PaisaJi help me?'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF007BFF),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Ji-AI is analyzing your account...',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final msg = _messages[index];
        final isUser = msg['isUser'] as bool;

        if (isUser) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
              decoration: BoxDecoration(
                color: const Color(0xFF0A2342),
                borderRadius: BorderRadius.circular(20).copyWith(bottomRight: const Radius.circular(4)),
              ),
              child: Text(
                msg['text'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          );
        } else {
          final isStructured = msg['isStructured'] as bool? ?? false;

          if (isStructured) {
            return AiStructuredCard(
              title: msg['title'] as String,
              subtitle: msg['subtitle'] as String,
              amountTitle: msg['amountTitle'] as String,
              amount: (msg['amount'] is num) ? (msg['amount'] as num).toDouble() : 0.0,
              dateTitle: msg['dateTitle'] as String,
              date: msg['date'] as String,
              actionText: msg['actionText'] as String,
              onActionTap: () {
                final route = msg['route'] as String?;
                final extra = msg['routeExtra'];
                if (route != null) {
                  context.push(route, extra: extra);
                }
              },
            );
          } else {
            final text = msg['text'] as String? ?? '';
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: const Radius.circular(4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      text,
                      style: const TextStyle(
                        color: Color(0xFF0A2342),
                        fontSize: 14.5,
                        fontFamily: 'Inter',
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => _copyToClipboard(text),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                Icon(Icons.copy_rounded, size: 14, color: Color(0xFF94A3B8)),
                                SizedBox(width: 4),
                                Text(
                                  'Copy',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFDCE7F5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0A2342),
                  fontFamily: 'Inter',
                ),
                decoration: const InputDecoration(
                  hintText: 'Ask PaisaJi AI anything...',
                  hintStyle: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Inter',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: const Color(0xFF007BFF),
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              onTap: () => _sendMessage(_messageController.text),
              borderRadius: BorderRadius.circular(22),
              child: const SizedBox(
                height: 46,
                width: 46,
                child: Center(
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
