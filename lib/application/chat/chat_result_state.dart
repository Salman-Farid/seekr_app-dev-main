import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import 'package:seekr_app/domain/chat/chat_context.dart';

class ChatResultState extends Equatable {
  final String? text;
  final ChatContext context;
  const ChatResultState({
    this.text,
    required this.context,
  });

  ChatResultState copyWith({
    ValueGetter<String?>? text,
    ChatContext? context,
  }) {
    return ChatResultState(
      text: text != null ? text() : this.text,
      context: context ?? this.context,
    );
  }

  @override
  String toString() => 'ChatResultState(text: $text, context: $context)';

  @override
  List<Object?> get props => [text, context];
}
