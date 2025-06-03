import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/camera/camera_controller_provider.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';
import 'package:seekr_app/domain/image_process/image_process_page_param.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/camera/camera_bus_detection_page.dart';
import 'package:seekr_app/presentation/screens/camera/camera_document_detection_page.dart';
import 'package:seekr_app/presentation/screens/camera/camera_obstacle_avoidance_page.dart';
import 'package:seekr_app/presentation/screens/camera/image_process_page.dart';
import 'package:seekr_app/presentation/screens/camera/widgets/image_process_button.dart';
import 'package:seekr_app/presentation/screens/museum/museum_list_page.dart';

class CameraButtons extends HookConsumerWidget {
  final CameraController controller;
  final bool cameraView;
  const CameraButtons(
      {super.key, required this.controller, required this.cameraView});

  @override
  Widget build(BuildContext context, ref) {
    final isCameraBusy = useState(false);
    final buttons = [
      Semantics(
        label: Words.of(context)!.semanticTextDetectionButton,
        child: ExcludeSemantics(
          child: ImageProcessButton(
            image: Image.asset('assets/images/read.png'),
            label: Words.of(context)!.modeText,
            onTap: () async {
              if (!isCameraBusy.value) {
                isCameraBusy.value = true;
                final controller =
                    await ref.watch(textCameraControllerProvider.future);
                if (controller != null) {
                  final image = await controller.takePicture();
                  await controller.dispose();
                  ref.invalidate(textCameraControllerProvider);
                  ref.invalidate(cameraControllerProvider);
                  if (context.mounted) {
                    context.push(ImageProcessPage.routePath,
                        extra: ImageProcessPageParam(
                          imagePath: image.path,
                          processType: ProcessType.text,
                        ));
                  }
                } else {
                  Logger.e('Camera is null');
                }
              }
              isCameraBusy.value = false;
            },
          ),
        ),
      ),
      Semantics(
        label: Words.of(context)!.semanticDepthDetectionButton,
        child: ExcludeSemantics(
          child: ImageProcessButton(
            image: Image.asset('assets/images/depth.png'),
            label: Words.of(context)!.modeDepth,
            onTap: () async {
              if (!isCameraBusy.value) {
                isCameraBusy.value = true;
                final image = await controller.takePicture();

                if (context.mounted) {
                  context.push(ImageProcessPage.routePath,
                      extra: ImageProcessPageParam(
                        imagePath: image.path,
                        processType: ProcessType.depth,
                      ));
                }
                isCameraBusy.value = false;
              }
            },
          ),
        ),
      ),
      Semantics(
        label: Words.of(context)!.semanticSceneDetectionButton,
        child: ExcludeSemantics(
          child: ImageProcessButton(
            image: Image.asset('assets/images/identify.png'),
            label: Words.of(context)!.modeScene,
            onTap: () async {
              final image = await controller.takePicture();

              if (context.mounted) {
                context.push(ImageProcessPage.routePath,
                    extra: ImageProcessPageParam(
                      imagePath: image.path,
                      processType: ProcessType.scene,
                    ));
              }
            },
          ),
        ),
      ),
      Semantics(
        label: Words.of(context)!.semanticSupermarketButton,
        child: ExcludeSemantics(
          child: ImageProcessButton(
            image: Image.asset(
              'assets/images/shop.png',
              width: 30,
            ),
            label: Words.of(context)!.modeSuperMarket,
            onTap: () async {
              final image = await controller.takePicture();

              if (context.mounted) {
                context.push(ImageProcessPage.routePath,
                    extra: ImageProcessPageParam(
                      imagePath: image.path,
                      processType: ProcessType.supermarket,
                    ));
              }
            },
          ),
        ),
      ),
      Semantics(
        label: Words.of(context)!.autoReadButton,
        child: ExcludeSemantics(
          child: ImageProcessButton(
            image: Image.asset('assets/images/read.png'),
            label: Words.of(context)!.autoRead,
            onTap: () async {
              context.push(CameraDocumentDetectionPage.routePath);
            },
          ),
        ),
      ),
      Semantics(
        label: Words.of(context)!.semanticBusButton,
        child: ExcludeSemantics(
          child: ImageProcessButton(
            image: Image.asset(
              'assets/icons/bus.png',
              width: 30,
              color: Colors.white,
              alignment: Alignment.center,
            ),
            label: Words.of(context)!.modeBus,
            onTap: () {
              context.push(CameraBusDetectionPage.routePath);
            },
          ),
        ),
      ),
      Semantics(
        label: Words.of(context)!.semanticWalkingButton,
        child: ExcludeSemantics(
          child: ImageProcessButton(
            image: Image.asset(
              'assets/icons/obstacle.png',
              width: 30,
              color: Colors.white,
              alignment: Alignment.center,
            ),
            label: Words.of(context)!.modeWalking,
            onTap: () {
              context.push(CameraObstacleAvoidancePage.routePath);
            },
          ),
        ),
      ),
      Semantics(
        label: Words.of(context)!.semanticMuseum,
        child: ExcludeSemantics(
          child: ImageProcessButton(
            image: Image.asset(
              'assets/icons/museum.png',
              width: 30,
              color: Colors.white,
              alignment: Alignment.center,
            ),
            label: Words.of(context)!.modeMuseum,
            onTap: () {
              context.push(MuseumListPage.routePath);
            },
          ),
        ),
      ),
    ];
    return Align(
      alignment: cameraView ? Alignment.bottomCenter : Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: cameraView
            ? SizedBox(
                height: 100,
                child: Semantics.fromProperties(
                  explicitChildNodes: true,
                  properties: SemanticsProperties(role: SemanticsRole.none),
                  child: ListView.separated(
                    addSemanticIndexes: false,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    scrollDirection: Axis.horizontal,
                    itemCount: buttons.length,
                    separatorBuilder: (context, index) => ExcludeSemantics(
                      child: SizedBox(
                        width: 10,
                      ),
                    ),
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    itemBuilder: (context, index) => buttons[index],
                  ),
                ),
              )
            // Semantics.fromProperties(
            //   properties: SemanticsProperties(
            //     role: SemanticsRole.none

            //   ),
            //   child: Wrap(
            //       spacing: 20,
            //       runSpacing: 10,
            //       alignment: WrapAlignment.start,
            //       crossAxisAlignment: WrapCrossAlignment.start,
            //       children: buttons,
            //     ),
            // )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: buttons,
              ),
      ),
    );
  }
}
