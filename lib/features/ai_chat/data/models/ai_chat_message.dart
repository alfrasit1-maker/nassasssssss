import 'package:cloud_firestore/cloud_firestore.dart';

class AiChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime createdAt;

  const AiChatMessage({required this.id, required this.content, required this.isUser, required this.createdAt});

  factory AiChatMessage.fromMap(String id, Map<String, dynamic> map) => AiChatMessage(
        id: id,
        content: (map['content'] ?? '').toString(),
        isUser: map['isUser'] == true,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'content': content,
        'isUser': isUser,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
