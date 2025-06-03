import 'dart:io';

import 'package:equatable/equatable.dart';

enum ProcessType {
  text,
  depth,
  scene,
  supermarket,
  museum,
  bus,
  object,
  sceneLong,
}

extension X on ProcessType {
  String feature() {
    switch (this) {
      case ProcessType.text:
        return 'TEXT_DETECTION';
      case ProcessType.depth:
        return 'DEPTH_DETECTION';
      case ProcessType.scene:
        return 'SCENE_DETECTION';
      case ProcessType.sceneLong:
        return 'SCENE_LONG_DETECTION';
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

extension XY on String {
  ProcessType processType() {
    switch (this) {
      case 'TEXT_DETECTION':
        return ProcessType.text;
      case 'DEPTH_DETECTION':
        return ProcessType.depth;
      case 'SCENE_DETECTION':
        return ProcessType.scene;
      case 'SCENE_LONG_DETECTION':
        return ProcessType.sceneLong;
      case 'SUPERMARKET_MODE':
        return ProcessType.supermarket;
      case 'MUSEUM_MODE':
        return ProcessType.museum;
      case 'BUS_MODE':
        return ProcessType.bus;
      case 'OBJECT_DETECTION':
        return ProcessType.object;
      default:
        return ProcessType.scene;
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
