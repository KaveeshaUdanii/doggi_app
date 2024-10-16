import 'package:flutter/material.dart';


// Favorites Page Content
class FavoritesContent extends StatelessWidget {
  const FavoritesContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Favorites",
        style: TextStyle(fontSize: 28, color: const Color(0xFF7286D3)),
      ),
    );
  }
}