import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/settings_provider.dart';
import 'package:seekr_app/domain/settings/settings.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/settings/widgets/change_device_ssid_dialog.dart';
import 'package:seekr_app/presentation/screens/settings/widgets/settings_button.dart';

class SettingsButtons extends HookConsumerWidget {
  const SettingsButtons({super.key});

  @override
  Widget build(BuildContext context, ref) {
    ref.listen(settingsProvider, (previous, next) {
      if (next.hasValue) ref.read(audioRepoProvider).init(next.value!);
    });
    final size = MediaQuery.of(context).size;

    return ref.watch(settingsProvider).when(
        data: (settings) => Padding(
              padding: const EdgeInsets.all(0),
              child: Semantics(
                label: Words.of(context)!.settingsPageSemantic,
                explicitChildNodes: true,
                child: Container(
                  padding: const EdgeInsets.only(left: 7, top: 20, bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21),
                    color: const Color(0xffD9D9D9),
                  ),
                  child: Column(
                    children: <Widget>[
                      SettingsButton(
                        semanticLabel: Words.of(context)!.adjustTextSizeButton,
                        label: Words.of(context)!.textSize,
                        action: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 11,
                                blurRadius: 19,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: DropdownButton(
                            value: settings.textScale,
                            onChanged: (double? newValue) async {
                              if (newValue != null) {
                                ref
                                    .read(settingsProvider.notifier)
                                    .changeTextScale(newValue);
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: 1.0,
                                child: Semantics(
                                  label: Words.of(context)!.textSizeNormal,
                                  child: ExcludeSemantics(
                                    child:
                                        Text(Words.of(context)!.textSizeNormal),
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 1.5,
                                child: Semantics(
                                  label: Words.of(context)!.textSizeLarge,
                                  child: ExcludeSemantics(
                                    child:
                                        Text(Words.of(context)!.textSizeLarge),
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 2.0,
                                child: Semantics(
                                  label: Words.of(context)!.textSizeExtraLarge,
                                  child: ExcludeSemantics(
                                    child: Text(
                                        Words.of(context)!.textSizeExtraLarge),
                                  ),
                                ),
                              ),
                            ],
                            underline: const SizedBox(),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      SettingsButton(
                        semanticLabel: Words.of(context)!.voiceSpeedDropdown,
                        label: Words.of(context)!.voiceSpeed,
                        action: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 11,
                                blurRadius: 19,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: DropdownButton<VoiceSpeed>(
                            style: TextStyle(
                                fontSize: size.width * .031,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            value: settings.speed,
                            onChanged: (VoiceSpeed? newValue) async {
                              if (newValue != null) {
                                ref
                                    .read(settingsProvider.notifier)
                                    .changeVoiceSpeed(newValue);
                              }
                            },
                            items: VoiceSpeed.values
                                .map<DropdownMenuItem<VoiceSpeed>>(
                                    (VoiceSpeed value) {
                              return DropdownMenuItem<VoiceSpeed>(
                                value: value,
                                child: Semantics(
                                    label: value.label(Words.of(context)!),
                                    explicitChildNodes: false,
                                    child: ExcludeSemantics(
                                        child: Text(
                                            value.label(Words.of(context)!)))),
                              );
                            }).toList(),
                            underline: const SizedBox(),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      SettingsButton(
                        semanticLabel: Words.of(context)!.speechPitchDropdown,
                        label: Words.of(context)!.voicePitch,
                        action: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 11,
                                blurRadius: 19,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: DropdownButton<Pitch>(
                            style: TextStyle(
                                fontSize: size.width * .031,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            value: settings.pitch,
                            onChanged: (Pitch? newValue) async {
                              if (newValue != null) {
                                ref
                                    .read(settingsProvider.notifier)
                                    .changePitch(newValue);
                              }
                            },
                            items: Pitch.values
                                .map<DropdownMenuItem<Pitch>>((Pitch value) {
                              return DropdownMenuItem<Pitch>(
                                value: value,
                                child: Semantics(
                                    label: value.label(),
                                    child: ExcludeSemantics(
                                        child: Text(value.label()))),
                              );
                            }).toList(),
                            underline: const SizedBox(),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      SettingsButton(
                        semanticLabel:
                            Words.of(context)!.speechLanguageDropDown,
                        label: Words.of(context)!.appLanguage,
                        action: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 11,
                                blurRadius: 19,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: DropdownButton<Locale>(
                            style: TextStyle(
                                fontSize: size.width * .031,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            value:
                                ref.watch(settingsProvider).valueOrNull?.locale,
                            onChanged: (newValue) async {
                              if (newValue != null) {
                                ref
                                    .read(settingsProvider.notifier)
                                    .changeLocace(newValue);
                              }
                            },
                            items: settings.repo
                                .geteSelectableLocales()
                                .map<DropdownMenuItem<Locale>>((value) {
                              return DropdownMenuItem<Locale>(
                                value: value,
                                child: Semantics(
                                    label: settings.repo
                                        .getLanguageForLocale(value),
                                    child: ExcludeSemantics(
                                        child: Text(settings.repo
                                            .getLanguageForLocale(value)))),
                              );
                            }).toList(),
                            underline: const SizedBox(),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      SettingsButton(
                          semanticLabel: Words.of(context)!.processSoundtoggle,
                          label: Words.of(context)!.processSound,
                          action: CupertinoSwitch(
                            inactiveTrackColor: const Color(0xff555555),
                            value: settings.playBgMusic,
                            onChanged: (value) async {
                              ref
                                  .read(settingsProvider.notifier)
                                  .changeBgMusic(value);
                            },
                          )),
                      SettingsButton(
                          semanticLabel: Words.of(context)!.enableCameraPreview,
                          label: Words.of(context)!.enableCameraPreview,
                          action: CupertinoSwitch(
                            inactiveTrackColor: const Color(0xff555555),
                            value: settings.cameraView,
                            onChanged: ref
                                .read(settingsProvider.notifier)
                                .changeCameraView,
                          )),
                      SettingsButton(
                          semanticLabel:
                              Words.of(context)!.automaticVoicePlayback,
                          label: Words.of(context)!.automaticVoicePlayback,
                          action: CupertinoSwitch(
                            inactiveTrackColor: const Color(0xff555555),
                            value: settings.enableTTs,
                            onChanged: ref
                                .read(settingsProvider.notifier)
                                .changeTTsStatus,
                          )),
                      SettingsButton(
                        semanticLabel: Words.of(context)!.changeWifiSemantic,
                        label: Words.of(context)!.changeDeviceName,
                        action: GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const ChangeDeviceSSidDialog());
                            },
                            child: ExcludeSemantics(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Text(Words.of(context)!.change),
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        error: (error, _) => Center(
              child: Text(
                error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
        loading: () => const Center(
              child: CircularProgressIndicator(),
            ));
  }
}
