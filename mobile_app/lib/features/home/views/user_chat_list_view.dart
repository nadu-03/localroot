import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/controllers/user_controller.dart';
import '../../../data/api/api_exceptions.dart';
import '../../../util/color_resources.dart';
import '../services/message_service.dart';
import 'user_chat_view.dart';

class UserChatListView extends StatefulWidget {
  final ChatListMode mode;
  final String title;
  final String participantRole;
  final String emptyMessage;

  const UserChatListView({
    super.key,
    this.mode = ChatListMode.seller,
    this.title = 'user_chats',
    this.participantRole = 'user',
    this.emptyMessage = 'no_user_chats',
  });

  @override
  State<UserChatListView> createState() => _UserChatListViewState();
}

class _UserChatListViewState extends State<UserChatListView> {
  final MessageService _messageService = MessageService();
  final List<ChatThread> _chats = <ChatThread>[];

  bool _isLoading = false;
  String? _error;

  int? get _currentUserId => Get.find<UserController>().user.value?.userId;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final userId = _currentUserId;
    if (userId == null) {
      setState(() => _error = 'please_login_view_chats'.tr);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final chats = widget.mode == ChatListMode.buyer
          ? await _messageService.fetchBuyerChats(userId)
          : await _messageService.fetchSellerChats(userId);
      if (!mounted) return;
      setState(() {
        _chats
          ..clear()
          ..addAll(chats);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'failed_load_chats'.tr);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openChat(ChatThread chat) {
    Get.to(
      () => UserChatView(
        sellerId: chat.userId,
        sellerName: chat.displayName,
        participantRole: widget.participantRole,
        itemId: chat.itemId,
        itemTitle: chat.itemTitle,
      ),
    )?.then((_) => _loadChats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: ColorResources.primaryGreen,
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: Colors.black,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              widget.title.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : _loadChats,
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading && _chats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _chats.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadChats,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(child: Text(_error!)),
          ],
        ),
      );
    }

    if (_chats.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadChats,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Text(
                widget.emptyMessage.tr,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF6F6F6F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChats,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        itemCount: _chats.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return _ChatTile(chat: chat, onTap: () => _openChat(chat));
        },
      ),
    );
  }
}

enum ChatListMode { buyer, seller }

class _ChatTile extends StatelessWidget {
  final ChatThread chat;
  final VoidCallback onTap;

  const _ChatTile({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFE6E6E6),
                child: Icon(Icons.person, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        Text(
                          _formatTime(chat.lastMessageAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF7A7A7A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5F5F5F),
                      ),
                    ),
                    if (chat.itemTitle != null &&
                        chat.itemTitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        chat.itemTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xFF6F6F6F)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? value) {
    if (value == null) return '';
    final now = DateTime.now();
    if (value.year != now.year ||
        value.month != now.month ||
        value.day != now.day) {
      return '${value.month}/${value.day}/${value.year}';
    }

    final hour = value.hour == 0
        ? 12
        : (value.hour > 12 ? value.hour - 12 : value.hour);
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
