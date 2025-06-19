import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:seekr_app/domain/i_audio_repo.dart';
import 'package:seekr_app/infrastructure/audio_repo.dart';

final audioRepoProvider = Provider<IAudioRepo>((ref) {
  return AudioRepo();
});

class TranslationArg extends Equatable {
  final String source;
  final bool shouldTranslate;

  const TranslationArg(this.source, this.shouldTranslate);

  @override
  List<Object> get props => [source, shouldTranslate];
}
