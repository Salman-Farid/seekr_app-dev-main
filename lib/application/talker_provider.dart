import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seekr_app/application/auth_provider.dart';
import 'package:seekr_app/domain/event/event.dart';
import 'package:seekr_app/domain/event/event_log.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';
import 'package:talker/talker.dart';
import 'package:http/http.dart' as http;

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

final sessionProvider = FutureProvider<String?>((ref) async {
  try {
    final user = ref.watch(authProvider).value;
    final device =
        ref.watch(deviceInfoProvider.select((value) => value.value?.data));
    Logger.i('Getting location data');
    final data = await ref.watch(locationProvider.future);
    Map<String, dynamic>? address;

    if (data != null) {
      Logger.i('Getting address data');

      try {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(data.latitude, data.longitude);
        Logger.i(data);
        if (placemarks.isNotEmpty) {
          Logger.i('placemarks: ${placemarks.length}');
          Placemark place = placemarks[0];

          address = {
            "name": place.name ?? '',
            "street": place.street ?? '',
            "isoCountryCode": place.isoCountryCode ?? '',
            "country": place.country ?? '',
            "postalCode": place.postalCode ?? '',
            "administrativeArea": place.administrativeArea ?? '',
            "subAdministrativeArea": place.subAdministrativeArea ?? '',
            "locality": place.locality ?? '',
            "subLocality": place.subLocality ?? '',
            "thoroughfare": place.thoroughfare ?? '',
            "subThoroughfare": place.subThoroughfare ?? '',
            "longitude": data.longitude,
            "latitude": data.latitude,
          };
        }
      } catch (e) {
        Logger.e('could not collecta address data');
        Logger.e(e);
      }
    }
    final body = {
      'uid': user?.uid,
      'email': user?.email,
      if (user != null)
        'user': {
          'displayName': user.displayName,
          'email': user.email,
          'isEmailVerified': user.emailVerified,
          'isAnonymous': user.isAnonymous,
          'metadata': user.metadata.toString(),
          'phoneNumber': user.phoneNumber,
          'photoURL': user.photoURL,
          'providerData': user.providerData.toString(),
          'refreshToken': user.refreshToken,
          'tenantId': user.tenantId,
          'uid': user.uid,
        },
      if (device != null) 'device': device,
      if (address != null) 'address': address
    };
    Logger.i("body: $body");
    Logger.json(jsonEncode(body));

    final response = await http.post(
        Uri.parse('https://seekr-analytics.squadhead.workers.dev/session'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body));
    Logger.json(jsonEncode(body));
    Logger.i(response.body);

    final parsedResponse = jsonDecode(response.body);
    final sessionId = parsedResponse['data']['sessionId'] as String;
    Logger.i("session id: $sessionId");
    if (Platform.isIOS) {
      Logger.i("Setting session for Ios");
      const backgroundChannel = MethodChannel('background_channel/ios');
      await backgroundChannel.invokeMethod('setSessionId', sessionId);
      Logger.i("Setting session completed");
    }
    return sessionId;
  } catch (e) {
    Logger.e("Error occurred while creating session");
    return null;
  }
});

final talkerProvider = Provider<Talker>((ref) {
  // final user = ref.watch(authProvider).valueOrNull;
  return Talker(
      // observer: SeekrTalkerObserver(
      //   session: user != null ? ref.watch(sessionProvider).valueOrNull : null,
      // ),
      );
});

final eventLogFuncProvider =
    ProviderFamily<VoidCallback, ProcessType>((ref, processType) {
  final user = ref.watch(authProvider).valueOrNull;
  final session = user != null ? ref.watch(sessionProvider).valueOrNull : null;
  return () async {
    if (session != null) {
      final eventLog = EventLog(
        session: session,
        feature: processType.feature(),
        event:
            Event(title: 'Now using ${processType.name} feature', details: '')
                .toMap(),
      );

      final response = await http.post(
          Uri.parse('https://seekr-analytics.squadhead.workers.dev/event'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: eventLog.toJson());
      if (response.statusCode != 200) {
        Logger.e(response.body);
      } else {
        Logger.i('Log sending success $processType');
      }
    }
  };
});
