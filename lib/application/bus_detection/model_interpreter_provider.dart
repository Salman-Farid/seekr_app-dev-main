// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

// final modelInterPreterProvider = FutureProvider<Interpreter>((ref) =>
//     Interpreter.fromAsset('assets/model/v1-3_20250122_float16.tflite'));
// final modelInterPreter32Provider = FutureProvider<Interpreter>((ref) =>
//     Interpreter.fromAsset('assets/model/v1-3_20250122_float32.tflite'));

// final modelInterPreterIsolateProvider = FutureProvider<IsolateInterpreter>(
//     (ref) async => IsolateInterpreter.create(
//         address: await ref
//             .watch(modelInterPreterProvider.future)
//             .then((value) => value.address)));
