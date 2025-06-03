import 'dart:convert';

import 'package:equatable/equatable.dart';

class BoundingBox extends Equatable {
  final double x;
  final double y;
  final double width;
  final double height;

  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  BoundingBox copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    return BoundingBox(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }

  factory BoundingBox.fromMap(Map<String, dynamic> map) {
    return BoundingBox(
      x: map['x']?.toDouble() ?? 0.0,
      y: map['y']?.toDouble() ?? 0.0,
      width: map['width']?.toDouble() ?? 0.0,
      height: map['height']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory BoundingBox.fromJson(String source) =>
      BoundingBox.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BoundingBox(x: $x, y: $y, width: $width, height: $height)';
  }

  @override
  List<Object> get props => [x, y, width, height];
}
