import 'package:flutter/material.dart';
import 'package:doggi_app/screens/Instructions/PetsContent.dart';
import 'package:doggi_app/screens/Instructions/ArticlesContent.dart';
import 'package:doggi_app/screens/Instructions/VideosContent.dart';


// Stories Page Content (StatefulWidget)
class StoriesContent extends StatefulWidget {
  const StoriesContent({Key? key}) : super(key: key);

  @override
  _StoriesContentState createState() => _StoriesContentState();
}

class _StoriesContentState extends State<StoriesContent> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.pets_rounded, color: Color(0xFFE5E0FF),)),
                Tab(icon: Icon(Icons.video_collection, color: Color(0xFFE5E0FF),)),
                Tab(icon: Icon(Icons.article_rounded, color: Color(0xFFE5E0FF),)),
              ],
            ),
            backgroundColor: Color(0xFF7286D3),
            toolbarHeight: 30.0,
          ),
          body: const TabBarView(
            children: [
              PetsContent(),
              VideosContent(),
              ArticlesContent(),
            ],
          ),
        ),
      );
  }
}
