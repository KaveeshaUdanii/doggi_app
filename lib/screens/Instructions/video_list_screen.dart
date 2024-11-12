import 'package:flutter/material.dart';
import 'package:doggi_app/services/youtube_service.dart';
import 'package:doggi_app/widgets/video_card.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  late Future<List<dynamic>> _videos;

  @override
  void initState() {
    super.initState();
    _videos = YoutubeService().fetchDogNutritionVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: _videos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final videos = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return VideoCard(videoData: videos[index]);
              },
            );
          }
        },
      ),
    );
  }
}
