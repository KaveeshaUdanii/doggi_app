import 'package:flutter/material.dart';
import 'package:doggi_app/screens/Instructions/video_player_screen.dart';

class VideoCard extends StatelessWidget {
  final dynamic videoData;

  const VideoCard({Key? key, required this.videoData}) : super(key: key);

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
        trailing: Icon(Icons.play_arrow),
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
