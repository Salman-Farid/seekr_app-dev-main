import 'package:http_interceptor/http_interceptor.dart';
import 'package:seekr_app/application/log_function_provider.dart';
import 'package:talker/talker.dart';

import 'package:seekr_app/domain/event/api_event_log.dart';

class SeekrHttpLogger extends InterceptorContract {
  final EventFunc eventFunc;
  SeekrHttpLogger({
    required this.eventFunc,
  });
  @override
  Future<BaseRequest> interceptRequest({
    required BaseRequest request,
  }) async {
    final apiLog = ApiEventLog(
        title: TalkerLogType.httpRequest.key,
        url: request.url.toString(),
        headers: request.headers,
        method: request.method);
    await eventFunc(apiLog);
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    final apiLog = ApiEventLog(
      title: TalkerLogType.httpResponse.key,
      url: response.request?.url.toString() ?? 'N/A',
      headers: response.request?.headers ?? {},
      method: response.request?.method ?? 'N/A',
      status: response.statusCode,
    );
    await eventFunc(apiLog);
    return response;
  }
}
