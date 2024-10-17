import 'package:doggi_app/screens/Instructions/video_list_screen.dart';
import 'package:flutter/material.dart';

class VideosContent extends StatefulWidget {
  const VideosContent({super.key});

  @override
  State<VideosContent> createState() => _VideosContentState();
}

class _VideosContentState extends State<VideosContent> {
  @override
  Widget build(BuildContext context) {
    return VideoListScreen();
  }
}
