import 'package:flutter/material.dart';
import 'package:seekr_app/application/settings_provider.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/routes/router_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SeekrApp extends ConsumerWidget {
  const SeekrApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Seekr App',
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) => ref.watch(settingsProvider).maybeWhen(
          orElse: () => child!,
          data: (settings) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(settings.textScale)),
                child: child!,
              )),
      supportedLocales:
          ref.watch(localizationRepoProvider).valueOrNull?.getLocales() ??
              [const Locale('en', 'US')],
      locale: ref.watch(settingsProvider).valueOrNull?.locale,
      localizationsDelegates: Words.localizationsDelegates,
      routerConfig: router,
    );
  }
}
