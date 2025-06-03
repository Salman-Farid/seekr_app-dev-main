import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class EventLog extends Equatable {
  final String session;
  final Map<String, dynamic> event;
  final String? feature;

  const EventLog({
    required this.session,
    required this.event,
    this.feature,
  });

  EventLog copyWith({
    String? session,
    Map<String, dynamic>? event,
    ValueGetter<String?>? feature,
  }) {
    return EventLog(
      session: session ?? this.session,
      event: event ?? this.event,
      feature: feature != null ? feature() : this.feature,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'session': session,
      'event': event,
      if (feature != null) 'feature': feature,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'EventLog(session: $session, event: $event, feature: $feature)';

  @override
  List<Object?> get props => [session, event, feature];
}
