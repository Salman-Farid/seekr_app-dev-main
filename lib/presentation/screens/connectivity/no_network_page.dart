import 'package:flutter/material.dart';
import 'package:seekr_app/localization/localization_type.dart';

class NoNetworkPage extends StatelessWidget {
  static const routeName = 'no-network';
  static const routePath = '/no-network';
  const NoNetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final words = Words.of(context)!;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 50,
              color: Colors.red.shade700,
            ),
            const SizedBox(
              height: 20,
            ),
            Semantics(
              label: words.connectToInternet,
              child: Text(
                words.connectToInternet,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Semantics(
                label: words.youAreOffline, child: Text(words.youAreOffline))
          ],
        ),
      ),
    );
  }
}
