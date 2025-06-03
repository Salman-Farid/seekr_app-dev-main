import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:seekr_app/domain/image_process/bounding_box.dart';

class DetectionResult extends Equatable {
  final BoundingBox boundingBox;
  final double confidence;
  const DetectionResult({
    required this.boundingBox,
    required this.confidence,
  });

  DetectionResult copyWith({
    BoundingBox? boundingBox,
    double? confidence,
  }) {
    return DetectionResult(
      boundingBox: boundingBox ?? this.boundingBox,
      confidence: confidence ?? this.confidence,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'boundingBox': boundingBox.toMap(),
      'confidence': confidence,
    };
  }

  factory DetectionResult.fromMap(Map<String, dynamic> map) {
    return DetectionResult(
      boundingBox: BoundingBox.fromMap(map['boundingBox']),
      confidence: map['confidence']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory DetectionResult.fromJson(String source) =>
      DetectionResult.fromMap(json.decode(source));

  @override
  String toString() =>
      'DetectionResult(boundingBox: $boundingBox, confidence: $confidence)';

  @override
  List<Object> get props => [boundingBox, confidence];
}
