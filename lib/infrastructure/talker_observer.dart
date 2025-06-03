// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:talker/talker.dart';

class SeekrTalkerObserver extends TalkerObserver {
  @override
  void onError(TalkerError err) async {
    FirebaseCrashlytics.instance.recordError(
      err.error,
      err.stackTrace,
      reason: err.message,
    );
  }

  @override
  void onException(TalkerException err) async {
    FirebaseCrashlytics.instance.recordError(
      err.exception,
      err.stackTrace,
      reason: err.message,
    );
  }

  @override
  void onLog(TalkerData log) async {
    final analytics = FirebaseAnalytics.instance;
    analytics.logEvent(
      name: log.title?.replaceAll('-', '_') ?? 'log',
      parameters: {
        if (log.key != null) 'key': log.key!,
        if (log.logLevel != null) 'level': log.logLevel!.name,
        'message': log.generateTextMessage(),
      },
    );
  }
}
