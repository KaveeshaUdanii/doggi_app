import 'package:flutter/material.dart';


// Favorites Page Content (StatefulWidget)
class FavoritesContent extends StatefulWidget {
  const FavoritesContent({Key? key}) : super(key: key);

  @override
  _FavoritesContentState createState() => _FavoritesContentState();
}

class _FavoritesContentState extends State<FavoritesContent> {
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