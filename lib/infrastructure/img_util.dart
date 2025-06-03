import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:image/image.dart' as img;

/// ImageUtils
class ImageUtils {
  ///
  /// Converts a [CameraImage] in YUV420 format to [image_lib.Image] in RGB format
  ///
  static img.Image convertCameraImage(CameraImage cameraImage) {
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      return convertYUV420ToImage(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      return convertBGRA8888ToImage(cameraImage);
    } else {
      throw Exception('Undefined image type.');
    }
  }

  ///
  /// Converts a [CameraImage] in BGRA888 format to [image_lib.Image] in RGB format
  ///
  static img.Image convertBGRA8888ToImage(CameraImage cameraImage) {
    Logger.i('convertBGRA8888ToImage');
    final plane = cameraImage.planes[0];
    const iosBytesOffset = 28;
    return img.Image.fromBytes(
      width: cameraImage.width,
      height: cameraImage.height,
      bytes: plane.bytes.buffer,
      rowStride: plane.bytesPerRow,
      bytesOffset: iosBytesOffset,
      order: img.ChannelOrder.bgra,
    );
  }

  ///
  /// Converts a [CameraImage] in YUV420 format to [image_lib.Image] in RGB format
  ///
  static img.Image convertYUV420ToImage(CameraImage cameraImage) {
    Logger.i('convertYUV420ToImage');
    final imageWidth = cameraImage.width;
    final imageHeight = cameraImage.height;

    final yBuffer = cameraImage.planes[0].bytes;
    final uBuffer = cameraImage.planes[1].bytes;
    final vBuffer = cameraImage.planes[2].bytes;

    final int yRowStride = cameraImage.planes[0].bytesPerRow;
    final int yPixelStride = cameraImage.planes[0].bytesPerPixel!;

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    // Create the image with swapped width and height to account for rotation
    final image = img.Image(width: imageHeight, height: imageWidth);

    for (int h = 0; h < imageHeight; h++) {
      int uvh = (h / 2).floor();

      for (int w = 0; w < imageWidth; w++) {
        int uvw = (w / 2).floor();

        final yIndex = (h * yRowStride) + (w * yPixelStride);

        final int y = yBuffer[yIndex];

        final int uvIndex = (uvh * uvRowStride) + (uvw * uvPixelStride);

        final int u = uBuffer[uvIndex];
        final int v = vBuffer[uvIndex];

        int r = (y + v * 1436 / 1024 - 179).round();
        int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
        int b = (y + u * 1814 / 1024 - 227).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        // Set the pixel with rotated coordinates
        image.setPixelRgb(imageHeight - h - 1, w, r, g, b);
      }
    }

    return image;
  }

  static Future<ui.Image> convertImageToFlutterUi(img.Image image) async {
    if (image.format != img.Format.uint8 || image.numChannels != 4) {
      final cmd = img.Command()
        ..image(image)
        ..convert(format: img.Format.uint8, numChannels: 4);
      final rgba8 = await cmd.getImageThread();
      if (rgba8 != null) {
        image = rgba8;
      }
    }

    ui.ImmutableBuffer buffer =
        await ui.ImmutableBuffer.fromUint8List(image.toUint8List());

    ui.ImageDescriptor id = ui.ImageDescriptor.raw(buffer,
        height: image.height,
        width: image.width,
        pixelFormat: ui.PixelFormat.rgba8888);

    ui.Codec codec = await id.instantiateCodec(
        targetHeight: image.height, targetWidth: image.width);

    ui.FrameInfo fi = await codec.getNextFrame();
    ui.Image uiImage = fi.image;

    return uiImage;
  }
}
