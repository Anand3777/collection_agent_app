enum MessageSender { system, customer, agent }

class ChatMessage {
  final String id;
  final String message;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.message,
    required this.sender,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      sender: MessageSender.values.firstWhere(
        (e) => e.toString() == 'MessageSender.${json['sender']}',
        orElse: () => MessageSender.system,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'sender': sender.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }
}
