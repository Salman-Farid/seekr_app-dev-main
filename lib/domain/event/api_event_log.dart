import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ApiEventLog extends Equatable {
  final String title;
  final String url;
  final Map<String, dynamic> headers;
  final int? status;
  final String method;
  final String? feature;
  const ApiEventLog({
    required this.title,
    required this.url,
    required this.headers,
    this.status,
    required this.method,
    this.feature,
  });

  ApiEventLog copyWith({
    String? title,
    String? url,
    Map<String, dynamic>? headers,
    ValueGetter<int?>? status,
    String? method,
    ValueGetter<String?>? feature,
  }) {
    return ApiEventLog(
      title: title ?? this.title,
      url: url ?? this.url,
      headers: headers ?? this.headers,
      status: status != null ? status() : this.status,
      method: method ?? this.method,
      feature: feature != null ? feature() : this.feature,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'headers': headers,
      if (status != null) 'status': status,
      'method': method,
      if (feature != null) 'feature': feature,
    };
  }

  factory ApiEventLog.fromMap(Map<String, dynamic> map) {
    return ApiEventLog(
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      headers: Map<String, dynamic>.from(map['headers']),
      status: map['status']?.toInt(),
      method: map['method'] ?? '',
      feature: map['feature'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ApiEventLog.fromJson(String source) =>
      ApiEventLog.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ApiEventLog(title: $title, url: $url, headers: $headers, status: $status, method: $method, mode: $feature)';
  }

  @override
  List<Object?> get props {
    return [
      title,
      url,
      headers,
      status,
      method,
      feature,
    ];
  }
}
