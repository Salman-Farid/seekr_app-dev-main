import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final mobileConnectivityCheckerProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).maybeWhen(
        orElse: () => false,
        data: (data) => data.contains(ConnectivityResult.mobile),
      );
});
final wifiConnectivityCheckerProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).maybeWhen(
        orElse: () => false,
        data: (data) => data.contains(ConnectivityResult.wifi),
      );
});
final readyToCheckDeviceProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).maybeWhen(
        orElse: () => false,
        data: (data) =>
            data.contains(ConnectivityResult.mobile) &&
            data.contains(ConnectivityResult.wifi),
      );
});

final connectedToAnyProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).maybeWhen(
        orElse: () => false,
        data: (data) =>
            data.contains(ConnectivityResult.mobile) ||
            data.contains(ConnectivityResult.wifi),
      );
});
