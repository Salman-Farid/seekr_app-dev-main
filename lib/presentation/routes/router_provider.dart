import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seekr_app/application/auth_provider.dart';
import 'package:seekr_app/application/connectivity/connectivity_provider.dart';
import 'package:seekr_app/application/permission/permission_provider.dart';
import 'package:seekr_app/application/permission/permission_state.dart';
import 'package:seekr_app/application/talker_provider.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';
import 'package:seekr_app/domain/image_process/image_process_page_param.dart';
import 'package:seekr_app/presentation/screens/camera/camera_bus_detection_page.dart';
import 'package:seekr_app/presentation/screens/camera/camera_page.dart';
import 'package:seekr_app/presentation/screens/auth/login/login_screen.dart';
import 'package:seekr_app/presentation/screens/auth/selection/selection_screen.dart';

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/presentation/screens/camera/device_bus_detection_page.dart';
import 'package:seekr_app/presentation/screens/camera/image_process_page.dart';
import 'package:seekr_app/presentation/screens/camera/reuse_camera_page.dart';
import 'package:seekr_app/presentation/screens/connectivity/no_camera_permission_page.dart';
import 'package:seekr_app/presentation/screens/connectivity/no_location_permission_page.dart';
import 'package:seekr_app/presentation/screens/connectivity/no_network_page.dart';
import 'package:seekr_app/presentation/screens/device/device_page.dart';
import 'package:seekr_app/presentation/screens/museum/museum_list_page.dart';
import 'package:seekr_app/presentation/screens/museum/museum_processing_page.dart';
import 'package:seekr_app/presentation/screens/others/permission_screen.dart';
import 'package:seekr_app/presentation/screens/others/splash_screen.dart';
import 'package:seekr_app/presentation/screens/root_page.dart';
import 'package:seekr_app/presentation/screens/settings/package_plan_sheet.dart';
import 'package:seekr_app/presentation/screens/settings/settings_page.dart';
import 'package:talker_flutter/talker_flutter.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorCameraKey =
    GlobalKey<NavigatorState>(debugLabel: 'camrea');
final _shellNavigatorDeviceKey =
    GlobalKey<NavigatorState>(debugLabel: 'device');

final _shellNavigatorSettingsKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

final _shellNavigatorBusKey = GlobalKey<NavigatorState>(debugLabel: 'bus');

