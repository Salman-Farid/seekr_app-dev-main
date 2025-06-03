import 'dart:convert';

import 'package:equatable/equatable.dart';

class ChatContext extends Equatable {
  final String text;
  final String sessionId;
  final String streamId;
  const ChatContext({
    required this.text,
    required this.sessionId,
    required this.streamId,
  });

  ChatContext copyWith({
    String? text,
    String? sessionId,
    String? streamId,
  }) {
    return ChatContext(
      text: text ?? this.text,
      sessionId: sessionId ?? this.sessionId,
      streamId: streamId ?? this.streamId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'sessionId': sessionId,
      'streamId': streamId,
    };
  }

  factory ChatContext.fromMap(Map<String, dynamic> map, String text) {
    // Logger.i("Map: $map, text: $text");
    return ChatContext(
      text: text,
      sessionId: map['session_id'] ?? '',
      streamId: map['stream_id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatContext.fromJson(String source, String text) =>
      ChatContext.fromMap(json.decode(source), text);

  @override
  String toString() =>
      'ChatContext(text: $text, sessionId: $sessionId, streamId: $streamId)';

  @override
  List<Object> get props => [text, sessionId, streamId];
}
