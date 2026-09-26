import 'dart:convert';

/// Represents a single message turn in the AI Chatbot conversation.
class ChatMessage {
  final String id;
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final DateTime timestamp;
  final bool isError;
  final String? topic;
  final String? subject;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isError = false,
    this.topic,
    this.subject,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isSystem => role == 'system';

  ChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
    bool? isError,
    String? topic,
    String? subject,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      topic: topic ?? this.topic,
      subject: subject ?? this.subject,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'isError': isError,
        if (topic != null) 'topic': topic,
        if (subject != null) 'subject': subject,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      role: json['role']?.toString() ?? 'user',
      content: json['content']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isError: json['isError'] == true,
      topic: json['topic']?.toString(),
      subject: json['subject']?.toString(),
    );
  }

  /// Format for Groq OpenAI-compatible chat completion payload
  Map<String, String> toApiMap() => {
        'role': role,
        'content': content,
      };

  @override
  String toString() => 'ChatMessage($role: "$content")';
}
