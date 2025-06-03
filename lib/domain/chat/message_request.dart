import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class MessageRequest extends Equatable {
  final String text;
  final Uint8List? image;
  final String? sessionId;
  const MessageRequest({
    this.text = 'Describe the image',
    this.image,
    this.sessionId,
  });

  MessageRequest copyWith({
    String? text,
    Uint8List? image,
    ValueGetter<String?>? sessionId,
  }) {
    return MessageRequest(
      text: text ?? this.text,
      image: image ?? this.image,
      sessionId: sessionId != null ? sessionId() : this.sessionId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      if (image != null) 'image_base64': base64Encode(image!),
      if (sessionId != null) 'session_id': sessionId,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'MessageRequest(text: $text, image: $image, sessionId: $sessionId)';

  @override
  List<Object?> get props => [text, image, sessionId];
}
