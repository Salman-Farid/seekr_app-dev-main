import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seekr_app/infrastructure/talker_observer.dart';
import 'package:talker/talker.dart';

final analyticsObserverProvider = Provider<FirebaseAnalyticsObserver>((ref) {
  final analytics = FirebaseAnalytics.instance;
  return FirebaseAnalyticsObserver(analytics: analytics);
});

final methodChannelProvider = Provider<MethodChannel?>((ref) {
  if (Platform.isIOS) {
    const backgroundChannel = MethodChannel('background_channel/ios');
    return backgroundChannel;
  } else {
    return null;
  }
});

final deviceInfoProvider = FutureProvider<BaseDeviceInfo>((ref) {
  final deviceInfoPlugin = DeviceInfoPlugin();
// final deviceInfo = await deviceInfoPlugin.deviceInfo;
  return deviceInfoPlugin.deviceInfo;
});

final locationProvider = FutureProvider<Position?>((ref) async {
  final hasLocationPermission = await Permission.location.status.isGranted;
  return hasLocationPermission ? Geolocator.getCurrentPosition() : null;
});

final talkerProvider = Provider<Talker>((ref) {
  final observer = SeekrTalkerObserver();
  // final user = ref.watch(authProvider).valueOrNull;
  return Talker(
    observer: observer,
  );
});
