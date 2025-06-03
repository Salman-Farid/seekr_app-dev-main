import 'dart:convert';

import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String title;
  final String details;
  const Event({
    required this.title,
    required this.details,
  });

  Event copyWith({
    String? title,
    String? details,
  }) {
    return Event(
      title: title ?? this.title,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'details': details,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      title: map['title'] ?? '',
      details: map['details'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Event.fromJson(String source) => Event.fromMap(json.decode(source));

  @override
  String toString() => 'Event(title: $title, details: $details)';

  @override
  List<Object> get props => [title, details];
}
