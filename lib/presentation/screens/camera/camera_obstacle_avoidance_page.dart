import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:seekr_app/application/live_modes/obstacle_avoidance/camera_live_obstacle_avoidance_provider.dart';
import 'package:seekr_app/localization/localization_type.dart';

class CameraObstacleAvoidancePage extends HookConsumerWidget {
  static const routeName = 'camera-obstacle-avoidance';
  static const routePath = '/camera-obstacle-avoidance';
  const CameraObstacleAvoidancePage({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ref.watch(cameraLiveObstacleAvoidanceStreamProvider).when(
                error: (e, _) => Text(e.toString()),
                data: (data) => Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: data != null
                      ? Center(
                          child: Text(data),
                        )
                      : Center(
                          child: Text(
                            'No obstacle detected',
                            style: TextTheme.of(context)
                                .headlineLarge
                                ?.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                          ),
                        ),
                )),
                loading: () => Expanded(
                    child: Center(child: const CircularProgressIndicator())),
              ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        backgroundColor: Colors.blue.shade200,
                        shape: const RoundedRectangleBorder(),
                        foregroundColor: Colors.white,
                        textStyle:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                    onPressed: () {
                      context.pop();
                    },
                    child: Text(Words.of(context)!.goBack)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
