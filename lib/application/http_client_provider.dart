import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:seekr_app/application/log_function_provider.dart';
import 'package:seekr_app/infrastructure/log_formatter/http_log_formatter.dart';

final httpClientProvider = Provider<Client>((ref) {
  return InterceptedClient.build(interceptors: [
    SeekrHttpLogger(eventFunc: ref.watch(apiLogFuncProvider)),
  ]);
});
