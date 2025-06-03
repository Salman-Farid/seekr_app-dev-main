import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:http/http.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/session_provider.dart';
import 'package:seekr_app/domain/event/api_event_log.dart';
import 'package:seekr_app/domain/event/event_log.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';

typedef EventFunc = Future<void> Function(ApiEventLog apiLog);

final apiLogFuncProvider = Provider<EventFunc>((ref) {
  final session = ref.watch(sessionIdProvider);
  ProcessType? getProcessType(String url) {
    switch (url) {
      case 'https://textdetection.com.ngrok.app':
        return ProcessType.text;
      case 'https://yolov3-flask1-wx2bjo7cia-uc.a.run.app/debug':
        return ProcessType.object;
      case 'https://image-792768179921.us-central1.run.app':
        return ProcessType.scene;
      case 'https://busdetection-wx2bjo7cia-uc.a.run.app/video':
        return ProcessType.bus;
      case 'https://yolov3-flask1-wx2bjo7cia-uc.a.run.app':
        return ProcessType.depth;
      case 'https://supermarket.ngrok.app':
        return ProcessType.supermarket;
      default:
        return null; // or throw an exception, or handle as needed
    }
  }

  return (ApiEventLog apiLog) async {
    if (session != null) {
      try {
        final feature = getProcessType(apiLog.url)?.feature();
        Logger.i('Calling api event');
        if (feature != null) {
          Logger.w('Feature detected $feature');
        }
        Logger.json(EventLog(
                session: session,
                event: apiLog.copyWith(feature: () => feature).toMap())
            .toJson());
        final response = await http.post(
            Uri.parse('https://seekr-analytics.squadhead.workers.dev/event'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: EventLog(
                    session: session,
                    event: apiLog.copyWith(feature: () => feature).toMap())
                .toJson());

        Logger.i('got response ${response.body}');
      } catch (e) {
        Logger.e(e);
        //pass
      }
    }
  };
});
