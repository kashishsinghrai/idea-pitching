import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/core/utils/responsive_utils.dart';
import 'package:navojit_tech/features/investor/repositories/message_repository.dart';

final messageRepositoryProvider = Provider((ref) => MessageRepository());

// ── Models ────────────────────────────────────────────────────────────────────

class ChatMessage {
  final String id;
  final String text;
  final bool fromMe;
  final DateTime time;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.fromMe,
    required this.time,
  });
}

class Conversation {
  final String id;
  final String name;
  final String company;
  final String lastMessage;
  final String timeAgo;
  final bool isUnread;
  final String initial;
  final Color color;
  final List<ChatMessage> messages;

  const Conversation({
    required this.id,
    required this.name,
    required this.company,
    required this.lastMessage,
    required this.timeAgo,
    required this.isUnread,
    required this.initial,
    required this.color,
    required this.messages,
  });

  Conversation copyWith({List<ChatMessage>? messages, bool? isUnread, String? lastMessage, String? timeAgo}) {
    return Conversation(
      id: id,
      name: name,
      company: company,
      lastMessage: lastMessage ?? this.lastMessage,
      timeAgo: timeAgo ?? this.timeAgo,
      isUnread: isUnread ?? this.isUnread,
      initial: initial,
      color: color,
      messages: messages ?? this.messages,
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

class MessagesState {
  final List<Conversation> conversations;
  final String? activeConversationId;

  const MessagesState({
    required this.conversations,
    this.activeConversationId,
  });

  MessagesState copyWith({
    List<Conversation>? conversations,
    String? activeConversationId,
  }) {
    return MessagesState(
      conversations: conversations ?? this.conversations,
      activeConversationId: activeConversationId ?? this.activeConversationId,
    );
  }

  Conversation? get activeConversation {
    if (activeConversationId == null) return null;
    try {
      return conversations.firstWhere((c) => c.id == activeConversationId);
    } catch (_) {
      return null;
    }
  }
}

class MessagesNotifier extends StateNotifier<MessagesState> {
  final MessageRepository _repository;

  MessagesNotifier(this._repository) : super(const MessagesState(conversations: [])) {
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    try {
      final data = await _repository.getConversations();
      final List<Conversation> convs = data.map((c) {
        return Conversation(
          id: c['id'],
          name: c['name'],
          company: c['company'],
          lastMessage: c['lastMessage'] ?? '',
          timeAgo: 'Just now', // Ideally formatted from c['timeAgo']
          isUnread: c['isUnread'] ?? false,
          initial: c['initial'] ?? 'U',
          color: AppColors.primaryBlue, // Could hash string to generate consistent colors
          messages: (c['messages'] as List<dynamic>).map((m) {
            return ChatMessage(
              id: m['id'],
              text: m['text'],
              fromMe: m['fromMe'],
              time: DateTime.parse(m['time']),
            );
          }).toList(),
        );
      }).toList();

      state = state.copyWith(conversations: convs);
      if (convs.isNotEmpty && state.activeConversationId == null) {
        selectConversation(convs.first.id);
      }
    } catch (e) {
      // Handle error implicitly
    }
  }

  void selectConversation(String id) {
    final updated = state.conversations.map((c) {
      if (c.id == id) return c.copyWith(isUnread: false);
      return c;
    }).toList();
    state = state.copyWith(conversations: updated, activeConversationId: id);
  }

  Future<void> sendMessage(String conversationId, String text) async {
    if (text.trim().isEmpty) return;
    
    // Extract otherUserId and pitchId from convId: format is otherUserId_pitchId
    final parts = conversationId.split('_');
    if (parts.length < 2) return;
    final receiverId = parts[0];
    final pitchId = parts[1];

    final newMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      fromMe: true,
      time: DateTime.now(),
    );
    final updated = state.conversations.map((c) {
      if (c.id == conversationId) {
        return c.copyWith(
          messages: [...c.messages, newMsg],
          lastMessage: text.trim(),
          timeAgo: 'Just now',
        );
      }
      return c;
    }).toList();
    state = state.copyWith(conversations: updated);

    try {
      await _repository.sendMessage(receiverId, pitchId, text.trim());
    } catch (e) {
      // Revert if failed
    }
  }
}

final messagesProvider = StateNotifierProvider<MessagesNotifier, MessagesState>(
  (ref) => MessagesNotifier(ref.watch(messageRepositoryProvider)),
);

// ── Screen ────────────────────────────────────────────────────────────────────

class InvestorMessagesScreen extends ConsumerWidget {
  const InvestorMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(messagesProvider);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: isDesktop
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.surfaceWhite,
              elevation: 0,
              title: Text('Messages', style: AppTextStyles.heading2),
            )
          : (state.activeConversationId == null
              ? AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: AppColors.surfaceWhite,
                  elevation: 0,
                  title: Text('Messages', style: AppTextStyles.heading2),
                )
              : AppBar(
                  backgroundColor: AppColors.surfaceWhite,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => ref.read(messagesProvider.notifier).selectConversation(''),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.activeConversation?.name ?? '',
                        style: AppTextStyles.heading3,
                      ),
                      Text(
                        state.activeConversation?.company ?? '',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                )),
      body: isDesktop
          ? _buildDesktopLayout(context, ref, state)
          : _buildMobileLayout(context, ref, state),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref, MessagesState state) {
    return Row(
      children: [
        // Conversation List (sidebar)
        SizedBox(
          width: 300,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceWhite,
              border: Border(right: BorderSide(color: AppColors.borderLight)),
            ),
            child: _buildConversationList(ref, state),
          ),
        ),
        // Chat View
        Expanded(
          child: state.activeConversation != null
              ? _ChatView(conversation: state.activeConversation!)
              : _buildNoSelection(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref, MessagesState state) {
    if (state.activeConversation != null && state.activeConversationId != '') {
      return _ChatView(conversation: state.activeConversation!);
    }
    return Container(
      color: AppColors.surfaceWhite,
      child: _buildConversationList(ref, state),
    );
  }

  Widget _buildConversationList(WidgetRef ref, MessagesState state) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: state.conversations.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
      itemBuilder: (context, index) {
        final conv = state.conversations[index];
        final isActive = conv.id == state.activeConversationId;

        return InkWell(
          onTap: () => ref.read(messagesProvider.notifier).selectConversation(conv.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color: isActive ? AppColors.surfaceLightBlue : Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.md,
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: conv.color.withAlpha(25),
                      child: Text(
                        conv.initial,
                        style: AppTextStyles.heading3.copyWith(color: conv.color),
                      ),
                    ),
                    if (conv.isUnread)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              conv.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: conv.isUnread ? FontWeight.w700 : FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            conv.timeAgo,
                            style: AppTextStyles.caption.copyWith(
                              color: conv.isUnread ? AppColors.primaryBlue : AppColors.textTertiary,
                              fontWeight: conv.isUnread ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        conv.company,
                        style: AppTextStyles.caption.copyWith(color: AppColors.accentTeal, fontWeight: FontWeight.w600, fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        conv.lastMessage,
                        style: AppTextStyles.caption.copyWith(
                          color: conv.isUnread ? AppColors.textPrimary : AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.xl),
            decoration: BoxDecoration(
              color: AppColors.surfaceLightBlue,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: AppDimensions.xl),
          Text('Select a conversation', style: AppTextStyles.heading3),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Choose a conversation from the list to start messaging.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

// ── Chat View ─────────────────────────────────────────────────────────────────

class _ChatView extends ConsumerStatefulWidget {
  final Conversation conversation;

  const _ChatView({required this.conversation});

  @override
  ConsumerState<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<_ChatView> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _send() {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;
    ref.read(messagesProvider.notifier).sendMessage(widget.conversation.id, text);
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  String _formatTime(DateTime time) {
    final h = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    // Watch so messages update in real time
    final state = ref.watch(messagesProvider);
    final conv = state.conversations.firstWhere(
      (c) => c.id == widget.conversation.id,
      orElse: () => widget.conversation,
    );

    return Column(
      children: [
        // Chat header (desktop only — mobile uses AppBar)
        if (ResponsiveUtils.isDesktop(context))
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.md,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceWhite,
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: conv.color.withAlpha(25),
                  child: Text(conv.initial, style: TextStyle(color: conv.color, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: AppDimensions.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(conv.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                    Text(conv.company, style: AppTextStyles.caption.copyWith(color: AppColors.accentTeal, fontWeight: FontWeight.w600)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.successGreen, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text('NDA Signed', style: AppTextStyles.caption.copyWith(color: AppColors.successGreen, fontWeight: FontWeight.w600, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppDimensions.base),
            itemCount: conv.messages.length,
            itemBuilder: (context, index) {
              final msg = conv.messages[index];
              return _buildBubble(msg, conv);
            },
          ),
        ),

        // Input bar
        Container(
          padding: EdgeInsets.only(
            left: AppDimensions.base,
            right: AppDimensions.base,
            top: AppDimensions.sm,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.base,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            border: Border(top: BorderSide(color: AppColors.borderLight)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: AppTextStyles.bodyMedium,
                  onSubmitted: (_) => _send(),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Type a message…',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.base,
                      vertical: AppDimensions.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.blueGradient,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBubble(ChatMessage msg, Conversation conv) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: msg.fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.fromMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: conv.color.withAlpha(25),
              child: Text(conv.initial, style: TextStyle(color: conv.color, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: AppDimensions.sm),
          ],
          Column(
            crossAxisAlignment: msg.fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: msg.fromMe ? AppColors.primaryBlue : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppDimensions.radiusMd),
                      topRight: const Radius.circular(AppDimensions.radiusMd),
                      bottomLeft: Radius.circular(msg.fromMe ? AppDimensions.radiusMd : 4),
                      bottomRight: Radius.circular(msg.fromMe ? 4 : AppDimensions.radiusMd),
                    ),
                    border: msg.fromMe ? null : Border.all(color: AppColors.borderLight),
                    boxShadow: AppColors.subtleShadow,
                  ),
                  child: Text(
                    msg.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: msg.fromMe ? Colors.white : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTime(msg.time),
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10),
              ),
            ],
          ),
          if (msg.fromMe) const SizedBox(width: AppDimensions.sm),
        ],
      ),
    );
  }
}
