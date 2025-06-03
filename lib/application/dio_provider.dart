import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final dioProvider = AutoDisposeProvider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://seekr-analytics.squadhead.workers.dev',
    sendTimeout: const Duration(seconds: 1),
    connectTimeout: const Duration(seconds: 1),
  ));
  // dio.interceptors.add(DioLogFormatter(
  //   eventFunc: ref.read(apiLogFuncProvider),
  // ));
  dio.interceptors.add(RetryInterceptor(
    dio: dio,
    logPrint: print, // specify log function (optional)
  ));
  return dio;
});
