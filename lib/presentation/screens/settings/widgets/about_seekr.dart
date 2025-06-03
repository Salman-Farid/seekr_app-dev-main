import 'package:flutter/material.dart';
import 'package:seekr_app/localization/localization_type.dart';

class AboutSeekr extends StatelessWidget {
  const AboutSeekr({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Semantics(
      label: Words.of(context)!.buttonToKnowMoreInfo,
      button: false,
      explicitChildNodes: false,
      child: GestureDetector(
        onTap: () {
          showAboutDialog(
              context: context,
              applicationName: 'Seekr',
              applicationIcon: const FlutterLogo(),
              applicationVersion: '0.1.0',
              children: [
                const Text('Developed by Vidi Labs.\n\nSeekr joined the ASCEND project, organized by J.C. DISI, supported by the PolyU Knowledge Transfer and Entrepreneurship Office, and funded by The Hong Kong Jockey Club Charities Trust.'),
              ]);
        },
        child: SizedBox(
          height: size.width * .1,
          child: ExcludeSemantics(
            child: Center(
              child: Text(
                Words.of(context)!.moreInfo,
                style: TextStyle(
                    fontSize: size.width * .041,
                    color: Colors.black,
                    fontFamily: 'Rounded_Elegance',
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
