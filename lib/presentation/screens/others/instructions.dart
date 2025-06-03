import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../domain/model/video_item.dart';

class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  final List<VideoItem> contentItems = [
    VideoItem(
      id: '1',
      title: 'Seekr Video Tutorial [English]',
      description: 'A step-by-step guide on using the Seekr device in English.',
      mediaUrl: 'https://youtu.be/T0g8TzM31pU?si=O47kuKPZxRUI2P1M',
    ),
    VideoItem(
      id: '2',
      title: 'Seekr Video Tutorial [Chinese]',
      description: '使用 Seekr 设备的中文操作指南。',
      mediaUrl: 'https://youtu.be/wsoQa95QRcc?si=FE74w3PFLmnRcZZm',
    ),
  ];

  Map<String, YoutubePlayerController> youtubeControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeYoutubeControllers();
  }

  void _initializeYoutubeControllers() {
    for (var item in contentItems) {
      final videoId = YoutubePlayer.convertUrlToId(item.mediaUrl);
      if (videoId != null) {
        final controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
        youtubeControllers[item.id] = controller;
      }
    }
  }

  @override
  void dispose() {
    for (var controller in youtubeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seekr Instructions'),
        ),
        body: ListView.builder(
          itemCount: contentItems.length,
          itemBuilder: (context, index) {
            final item = contentItems[index];
            final controller = youtubeControllers[item.id];

            return Card(
              margin: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      item.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (controller != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: YoutubePlayer(
                          controller: controller,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.amber,
                          progressColors: const ProgressBarColors(
                            playedColor: Colors.amber,
                            handleColor: Colors.amberAccent,
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
