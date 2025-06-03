import 'dart:convert';

import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String content;
  final bool isUser;
  final DateTime time;
  const ChatMessage({
    required this.content,
    required this.isUser,
    required this.time,
  });

  ChatMessage copyWith({
    String? content,
    bool? isUser,
    DateTime? time,
  }) {
    return ChatMessage(
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'isUser': isUser,
      'time': time.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      content: map['content'] ?? '',
      isUser: map['isUser'] ?? false,
      time: DateTime.fromMillisecondsSinceEpoch(map['time']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatMessage.fromJson(String source) =>
      ChatMessage.fromMap(json.decode(source));

  @override
  String toString() =>
      'ChatMessage(content: $content, isUser: $isUser, time: $time)';

  @override
  List<Object> get props => [content, isUser, time];
}
