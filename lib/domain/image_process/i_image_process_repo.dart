import 'dart:io';
import 'package:flutter/services.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';

abstract class IImageProcessRepo {
  Future<File> compressImage(String imagePath);
  Future<String> processImageRepo(ImageProcessData data);

  Future<Uint8List?> busDetectFromImage(Uint8List imageBytes);
  Future<String?> ocrFromImage(Uint8List imageBytes);
}
