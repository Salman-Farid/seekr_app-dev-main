import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/http_client_provider.dart';
import 'package:seekr_app/application/session_provider.dart';
import 'package:seekr_app/application/settings_provider.dart';
import 'package:seekr_app/domain/image_process/i_image_process_repo.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';
import 'package:seekr_app/infrastructure/image_process_repo.dart';

final imageProcessRepoProvider = Provider<IImageProcessRepo>((ref) {
  final session = ref.watch(sessionIdProvider);
  return ImageProcessRepo(
      client: ref.read(httpClientProvider), session: session);
});

final imageCompressProvider =
    AutoDisposeFutureProviderFamily<File, String>((ref, imagePath) async {
  return ref.read(imageProcessRepoProvider).compressImage(imagePath);
});

final imageProcessProvider =
    AutoDisposeFutureProviderFamily<String, ImageProcessData>(
        (ref, data) async {
  final langRepo = await ref.watch(settingsRepoProvider.future);
  final result = await ref.read(imageProcessRepoProvider).processImageRepo(
      data.copyWith(
          languageCode: data.processType == ProcessType.text
              ? langRepo.getLangCodeForOcr()
              : langRepo.getLangCodeForLocale()));

  return result;
});
