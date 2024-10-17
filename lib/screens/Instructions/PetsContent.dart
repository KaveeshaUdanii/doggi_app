import 'package:doggi_app/screens/Instructions/video_list_screen.dart';
import 'package:flutter/material.dart';


class PetsContent extends StatefulWidget {
  const PetsContent({super.key});

  @override
  State<PetsContent> createState() => _PetsContentState();
}

class _PetsContentState extends State<PetsContent> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoListScreen(),
    );
  }
}
