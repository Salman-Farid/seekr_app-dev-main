import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_easylogger/flutter_logger.dart';

class ChatToken extends Equatable {
  final String text;
  final String status;
  const ChatToken({
    required this.text,
    required this.status,
  });

  ChatToken copyWith({
    String? text,
    String? status,
  }) {
    return ChatToken(
      text: text ?? this.text,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'status': status,
    };
  }

  factory ChatToken.fromMap(Map<String, dynamic> map) {
    Logger.i("data: $map");
    return ChatToken(
      text: jsonDecode(map['tokens'])['text'] ?? '',
      status: map['status'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatToken.fromJson(String source) =>
      ChatToken.fromMap(json.decode(source));

  @override
  String toString() => 'ChatToken(text: $text, status: $status)';

  @override
  List<Object> get props => [text, status];
}
