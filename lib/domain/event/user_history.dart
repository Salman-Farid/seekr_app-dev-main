import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';

class UserHistoryLog extends Equatable {
  final int id;
  final String sessionId;
  final ProcessType feature;
  final HistoryEvent event;
  final DateTime createdAt;
  const UserHistoryLog({
    required this.id,
    required this.sessionId,
    required this.feature,
    required this.event,
    required this.createdAt,
  });

  UserHistoryLog copyWith({
    int? id,
    String? sessionId,
    ProcessType? feature,
    HistoryEvent? event,
    DateTime? createdAt,
  }) {
    return UserHistoryLog(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      feature: feature ?? this.feature,
      event: event ?? this.event,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'feature': feature.feature(),
      'event': event.toMap(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserHistoryLog.fromMap(Map<String, dynamic> map) {
    final process = (map['feature'] as String? ?? '').processType();
    return UserHistoryLog(
      id: map['id']?.toInt() ?? 0,
      sessionId: map['sessionId'] ?? '',
      feature: process,
      event: HistoryEvent.fromMap(map['event']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserHistoryLog.fromJson(String source) =>
      UserHistoryLog.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserHistoryLog(id: $id, sessionId: $sessionId, feature: $feature, event: $event, createdAt: $createdAt)';
  }

  @override
  List<Object> get props {
    return [
      id,
      sessionId,
      feature,
      event,
      createdAt,
    ];
  }
}

class HistoryEvent extends Equatable {
  final String title;
  final String details;
  const HistoryEvent({
    required this.title,
    required this.details,
  });

  HistoryEvent copyWith({
    String? title,
    String? details,
  }) {
    return HistoryEvent(
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

  factory HistoryEvent.fromMap(Map<String, dynamic> map) {
    return HistoryEvent(
      title: map['title'] ?? '',
      details: map['details'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory HistoryEvent.fromJson(String source) =>
      HistoryEvent.fromMap(json.decode(source));

  @override
  String toString() => 'HistoryEvent(title: $title, details: $details)';

  @override
  List<Object> get props => [title, details];
}
