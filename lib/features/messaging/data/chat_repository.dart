import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/chat_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

class ChatRepository {
  final List<ConversationSummaryModel> _demoConversations = [
    ConversationSummaryModel(
      id: '90000000-0000-0000-0000-000000000001',
      title: 'Dr. Sarah Watson Consultation',
      participantName: 'Dr. Sarah Watson',
      participantAvatar: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
      lastMessage: 'Please bring your previous ECG records along if possible.',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      unreadCount: 1,
      isOnline: true,
    ),
    ConversationSummaryModel(
      id: '90000000-0000-0000-0000-000000000002',
      title: 'AuraCare Clinical Support Desk',
      participantName: 'Hospital Support Team',
      participantAvatar: null,
      lastMessage: 'Your lab appointment for lipid panel is confirmed.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 4)),
      unreadCount: 0,
      isOnline: true,
    ),
  ];

  final Map<String, List<ChatMessageModel>> _demoMessages = {
    '90000000-0000-0000-0000-000000000001': [
      ChatMessageModel(
        id: 'm-1',
        conversationId: '90000000-0000-0000-0000-000000000001',
        senderId: '30000000-0000-0000-0000-000000000001',
        senderName: 'Emma Stonehurst',
        text: 'Hello Dr. Watson, I have been recording my morning blood pressure as requested.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        isFromMe: true,
      ),
      ChatMessageModel(
        id: 'm-2',
        conversationId: '90000000-0000-0000-0000-000000000001',
        senderId: '20000000-0000-0000-0000-000000000001',
        senderName: 'Dr. Sarah Watson',
        text: 'Hi Emma, excellent! What have your average readings been over the past 3 days?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
        isFromMe: false,
      ),
      ChatMessageModel(
        id: 'm-3',
        conversationId: '90000000-0000-0000-0000-000000000001',
        senderId: '30000000-0000-0000-0000-000000000001',
        senderName: 'Emma Stonehurst',
        text: 'They have averaged around 122/78 mmHg, heart rate around 68 bpm.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        isFromMe: true,
      ),
      ChatMessageModel(
        id: 'm-4',
        conversationId: '90000000-0000-0000-0000-000000000001',
        senderId: '20000000-0000-0000-0000-000000000001',
        senderName: 'Dr. Sarah Watson',
        text: 'Those numbers are within optimal target range. Keep taking Lisinopril consistently.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isFromMe: false,
      ),
      ChatMessageModel(
        id: 'm-5',
        conversationId: '90000000-0000-0000-0000-000000000001',
        senderId: '20000000-0000-0000-0000-000000000001',
        senderName: 'Dr. Sarah Watson',
        text: 'Please bring your previous ECG records along if possible.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        isFromMe: false,
      ),
    ],
  };

  Future<List<ConversationSummaryModel>> getConversations() async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final List res = await client.from('conversations').select('*, conversation_members(*)');
        if (res.isNotEmpty) {
          // Can parse remote conversations
        }
      } catch (_) {}
    }
    return _demoConversations;
  }

  Future<List<ChatMessageModel>> getMessages(String conversationId) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final List res = await client
            .from('messages')
            .select('*, profiles(full_name)')
            .eq('conversation_id', conversationId)
            .order('created_at', ascending: true);
        final currentId = client.auth.currentUser?.id;
        return res.map((e) => ChatMessageModel.fromJson(Map<String, dynamic>.from(e), currentUserId: currentId)).toList();
      } catch (_) {}
    }
    return _demoMessages[conversationId] ?? [];
  }

  Future<void> sendMessage(String conversationId, String text) async {
    final msg = ChatMessageModel(
      id: 'm-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: '30000000-0000-0000-0000-000000000001',
      senderName: 'Emma Stonehurst',
      text: text,
      createdAt: DateTime.now(),
      isFromMe: true,
    );

    _demoMessages.putIfAbsent(conversationId, () => []).add(msg);

    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        await client.from('messages').insert({
          'conversation_id': conversationId,
          'message_text': text,
        });
      } catch (_) {}
    }
  }
}
