import 'dart:convert';

import 'package:equatable/equatable.dart';

class LiveTextResult extends Equatable {
  final String message;
  final bool isResultGenerated;
  const LiveTextResult({
    required this.message,
    this.isResultGenerated = false,
  });

  LiveTextResult copyWith({
    String? message,
    bool? isResultGenerated,
  }) {
    return LiveTextResult(
      message: message ?? this.message,
      isResultGenerated: isResultGenerated ?? this.isResultGenerated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'isResultGenerated': isResultGenerated,
    };
  }

  factory LiveTextResult.fromMap(Map<String, dynamic> map) {
    return LiveTextResult(
      message: map['message'] ?? '',
      isResultGenerated: map['isResultGenerated'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory LiveTextResult.fromJson(String source) =>
      LiveTextResult.fromMap(json.decode(source));

  @override
  String toString() =>
      'LiveTextResult(message: $message, isResultGenerated: $isResultGenerated)';

  @override
  List<Object> get props => [message, isResultGenerated];
}
