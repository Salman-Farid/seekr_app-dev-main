// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:record/record.dart';

// import 'widgets/wave_visualizer.dart';

// class RecordPage extends StatefulWidget {
//   const RecordPage({super.key});

//   @override
//   State<RecordPage> createState() => _RecordPageState();
// }

// class _RecordPageState extends State<RecordPage> {
//   late final AudioRecorder _recorder;
//   bool _isRecording = false;
//   String? _filePath;

//   _startRecording() async {
//     bool hasPermission = await _recorder.hasPermission();

//     if (hasPermission) {
//       setState(() {
//         _isRecording = true;
//         _filePath = null;
//       });

//       // await _recorder.start();
//     }
//   }

//   _stopRecording() async {
//     final path = await _recorder.stop();

//     log('Recording complete, path: $path');

//     if (path != null) {
//       setState(() {
//         _isRecording = false;
//         _filePath = path;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         centerTitle: false,
//         backgroundColor: Colors.white,
//         systemOverlayStyle: const SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: Brightness.dark,
//         ),
//         iconTheme: const IconThemeData(
//           color: Color(0xFF2F2F2F),
//         ),
//         title: const Text(
//           'decifer',
//           style: TextStyle(
//             color: Color(0xFF2F2F2F),
//             fontSize: 26,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 56.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(),
//             _isRecording
//                 ? Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 20.0),
//                     child: SizedBox(
//                       height: 60,
//                       width: double.maxFinite,
//                       child: WaveVisualizer(
//                         columnHeight: 50,
//                         columnWidth: 10,
//                         isPaused: false,
//                         isBarVisible: false,
//                         color: Colors.red.shade600,
//                       ),
//                     ),
//                   )
//                 : FaIcon(
//                     FontAwesomeIcons.microphone,
//                     size: 100,
//                     color: Colors.red.shade600.withOpacity(0.5),
//                   ),
//             const SizedBox(height: 32),
//             _isRecording
//                 ? SizedBox(
//                     width: double.maxFinite,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         elevation: 0,
//                         backgroundColor: Colors.red.shade50,
//                         foregroundColor: Theme.of(context).colorScheme.primary,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(60),
//                           side: BorderSide(
//                             color: Colors.red.shade600,
//                             width: 3,
//                           ),
//                         ),
//                       ),
//                       onPressed: _stopRecording,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 8.0,
//                           horizontal: 2.0,
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.red.shade600,
//                               ),
//                               child: const Padding(
//                                 padding: EdgeInsets.all(16.0),
//                                 child: FaIcon(
//                                   FontAwesomeIcons.stop,
//                                   size: 24,
//                                 ),
//                               ),
//                             ),
//                             const Spacer(),
//                             Text(
//                               'Stop Recording',
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 color: Colors.red.shade600,
//                               ),
//                             ),
//                             const Spacer(),
//                           ],
//                         ),
//                       ),
//                     ),
//                   )
//                 : _filePath != null
//                     ? SizedBox(
//                         width: double.maxFinite,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red.shade50,
//                             foregroundColor:
//                                 Theme.of(context).colorScheme.primary,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(60),
//                               side: BorderSide(
//                                 color: Colors.red.shade600,
//                                 width: 3,
//                               ),
//                             ),
//                           ),
//                           onPressed: _startRecording,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 8.0,
//                               horizontal: 2.0,
//                             ),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: Colors.red.shade600,
//                                   ),
//                                   child: const Padding(
//                                     padding: EdgeInsets.all(16.0),
//                                     child: FaIcon(
//                                       FontAwesomeIcons.microphone,
//                                       size: 24,
//                                     ),
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 Text(
//                                   'Record Again',
//                                   style: TextStyle(
//                                     fontSize: 22,
//                                     color: Colors.red.shade600,
//                                   ),
//                                 ),
//                                 const Spacer(),
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                     : SizedBox(
//                         width: double.maxFinite,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red.shade600,
//                             foregroundColor:
//                                 Theme.of(context).colorScheme.primary,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(60),
//                               side: BorderSide(
//                                 color: Colors.red.shade600,
//                                 width: 3,
//                               ),
//                             ),
//                           ),
//                           onPressed: _startRecording,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 8.0,
//                               horizontal: 2.0,
//                             ),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   decoration: const BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: Colors.black26,
//                                   ),
//                                   child: const Padding(
//                                     padding: EdgeInsets.all(16.0),
//                                     child: FaIcon(
//                                       FontAwesomeIcons.microphone,
//                                       size: 24,
//                                     ),
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 const Text(
//                                   'Start Recording',
//                                   style: TextStyle(fontSize: 22),
//                                 ),
//                                 const Spacer(),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//             _filePath != null
//                 ? Padding(
//                     padding: const EdgeInsets.only(top: 16.0),
//                     child: SizedBox(
//                       width: double.maxFinite,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           elevation: 0,
//                           backgroundColor: const Color(0xFFCBEF43),
//                           foregroundColor:
//                               Theme.of(context).colorScheme.primary,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(60),
//                             side: const BorderSide(
//                               color: Colors.black,
//                               width: 2,
//                             ),
//                           ),
//                         ),
//                         onPressed: () async {
//                           // final file = File(_filePath!);

//                           // final Tuple4<List<Subtitle>, String, String,
//                           //     List<double>> result = await showModalBottomSheet(
//                           //   isDismissible: false,
//                           //   context: context,
//                           //   builder: (context) {
//                           //     return BottomSheetWidget(
//                           //       file: file,
//                           //     );
//                           //   },
//                           // );

//                           // final subtitles = result.item1;
//                           // final docId = result.item2;
//                           // final downloadUrl = result.item3;
//                           // final confidences = result.item4;

//                           log('Received transcripts!');

//                           // Navigator.of(context).pushReplacement(
//                           //   MaterialPageRoute(
//                           //     builder: (context) => TranscriptionPage(
//                           //       subtitles: subtitles,
//                           //       audioFile: file,
//                           //       audioUrl: downloadUrl,
//                           //       docId: docId,
//                           //       confidences: confidences,
//                           //     ),
//                           //   ),
//                           // );
//                         },
//                         child: const Padding(
//                           padding: EdgeInsets.symmetric(
//                             vertical: 8.0,
//                           ),
//                           child: Text(
//                             'Generate Transcript',
//                             style: TextStyle(
//                               fontSize: 22,
//                               color: Color(0xFF2F2F2F),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                 : const SizedBox(),
//             const SizedBox(height: 50),
//           ],
//         ),
//       ),
//     );
//   }
// }


