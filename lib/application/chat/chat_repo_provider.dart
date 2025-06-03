import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_http_sse/client/sse_client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/domain/chat/i_chat_repo.dart';
import 'package:seekr_app/infrastructure/chat_repo.dart';

final sseClientProvider = Provider<SSEClient>((ref) {
  final client = SSEClient();
  ref.onDispose(() {
    Logger.i("SSE Client disposed");
    client.close();
  });
  return client;
});

final chatRepoProvider = Provider<IChatRepo>((ref) {
  return ChatRepo(sseClient: ref.watch(sseClientProvider));
});
