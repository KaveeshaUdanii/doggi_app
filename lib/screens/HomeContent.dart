import 'package:flutter/material.dart';


// Home Page Content
class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Welcome to the Home Page",
        style: TextStyle(fontSize: 28, color: const Color(0xFF7286D3)),
      ),
    );
  }
}