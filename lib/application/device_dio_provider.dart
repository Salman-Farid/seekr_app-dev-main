import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/log_function_provider.dart';
import 'package:seekr_app/infrastructure/log_formatter/dio_log_formatter.dart';

final deviceDioProvider = AutoDisposeProvider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.254',
    sendTimeout: const Duration(seconds: 1),
    connectTimeout: const Duration(seconds: 1),
  ));
  dio.interceptors.add(DioLogFormatter(
    eventFunc: ref.read(apiLogFuncProvider),
  ));
  dio.interceptors.add(RetryInterceptor(
    // retryEvaluator: (error, attempt) =>
    //     error.type != DioExceptionType.connectionTimeout,
    dio: dio,
    logPrint: print, // specify log function (optional)
    retries: 3, // retry count (optional)
    retryDelays: const [
      // set delays between retries (optional)
      Duration(milliseconds: 500), // wait 1 sec before first retry
      Duration(seconds: 1), // wait 2 sec before second retry
      Duration(milliseconds: 1500), // wait 3 sec before third retry
    ],
  ));
  return dio;
});
