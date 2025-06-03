import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:seekr_app/domain/image_process/image_process_data.dart';

class ImageProcessPageParam extends Equatable {
  final String imagePath;
  final ProcessType processType;
  const ImageProcessPageParam({
    required this.imagePath,
    required this.processType,
  });

  ImageProcessPageParam copyWith({
    String? imagePath,
    ProcessType? processType,
  }) {
    return ImageProcessPageParam(
      imagePath: imagePath ?? this.imagePath,
      processType: processType ?? this.processType,
    );
  }

  @override
  String toString() =>
      'ImageProcessPageParam(imagePath: $imagePath, processType: $processType)';

  @override
  List<Object> get props => [imagePath, processType];

  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'processType': processType.name,
    };
  }

  factory ImageProcessPageParam.fromMap(Map<String, dynamic> map) {
    return ImageProcessPageParam(
      imagePath: map['imagePath'] ?? '',
      processType: ProcessType.values.firstWhere(
        (v) => v.name == map['processType'],
        orElse: () => ProcessType.scene,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ImageProcessPageParam.fromJson(String source) =>
      ImageProcessPageParam.fromMap(json.decode(source));
}
