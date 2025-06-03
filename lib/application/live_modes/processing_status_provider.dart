import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

final lastResultProvider = StateProvider<String?>((ref) {
  return null;
});

final processingProvider =
    StateNotifierProvider<ProcessingNotifier, bool>((ref) {
  return ProcessingNotifier(onProcessingCompleted: () {
    ref.read(lastResultProvider.notifier).state = null;
  });
});

class ProcessingNotifier extends StateNotifier<bool> {
  final void Function() onProcessingCompleted;
  ProcessingNotifier({required this.onProcessingCompleted}) : super(false);

  void startProcessing() {
    if (!state) {
      state = true;
    }
  }

  void stopProcessing() {
    if (state) {
      state = false;
    }
  }

  void setActiveWithTimer() {
    state = true;
    Timer(const Duration(seconds: 2), () {
      state = false;
      onProcessingCompleted();
    });
  }
}
