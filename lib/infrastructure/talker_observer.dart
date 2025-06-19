// import 'package:flutter_easylogger/flutter_logger.dart';
// import 'package:seekr_app/domain/event/event.dart';
// import 'package:seekr_app/domain/event/event_log.dart';
// import 'package:talker/talker.dart';
// import 'package:http/http.dart' as http;

// class SeekrTalkerObserver extends TalkerObserver {
//   final String? session;
//   // final Posi
//   SeekrTalkerObserver({
//     required this.session,
//   });

//   @override
//   void onError(TalkerError err) async {
//     if (session != null) {
//       final eventLog = EventLog(
//         session: session!,
//         event: Event(
//           title: err.title ?? 'Error',
//           details: err.generateTextMessage(),
//         ).toMap(),
//       );
//       final response = await http.post(
//           Uri.parse('https://seekr-analytics.squadhead.workers.dev/event'),
//           headers: <String, String>{
//             'Content-Type': 'application/json; charset=UTF-8',
//           },
//           body: eventLog.toJson());
//       if (response.statusCode != 200) {
//         Logger.e(response.body);
//       }
//     }
//     super.onError(err);
//   }

//   @override
//   void onException(TalkerException err) async {
//     if (session != null) {
//       final eventLog = EventLog(
//         session: session!,
//         event: Event(
//                 title: err.title ?? 'Exception',
//                 details: err.generateTextMessage())
//             .toMap(),
//       );
//       final response = await http.post(
//           Uri.parse('https://seekr-analytics.squadhead.workers.dev/event'),
//           headers: <String, String>{
//             'Content-Type': 'application/json; charset=UTF-8',
//           },
//           body: eventLog.toJson());
//       if (response.statusCode != 200) {
//         Logger.e(response.body);
//       }
//     }

//     super.onException(err);
//   }

//   @override
//   void onLog(TalkerData log) async {
//     if (session != null) {
//       final eventLog = EventLog(
//         session: session!,
//         event:
//             Event(title: log.title ?? 'Log', details: log.generateTextMessage())
//                 .toMap(),
//       );

//       final response = await http.post(
//           Uri.parse('https://seekr-analytics.squadhead.workers.dev/event'),
//           headers: <String, String>{
//             'Content-Type': 'application/json; charset=UTF-8',
//           },
//           body: eventLog.toJson());
//       if (response.statusCode != 200) {
//         Logger.e(response.body);
//       }
//     }

//     super.onLog(log);
//   }
// }
