import 'package:flutter/material.dart';
import 'package:doggi_app/screens/Instructions/video_player_screen.dart';

class VideoCard extends StatelessWidget {
  final dynamic videoData;

  const VideoCard({super.key, required this.videoData});

  @override
  Widget build(BuildContext context) {
    final videoId = videoData['id']['videoId'];
    final videoTitle = videoData['snippet']['title'];
    final videoThumbnailUrl = videoData['snippet']['thumbnails']['high']['url'];

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: ListTile(
        leading: Image.network(videoThumbnailUrl),
        title: Text(videoTitle),
        trailing: const Icon(Icons.play_arrow),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(videoId: videoId),
            ),
          );
        },
      ),
    );
  }
}
