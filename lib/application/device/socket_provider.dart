import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/device/mock_socket.dart';
import 'package:seekr_app/main.dart';

final socketProvider = AutoDisposeFutureProvider<Socket>((ref) async {
  if (useFakeDevice) {
    return MockSocket.connect('local', 123);
  }
  return Socket.connect('192.168.1.254', 3333);
});

//https://busdetectiondev-wx2bjo7cia-uc.a.run.app

// final socketXProvider = AutoDisposeFutureProvider<Socket>((ref) async {
//   return Socket.connect('https://busdetectiondev-wx2bjo7cia-uc.a.run.app', 443);
// });
