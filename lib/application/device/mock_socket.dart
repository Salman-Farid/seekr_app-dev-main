/*
 * Package : mockio
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 08/03/2023
 * Copyright :  S.Hamblett
 */

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:mocktail/mocktail.dart';

//
/// The mock socket class
///
class MockSocket extends Mock implements Socket {
  final mockBytes = <int>[];
  final mockBytesUint = Uint8List(500);

  dynamic onDataFunc;
  dynamic onDoneFunc;
  dynamic onErrorFunc;

  MockSocket();

  static late MockSocket instance;

  @override
  int port = 0;

  String host = '';

  late StreamSubscription<Uint8List> outgoing =
      Stream<Uint8List>.empty().listen((event) {});

  static Future<MockSocket> connect(host, int port,
      {sourceAddress, int sourcePort = 0, Duration? timeout}) {
    final completer = Completer<MockSocket>();
    final extSocket = MockSocket();
    extSocket.port = port;
    extSocket.host = host;
    instance = extSocket;
    completer.complete(extSocket);
    return completer.future;
  }

  @override
  void add(List<int> data) {
    mockBytes.addAll(data);
  }

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    onDataFunc = onData;
    onDoneFunc = onDone;
    onErrorFunc = onError;

    final out = Uint8List.fromList(mockBytes);
    onData!(out);
    return outgoing;
  }

  @override
  void destroy();

  @override
  Future close() {
    final completer = Completer<Future>();
    return completer.future;
  }

  void onDone() => onDoneFunc();
}

///
/// Mock socket scenario class
///
class MqttScenario1 extends MockSocket {
  static Future<MqttScenario1> connect(host, int port,
      {sourceAddress, int sourcePort = 0, Duration? timeout}) {
    final completer = Completer<MqttScenario1>();
    final extSocket = MqttScenario1();
    extSocket.port = port;
    extSocket.host = host;
    MockSocket.instance = extSocket;
    completer.complete(extSocket);
    return completer.future;
  }

  @override
  void add(List<int> data) {
    mockBytes.addAll(data);
  }

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    onDataFunc = onData;
    onDoneFunc = onDone;
    onErrorFunc = onError;
    return outgoing;
  }
}
