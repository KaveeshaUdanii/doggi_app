import 'package:doggi_app/models/article.dart';
import 'package:flutter/material.dart';

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  ArticleDetailPage({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            article.urlToImage != ''
                ? Image.network(article.urlToImage)
                : Container(),
            SizedBox(height: 16),
            Text(
              article.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('by ${article.author}'),
            SizedBox(height: 16),
            Text(article.description),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Open the article in a browser
                // You can use url_launcher package here if you'd like
              },
              child: Text('Read Full Article'),
            ),
          ],
        ),
      ),
    );
  }
}
