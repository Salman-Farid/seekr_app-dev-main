import 'package:dio/dio.dart';
import 'package:seekr_app/application/log_function_provider.dart';
import 'package:seekr_app/domain/event/api_event_log.dart';
import 'package:talker/talker.dart';

class DioLogFormatter extends Interceptor {
  final EventFunc eventFunc;
  DioLogFormatter({
    required this.eventFunc,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    super.onRequest(options, handler);

    final apiLog = ApiEventLog(
        title: TalkerLogType.httpRequest.key,
        url: options.uri.toString(),
        headers: options.headers,
        method: options.method);
    await eventFunc(apiLog);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    super.onResponse(response, handler);
    final apiLog = ApiEventLog(
        title: TalkerLogType.httpResponse.key,
        url: response.requestOptions.uri.toString(),
        headers: response.requestOptions.headers,
        method: response.requestOptions.method,
        status: response.statusCode);
    await eventFunc(apiLog);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    super.onError(err, handler);
    final apiLog = ApiEventLog(
        title: TalkerLogType.httpError.key,
        url: err.requestOptions.uri.toString(),
        headers: err.requestOptions.headers,
        method: err.requestOptions.method,
        status: err.response?.statusCode);
    await eventFunc(apiLog);
  }
}
