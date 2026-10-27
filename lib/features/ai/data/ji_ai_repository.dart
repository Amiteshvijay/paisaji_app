import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/network/api_client.dart';

class JiAiAction {
  final String actionType;
  final String title;
  final String subtitle;
  final double amount;
  final String route;
  final String actionText;

  JiAiAction({
    required this.actionType,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.route,
    required this.actionText,
  });

  factory JiAiAction.fromJson(Map<String, dynamic> json) {
    return JiAiAction(
      actionType: json['action_type'] as String? ?? 'VIEW_HISTORY',
      title: json['title'] as String? ?? 'View Details',
      subtitle: json['subtitle'] as String? ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      route: json['route'] as String? ?? '/history',
      actionText: json['action_text'] as String? ?? 'Proceed',
    );
  }
}

class JiAiResponse {
  final String reply;
  final String? conversationId;
  final JiAiAction? action;

  JiAiResponse({
    required this.reply,
    this.conversationId,
    this.action,
  });

  factory JiAiResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final convId = data['conversation_id']?.toString();
    final replyText = data['reply'] as String? ?? '';
    
    JiAiAction? act;
    if (data['action'] != null && data['action'] is Map<String, dynamic>) {
      act = JiAiAction.fromJson(data['action'] as Map<String, dynamic>);
    } else if (data['proposed_action'] != null && data['proposed_action'] is Map<String, dynamic>) {
      act = JiAiAction.fromJson(data['proposed_action'] as Map<String, dynamic>);
    }

    return JiAiResponse(
      reply: replyText,
      conversationId: convId,
      action: act,
    );
  }
}

class JiAiRepository {
  final Dio _dio;

  JiAiRepository(this._dio);

  Future<JiAiResponse> sendMessage(String message, {String? conversationId}) async {
    try {
      final payload = <String, dynamic>{
        'message': message,
      };
      if (conversationId != null && conversationId.isNotEmpty) {
        payload['conversation_id'] = conversationId;
      }

      final response = await _dio.post(
        'zeoai/chat/',
        data: payload,
      );

      if (response.statusCode == 200 && response.data != null) {
        return JiAiResponse.fromJson(response.data as Map<String, dynamic>);
      }
      return JiAiResponse(
        reply: 'Sorry, I could not process your request at this moment. Please try again.',
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final d = e.response!.data as Map;
        final msg = d['message'] ?? d['detail'] ?? 'Connection error';
        return JiAiResponse(reply: 'PaisaJi Assistant: $msg');
      }
      return JiAiResponse(
        reply: 'Unable to connect to PaisaJi AI service. Please check your internet connection.',
      );
    } catch (e) {
      return JiAiResponse(
        reply: 'An unexpected error occurred. Please try again later.',
      );
    }
  }
}

final jiAiRepositoryProvider = Provider<JiAiRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return JiAiRepository(dio);
});
