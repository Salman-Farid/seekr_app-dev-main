import 'dart:convert';
import 'dart:io';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:seekr_app/application/auth_provider.dart';
import 'package:seekr_app/application/analytics/talker_provider.dart';
import 'package:seekr_app/domain/event/user_history.dart';

final sessionIdProvider = StateProvider<String?>((ref) {
  return null;
});

final sessionProvider =
    FutureProviderFamily<String?, bool>((ref, voActivated) async {
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
      'voActivated': voActivated,
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
    ref.read(sessionIdProvider.notifier).state = sessionId;
    return sessionId;
  } catch (e) {
    Logger.e("Error occurred while creating session");
    return null;
  }
});

final userHistoryProvider =
    AutoDisposeFutureProvider<IList<UserHistoryLog>>((ref) async {
  final uid = ref.watch(authProvider).requireValue!.uid;
  final response = await http.get(
    Uri.parse(
        'https://seekr-analytics.squadhead.workers.dev/analytics/users/$uid/history'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  Logger.i(response.body);
  Logger.i("User history response status: ${response.statusCode}");
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    Logger.i("User history data: $data");
    final historyLogs = data
        .map((item) => UserHistoryLog.fromMap(item))
        .toList()
        .cast<UserHistoryLog>();
    final list = IList(historyLogs).sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return list.where((log) => log.event.details.isNotEmpty).toIList();
  } else {
    return IList([]);
  }
});