final routerProvider = Provider<GoRouter>((ref) {
  final permissionState = ref.watch(permissionProvider);
  final authState = ref.watch(authProvider);
  final networkAvailableState = ref.watch(connectedToAnyProvider);
  return GoRouter(
    observers: [
      TalkerRouteObserver(ref.read(talkerProvider)),
    ],
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    initialLocation: SplashScreen.routePath,
    routes: [
      StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              RootPage(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
                navigatorKey: _shellNavigatorCameraKey,
                routes: [
                  GoRoute(
                    path: CameraPage.routePath,
                    name: CameraPage.routeName,
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: CameraPage()),
                  ),
                  GoRoute(
                    path: NoCameraPermissionPage.routePath,
                    name: NoCameraPermissionPage.routeName,
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: NoCameraPermissionPage()),
                  ),
                  GoRoute(
                    path: NoLocationPermissionPage.routePath,
                    name: NoLocationPermissionPage.routeName,
                    pageBuilder: (context, state) => const NoTransitionPage(
                        child: NoLocationPermissionPage()),
                  ),
                ]),
            if (Platform.isIOS)
              StatefulShellBranch(
                  navigatorKey: _shellNavigatorDeviceKey,
                  routes: [
                    GoRoute(
                      path: DevicePage.routePath,
                      name: DevicePage.routeName,
                      pageBuilder: (context, state) =>
                          const NoTransitionPage(child: DevicePage()),
                    ),
                  ]),
            StatefulShellBranch(
                navigatorKey: _shellNavigatorSettingsKey,
                routes: [
                  GoRoute(
                    path: SettingsPage.routePath,
                    name: SettingsPage.routeName,
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: SettingsPage()),
                  ),
                ]),
            if (Platform.isIOS)
              StatefulShellBranch(navigatorKey: _shellNavigatorBusKey, routes: [
                GoRoute(
                  path: DeviceBusDetectionPage.routePath,
                  name: DeviceBusDetectionPage.routeName,
                  builder: (context, state) {
                    return const DeviceBusDetectionPage();
                  },
                ),
              ]),
          ]),
      GoRoute(
        path: CameraBusDetectionPage.routePath,
        name: CameraBusDetectionPage.routeName,
        builder: (context, state) {
          return const CameraBusDetectionPage();
        },
      ),
      GoRoute(
        path: SplashScreen.routePath,
        name: SplashScreen.routeName,
        builder: (context, state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: NoNetworkPage.routePath,
        name: NoNetworkPage.routeName,
        builder: (context, state) {
          return const NoNetworkPage();
        },
      ),
      GoRoute(
        path: PackagePlansSheet.routePath,
        name: PackagePlansSheet.routeName,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            ModalPage<void>(key: state.pageKey, child: PackagePlansSheet()),
      ),
      GoRoute(
        path: ImageProcessPage.routePath,
        name: ImageProcessPage.routeName,
        builder: (context, state) {
          final extra = state.extra as ImageProcessPageParam;
          return ImageProcessPage(
            param: extra,
          );
        },
      ),
      GoRoute(
        path: PermissionScreen.routePath,
        name: PermissionScreen.routeName,
        builder: (context, state) {
          return const PermissionScreen();
        },
      ),
      GoRoute(
        path: ReuseCameraPage.routePath,
        name: ReuseCameraPage.routeName,
        builder: (context, state) {
          final processType = ProcessType.values.firstWhere(
            (v) => v.name == state.extra,
            orElse: () => ProcessType.scene,
          );
          return ReuseCameraPage(processType);
        },
      ),
      GoRoute(
        path: LoginScreen.routePath,
        name: LoginScreen.routeName,
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: SelectionScreen.routePath,
        name: SelectionScreen.routeName,
        builder: (context, state) {
          return const SelectionScreen();
        },
      ),
      GoRoute(
        path: MuseumListPage.routePath,
        name: MuseumListPage.routeName,
        builder: (context, state) {
          return const MuseumListPage();
        },
      ),
      GoRoute(
        path: MuseumProcessingPage.routePath,
        name: MuseumProcessingPage.routeName,
        builder: (context, state) {
          return const MuseumProcessingPage();
        },
      ),
      // GoRoute(
      //   path: DeviceResultPage.routePath,
      //   name: DeviceResultPage.routeName,
      //   builder: (context, state) {
      //     Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
      //     return DeviceResultPage(
      //         text: extra['text'] as String,
      //         processType: extra['processType'] as ProcessType);
      //   },
      // ),
    ],
    redirect: (context, state) {
      final currentPath = state.uri.path;
      if (!networkAvailableState) {
        return NoNetworkPage.routePath;
      } else if (permissionState.isLoading || authState.isLoading) {
        return SplashScreen.routePath;
      } else {
        if (permissionState.hasValue &&
            permissionState.value?.hasAllPermission == true) {
          if (authState.hasValue && authState.value != null) {
            if (permissionState.value!.cameraPerission !=
                    PermissionResult.accepted &&
                currentPath == CameraPage.routePath) {
              return NoCameraPermissionPage.routePath;
            }
            // else if (permissionState.value!.locationPermission !=
            //         PermissionResult.accepted &&
            //     currentPath == CameraPage.routePath) {
            //   return NoLocationPermissionPage.routePath;
            // }
            else if (currentPath == SplashScreen.routePath ||
                currentPath == PermissionScreen.routePath) {
              return CameraPage.routePath;
            } else {
              return null;
            }
          } else {
            return SelectionScreen.routePath;
          }
        } else {
          return PermissionScreen.routePath;
        }
      }
    },
  );
});
