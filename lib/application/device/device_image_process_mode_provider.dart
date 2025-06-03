import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';

final deviceImageProcessModeProvider =
    StateNotifierProvider<ImageProcessModeNotifier, ProcessType>((ref) {
  return ImageProcessModeNotifier();
});

class ImageProcessModeNotifier extends StateNotifier<ProcessType> {
  ImageProcessModeNotifier() : super(ProcessType.text);

  void switchToNextType() {
    Logger.i(state.index);

    if (state.index < 4) {
      state = ProcessType.values[state.index + 1];
    } else {
      state = ProcessType.text;
    }
  }

  void switchToPreviousType() {
    Logger.i(state.index);

    if (state.index > 0) {
      state = ProcessType.values[state.index - 1];
    } else {
      state = ProcessType.museum;
    }
  }

  void syncWithBgMode() async {
    if (Platform.isIOS) {
      const backgroundChannel = MethodChannel('background_channel/ios');
      final String selectedModeFromBackground =
          await backgroundChannel.invokeMethod('getSelectedMode');
      if (selectedModeFromBackground != state.name) {
        state = ProcessType.values.firstWhere(
          (element) => element.name == selectedModeFromBackground,
          orElse: () => state,
        );
      }
    }
  }
}
