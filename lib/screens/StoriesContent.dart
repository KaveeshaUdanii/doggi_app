import 'package:flutter/material.dart';


// Stories Page Content (StatefulWidget)
class StoriesContent extends StatefulWidget {
  const StoriesContent({Key? key}) : super(key: key);

  @override
  _StoriesContentState createState() => _StoriesContentState();
}

class _StoriesContentState extends State<StoriesContent> {
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
