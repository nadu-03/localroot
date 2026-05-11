import '../../../data/api/api_exceptions.dart';
import '../../../data/api/api_manager.dart';
import '../../../util/app_constant.dart';

class MessageService {
  Future<List<ChatThread>> fetchBuyerChats(int userId) async {
    try {
      final sentResponse = await ApiManager.instance.get(
        '${AppConstant.getChatMessages}/sender/$userId',
      );

      return _buildChatThreads(
        _extractListData(sentResponse.data),
        otherUserType: ChatOtherUserType.receiver,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch buyer chats: $e');
    }
  }

  Future<List<ChatThread>> fetchSellerChats(int userId) async {
    try {
      final receivedResponse = await ApiManager.instance.get(
        '${AppConstant.getChatMessages}/receiver/$userId',
      );

      return _buildChatThreads(
        _extractListData(receivedResponse.data),
        otherUserType: ChatOtherUserType.sender,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch seller chats: $e');
    }
  }

  List<ChatThread> _buildChatThreads(
    List<dynamic> rawMessages, {
    required ChatOtherUserType otherUserType,
  }) {
    final sortedMessages = <dynamic>[...rawMessages]
      ..sort((a, b) {
        final aDate = a is Map ? _messageDate(a) : null;
        final bDate = b is Map ? _messageDate(b) : null;
        return (bDate ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
          aDate ?? DateTime.fromMillisecondsSinceEpoch(0),
        );
      });

    final chatsByParticipant = <String, ChatThread>{};
    for (final entry in sortedMessages) {
      if (entry is Map) {
        final chat = ChatThread.fromDirectionalMessageJson(
          entry,
          otherUserType: otherUserType,
        );
        final key = '${chat.userId}:${chat.itemId ?? 0}';
        if (chat.userId != 0 && !chatsByParticipant.containsKey(key)) {
          chatsByParticipant[key] = chat;
        }
      }
    }

    return chatsByParticipant.values.toList();
  }

  DateTime? _messageDate(Map<dynamic, dynamic> json) {
    return DateTime.tryParse(
      (json['created_at'] ?? json['createdAt'])?.toString() ?? '',
    );
  }

  List<dynamic> _extractListData(dynamic responseData) {
    final rawData = responseData is Map && responseData['data'] != null
        ? responseData['data']
        : responseData;
    return rawData is List ? rawData : <dynamic>[];
  }

  Future<List<ChatMessage>> fetchConversation({
    required int userId,
    required int sellerId,
    int? itemId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (itemId != null) queryParameters['itemId'] = itemId;

      final response = await ApiManager.instance.get(
        '${AppConstant.getChatMessages}/conversation/$userId/$sellerId',
        queryParameters: queryParameters,
      );

      final responseData = response.data;
      final rawMessages = responseData is Map && responseData['data'] != null
          ? responseData['data']
          : responseData;

      final messages = <ChatMessage>[];
      if (rawMessages is List) {
        for (final entry in rawMessages) {
          if (entry is Map) {
            final message = ChatMessage.fromJson(entry);
            if (message.content.isNotEmpty &&
                (itemId == null || message.itemId == itemId)) {
              messages.add(message);
            }
          }
        }
      }

      return messages;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch messages: $e');
    }
  }

  Future<ChatMessage> sendMessage({
    required int senderId,
    required int receiverId,
    required String content,
    int? itemId,
  }) async {
    try {
      final data = <String, dynamic>{
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'encrypted': false,
      };
      if (itemId != null) data['item_id'] = itemId;

      final response = await ApiManager.instance.post(
        AppConstant.sendChatMessage,
        data: data,
      );

      final responseData = response.data;
      final rawMessage = responseData is Map && responseData['data'] != null
          ? responseData['data']
          : responseData;

      if (rawMessage is Map) {
        return ChatMessage.fromJson(rawMessage);
      }

      throw ApiException('Invalid message response');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to send message: $e');
    }
  }
}

enum ChatOtherUserType { sender, receiver }

class ChatThread {
  final int userId;
  final String username;
  final String email;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int? itemId;
  final String? itemTitle;

  const ChatThread({
    required this.userId,
    required this.username,
    required this.email,
    required this.lastMessage,
    this.lastMessageAt,
    this.itemId,
    this.itemTitle,
  });

  String get displayName {
    if (username.trim().isNotEmpty) return username.trim();
    if (email.trim().isNotEmpty) return email.trim();
    return 'User';
  }

  factory ChatThread.fromJson(Map<dynamic, dynamic> json) {
    return ChatThread(
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      lastMessage: json['last_message']?.toString() ?? '',
      lastMessageAt: DateTime.tryParse(
        (json['last_message_at'] ?? json['lastMessageAt'])?.toString() ?? '',
      ),
      itemId: int.tryParse(json['item_id']?.toString() ?? ''),
      itemTitle: json['item_title']?.toString(),
    );
  }

  factory ChatThread.fromReceivedMessageJson(Map<dynamic, dynamic> json) {
    final sender = json['sender'];
    final item = json['item'];

    return ChatThread(
      userId:
          int.tryParse(json['sender_id']?.toString() ?? '') ??
          _nestedId(sender),
      username: sender is Map ? sender['username']?.toString() ?? '' : '',
      email: sender is Map ? sender['email']?.toString() ?? '' : '',
      lastMessage: json['content']?.toString() ?? '',
      lastMessageAt: DateTime.tryParse(
        (json['created_at'] ?? json['createdAt'])?.toString() ?? '',
      ),
      itemId: int.tryParse(
        (json['item_id'] ?? (item is Map ? item['item_id'] : null))
                ?.toString() ??
            '',
      ),
      itemTitle: item is Map ? item['title']?.toString() : null,
    );
  }

  factory ChatThread.fromMessageJson(
    Map<dynamic, dynamic> json, {
    required int currentUserId,
  }) {
    final senderId =
        int.tryParse(json['sender_id']?.toString() ?? '') ??
        _nestedId(json['sender']);
    final receiverId =
        int.tryParse(json['receiver_id']?.toString() ?? '') ??
        _nestedId(json['receiver']);
    final otherUser = senderId == currentUserId
        ? json['receiver']
        : json['sender'];
    final otherUserId = senderId == currentUserId ? receiverId : senderId;
    final item = json['item'];

    return ChatThread(
      userId: otherUserId,
      username: otherUser is Map ? otherUser['username']?.toString() ?? '' : '',
      email: otherUser is Map ? otherUser['email']?.toString() ?? '' : '',
      lastMessage: json['content']?.toString() ?? '',
      lastMessageAt: DateTime.tryParse(
        (json['created_at'] ?? json['createdAt'])?.toString() ?? '',
      ),
      itemId: int.tryParse(
        (json['item_id'] ?? (item is Map ? item['item_id'] : null))
                ?.toString() ??
            '',
      ),
      itemTitle: item is Map ? item['title']?.toString() : null,
    );
  }

  factory ChatThread.fromDirectionalMessageJson(
    Map<dynamic, dynamic> json, {
    required ChatOtherUserType otherUserType,
  }) {
    final otherUser = otherUserType == ChatOtherUserType.sender
        ? json['sender']
        : json['receiver'];
    final otherUserId = otherUserType == ChatOtherUserType.sender
        ? int.tryParse(json['sender_id']?.toString() ?? '') ??
              _nestedId(json['sender'])
        : int.tryParse(json['receiver_id']?.toString() ?? '') ??
              _nestedId(json['receiver']);
    final item = json['item'];

    return ChatThread(
      userId: otherUserId,
      username: otherUser is Map ? otherUser['username']?.toString() ?? '' : '',
      email: otherUser is Map ? otherUser['email']?.toString() ?? '' : '',
      lastMessage: json['content']?.toString() ?? '',
      lastMessageAt: DateTime.tryParse(
        (json['created_at'] ?? json['createdAt'])?.toString() ?? '',
      ),
      itemId: int.tryParse(
        (json['item_id'] ?? (item is Map ? item['item_id'] : null))
                ?.toString() ??
            '',
      ),
      itemTitle: item is Map ? item['title']?.toString() : null,
    );
  }

  static int _nestedId(dynamic value) {
    if (value is! Map) return 0;
    return int.tryParse((value['user_id'] ?? value['id'])?.toString() ?? '') ??
        0;
  }
}

class ChatMessage {
  final int id;
  final int senderId;
  final int receiverId;
  final int? itemId;
  final String content;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.itemId,
    required this.content,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<dynamic, dynamic> json) {
    return ChatMessage(
      id:
          int.tryParse((json['message_id'] ?? json['id'])?.toString() ?? '') ??
          0,
      senderId:
          int.tryParse(json['sender_id']?.toString() ?? '') ??
          _nestedUserId(json['sender']),
      receiverId:
          int.tryParse(json['receiver_id']?.toString() ?? '') ??
          _nestedUserId(json['receiver']),
      itemId: int.tryParse(
        (json['item_id'] ??
                    (json['item'] is Map ? json['item']['item_id'] : null))
                ?.toString() ??
            '',
      ),
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(
        (json['created_at'] ?? json['createdAt'])?.toString() ?? '',
      ),
    );
  }

  static int _nestedUserId(dynamic value) {
    if (value is! Map) return 0;
    return int.tryParse((value['user_id'] ?? value['id'])?.toString() ?? '') ??
        0;
  }
}
