import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/controllers/user_controller.dart';
import '../../../data/api/api_exceptions.dart';
import '../../../util/color_resources.dart';
import '../services/chatbot_service.dart';

class AiChatBotView extends StatefulWidget {
  const AiChatBotView({super.key});

  @override
  State<AiChatBotView> createState() => _AiChatBotViewState();
}

class _AiChatBotViewState extends State<AiChatBotView> {
  final ChatbotService _chatbotService = ChatbotService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatEntry> _messages = <_ChatEntry>[];

  bool _isLoadingHistory = true;
  bool _isSending = false;

  int? get _currentUserId => Get.find<UserController>().user.value?.userId;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);

    try {
      final history = await _chatbotService.fetchHistory(userId: _currentUserId);
      if (!mounted) return;

      setState(() {
        _messages
          ..clear()
          ..addAll(_buildMessagesFromHistory(history));

        if (_messages.isEmpty) {
          _messages.add(_ChatEntry.bot(_welcomeMessage));
        }
      });
      _scrollToBottom();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..add(_ChatEntry.bot(_welcomeMessage));
      });
      Get.snackbar('ai_chat_bot'.tr, e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..add(_ChatEntry.bot(_welcomeMessage));
      });
      Get.snackbar('ai_chat_bot'.tr, 'Failed to load chatbot history');
    } finally {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  List<_ChatEntry> _buildMessagesFromHistory(
    List<ChatbotHistoryItem> history,
  ) {
    final sorted = <ChatbotHistoryItem>[...history]
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });

    return sorted
        .expand(
          (item) => <_ChatEntry>[
            _ChatEntry.user(item.query),
            if (item.response.trim().isNotEmpty)
              _ChatEntry.bot(item.response, intent: item.intent),
          ],
        )
        .toList();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() {
      _isSending = true;
      _messages.add(_ChatEntry.user(message));
    });
    _scrollToBottom();

    try {
      final reply = await _chatbotService.sendDonationMessage(
        message: message,
        userId: _currentUserId,
      );

      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatEntry.bot(
            reply.reply.trim().isEmpty
                ? 'I can help you with donation-related questions.'
                : reply.reply,
            intent: reply.intent,
          ),
        );
      });
      _scrollToBottom();
    } on ApiException catch (e) {
      _messageController.text = message;
      Get.snackbar('ai_chat_bot'.tr, e.message);
    } catch (_) {
      _messageController.text = message;
      Get.snackbar('ai_chat_bot'.tr, 'Failed to send chatbot message');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoadingHistory
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: ColorResources.primaryGreen,
                      ),
                    )
                  : RefreshIndicator(
                      color: ColorResources.primaryGreen,
                      onRefresh: _loadHistory,
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        itemCount: _messages.length + (_isSending ? 1 : 0),
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (_isSending && index == _messages.length) {
                            return const _BotBubble(message: 'Typing...');
                          }

                          final message = _messages[index];
                          return message.isUser
                              ? _UserBubble(message: message.message)
                              : _BotBubble(
                                  message: message.message,
                                  intent: message.intent,
                                );
                        },
                      ),
                    ),
            ),
            _buildComposer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: ColorResources.primaryGreen,
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: Colors.black,
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(Icons.smart_toy_outlined, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ai_chat_bot'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _isLoadingHistory ? 'Loading history' : 'always_available'.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black87),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isLoadingHistory ? null : _loadHistory,
            icon: const Icon(Icons.refresh, size: 21),
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_isSending,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'ask_about_donations'.tr,
                filled: true,
                fillColor: const Color(0xFFE6E6E6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 46,
            height: 46,
            child: IconButton(
              onPressed: _isSending ? null : _sendMessage,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF6D4C41),
                disabledBackgroundColor: const Color(0xFFBCAAA4),
              ),
              icon: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatEntry {
  final String message;
  final bool isUser;
  final String? intent;

  const _ChatEntry({
    required this.message,
    required this.isUser,
    this.intent,
  });

  factory _ChatEntry.user(String message) {
    return _ChatEntry(message: message, isUser: true);
  }

  factory _ChatEntry.bot(String message, {String? intent}) {
    return _ChatEntry(message: message, isUser: false, intent: intent);
  }
}

class _BotBubble extends StatelessWidget {
  final String message;
  final String? intent;

  const _BotBubble({required this.message, this.intent});

  @override
  Widget build(BuildContext context) {
    final hasIntent = intent != null && intent!.trim().isNotEmpty;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            if (hasIntent) ...[
              const SizedBox(height: 6),
              Text(
                intent!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6D4C41),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String message;

  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColorResources.primaryGreen,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(message),
      ),
    );
  }
}

const String _welcomeMessage =
    'Hi, I am LocalRoot AI Bot. Ask me about food, clothes, education, toys, medical, money, or hygiene donations.';
