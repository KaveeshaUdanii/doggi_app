import 'package:flutter/material.dart';

// Stories Page Content
class StoriesContent extends StatelessWidget {
  const StoriesContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Dog Stories",
        style: TextStyle(fontSize: 28, color: const Color(0xFF7286D3)),
      ),
    );
  }
}