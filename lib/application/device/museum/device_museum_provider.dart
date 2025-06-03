import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/device/museum/museum_state.dart';

final museumProvider = StateProvider<MuseumState>((ref) {
  return const MuseumState(
    isMuseum: false,
  );
});
