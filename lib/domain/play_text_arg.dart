import 'dart:convert';

import 'package:equatable/equatable.dart';

class PlayTextArg extends Equatable {
  final String text;
  final bool accessibleNavigation;
  const PlayTextArg({
    required this.text,
    required this.accessibleNavigation,
  });

  PlayTextArg copyWith({
    String? text,
    bool? accessibleNavigation,
  }) {
    return PlayTextArg(
      text: text ?? this.text,
      accessibleNavigation: accessibleNavigation ?? this.accessibleNavigation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'accessibleNavigation': accessibleNavigation,
    };
  }

  factory PlayTextArg.fromMap(Map<String, dynamic> map) {
    return PlayTextArg(
      text: map['text'] ?? '',
      accessibleNavigation: map['accessibleNavigation'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayTextArg.fromJson(String source) =>
      PlayTextArg.fromMap(json.decode(source));

  @override
  String toString() =>
      'PlayTextArg(text: $text, accessibleNavigation: $accessibleNavigation)';

  @override
  List<Object> get props => [text, accessibleNavigation];
}
