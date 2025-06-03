import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:seekr_app/application/live_modes/bus_detection/camera_live_bus_detection_provider.dart';
import 'package:seekr_app/localization/localization_type.dart';

class CameraBusDetectionPage extends HookConsumerWidget {
  static const routeName = 'camera-bus-detection';
  static const routePath = '/camera-bus-detection';
  const CameraBusDetectionPage({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // useEffect(() {
    //   Future.microtask(() async {
    //     final settings = await ref.watch(settingsProvider.future);
    //     ref.read(audioRepoProvider).init(settings);
    //   });
    //   return null;
    // }, []);
    // final settings = ref.watch(settingsProvider).requireValue;
    // final controller = ref.watch(cameraControllerProvider).requireValue!;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ref.watch(cameraLiveBusDetectionStreamProvider).when(
                error: (e, _) => Text(e.toString()),
                data: (data) => Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: data != null
                      ? Image.memory(
                          data,
                          fit: BoxFit.contain,
                        )
                      : Center(
                          child: Text(
                            'No bus detected',
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
              // Expanded(child: SizedBox.shrink()),
              // Expanded(
              //     child: ElevatedButton(
              //         onPressed: () async {
              //           final image = await ImagePicker().pickImage(
              //               source: ImageSource.gallery, imageQuality: 50);
              //           if (image != null) {
              //             Logger.i("Convert image to bytes");
              //             final bytes = await image.readAsBytes();
              //             Logger.i("Image size: ${bytes.length}");
              //             Logger.i("Start OCR");
              //             final ocr = await ref
              //                 .read(imageProcessRepoProvider)
              //                 .ocrFromImage(bytes);

              //             Logger.i(ocr);
              //           }
              //         },
              //         style: ElevatedButton.styleFrom(
              //             elevation: 0,
              //             padding: const EdgeInsets.symmetric(vertical: 30),
              //             backgroundColor: Colors.red.shade200,
              //             shape: const RoundedRectangleBorder(),
              //             foregroundColor: Colors.white,
              //             textStyle:
              //                 Theme.of(context).textTheme.titleLarge?.copyWith(
              //                       fontWeight: FontWeight.bold,
              //                     )),
              //         child: Text("Test"))),
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
