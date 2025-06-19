import 'dart:io';

import 'package:equatable/equatable.dart';

enum ProcessType { text, depth, scene, supermarket, museum, bus, object }

extension X on ProcessType {
  String? feature() {
    switch (this) {
      case ProcessType.text:
        return 'TEXT_DETECTION';
      case ProcessType.depth:
        return 'DEPTH_DETECTION';
      case ProcessType.scene:
        return 'SCENE_DETECTION';
      case ProcessType.supermarket:
        return 'SUPERMARKET_MODE';
      case ProcessType.museum:
        return 'MUSEUM_MODE';
      case ProcessType.bus:
        return 'BUS_MODE';
      case ProcessType.object:
        return 'OBJECT_DETECTION';
    }
  }
}

class ImageProcessData extends Equatable {
  final File image;
  final ProcessType processType;
  final String languageCode;

  const ImageProcessData({
    required this.image,
    required this.processType,
    this.languageCode = 'en_US',
  });

  ImageProcessData copyWith({
    File? image,
    ProcessType? processType,
    int? langIndex,
    String? languageCode,
  }) {
    return ImageProcessData(
        image: image ?? this.image,
        processType: processType ?? this.processType,
        languageCode: languageCode ?? this.languageCode);
  }

  @override
  List<Object> get props => [image, processType, languageCode];
}
