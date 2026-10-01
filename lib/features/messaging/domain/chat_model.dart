class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final String? attachmentUrl;
  final String? attachmentType; // image, pdf, audio
  final bool isRead;
  final DateTime createdAt;
  final bool isFromMe;

  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.attachmentUrl,
    this.attachmentType,
    this.isRead = false,
    required this.createdAt,
    this.isFromMe = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final sId = json['sender_id'] as String? ?? '';
    return ChatMessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String? ?? '',
      senderId: sId,
      senderName: json['profiles']?['full_name'] as String? ?? 'User',
      text: json['message_text'] as String? ?? '',
      attachmentUrl: json['attachment_url'] as String?,
      attachmentType: json['attachment_type'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      isFromMe: currentUserId != null && currentUserId == sId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message_text': text,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
      'is_read': isRead,
    };
  }
}

class ConversationSummaryModel {
  final String id;
  final String title;
  final String participantName;
  final String? participantAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  const ConversationSummaryModel({
    required this.id,
    required this.title,
    required this.participantName,
    this.participantAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = true,
  });
}
