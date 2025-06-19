import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easylogger/flutter_logger.dart';

class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  Future<String> _read() async {
    try {
      return await rootBundle.loadString('assets/instructions.txt');
    } catch (e) {
      Logger.i("Couldn't read file: $e");
    }
    return "Empty instructions";
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seekr Instructions'),
        ),
        body: FutureBuilder(
          future: _read(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              String content = snapshot.data;
              return SingleChildScrollView(
                  child: Text(
                content,
                style: const TextStyle(fontSize: 20),
              ));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
