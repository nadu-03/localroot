import '../../../data/api/api_exceptions.dart';
import '../../../data/api/api_manager.dart';
import '../../../util/app_constant.dart';

class ChatbotService {
  Future<ChatbotReply> sendDonationMessage({
    required String message,
    int? userId,
  }) async {
    try {
      final payload = <String, dynamic>{'message': message};
      if (userId != null) payload['user_id'] = userId;

      final response = await ApiManager.instance.post(
        AppConstant.chatbotDonation,
        data: payload,
      );

      final data = _extractData(response.data);
      if (data is Map) {
        return ChatbotReply.fromJson(data);
      }

      if (response.data is Map) {
        return ChatbotReply.fromJson(response.data as Map);
      }

      throw ApiException('Invalid chatbot response');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to send chatbot message: $e');
    }
  }

  Future<List<ChatbotHistoryItem>> fetchHistory({int? userId}) async {
    try {
      final path = userId == null
          ? AppConstant.chatbotHistory
          : '${AppConstant.chatbotHistory}/$userId';
      final response = await ApiManager.instance.get(path);
      final rawItems = _extractListData(response.data);

      return rawItems
          .whereType<Map>()
          .map(ChatbotHistoryItem.fromJson)
          .where((item) => item.query.trim().isNotEmpty)
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch chatbot history: $e');
    }
  }

  dynamic _extractData(dynamic responseData) {
    return responseData is Map && responseData['data'] != null
        ? responseData['data']
        : responseData;
  }

  List<dynamic> _extractListData(dynamic responseData) {
    final rawData = _extractData(responseData);
    return rawData is List ? rawData : <dynamic>[];
  }
}

class ChatbotReply {
  final String reply;
  final String? intent;

  const ChatbotReply({required this.reply, this.intent});

  factory ChatbotReply.fromJson(Map<dynamic, dynamic> json) {
    return ChatbotReply(
      reply:
          (json['reply'] ??
                  json['response'] ??
                  json['bot_reply'] ??
                  json['botReply'] ??
                  '')
              .toString(),
      intent: (json['intent'] ?? json['category'])?.toString(),
    );
  }
}

class ChatbotHistoryItem {
  final int id;
  final int? userId;
  final String query;
  final String response;
  final String? intent;
  final DateTime? createdAt;

  const ChatbotHistoryItem({
    required this.id,
    this.userId,
    required this.query,
    required this.response,
    this.intent,
    this.createdAt,
  });

  factory ChatbotHistoryItem.fromJson(Map<dynamic, dynamic> json) {
    return ChatbotHistoryItem(
      id:
          int.tryParse((json['query_id'] ?? json['id'])?.toString() ?? '') ??
          0,
      userId: int.tryParse(json['user_id']?.toString() ?? ''),
      query: (json['query'] ?? json['message'] ?? '').toString(),
      response: (json['response'] ?? json['reply'] ?? '').toString(),
      intent: json['intent']?.toString(),
      createdAt: DateTime.tryParse(
        (json['created_at'] ?? json['createdAt'])?.toString() ?? '',
      ),
    );
  }
}
