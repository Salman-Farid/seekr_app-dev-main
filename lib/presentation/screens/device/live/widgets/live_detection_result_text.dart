import 'package:flutter/material.dart';

class LiveDetectionResultText extends StatelessWidget {
  final String resultText;
  const LiveDetectionResultText({super.key, required this.resultText});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          resultText,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
