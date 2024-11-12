import 'package:doggi_app/models/article.dart';
import 'package:flutter/material.dart';

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

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
            const SizedBox(height: 16),
            Text(
              article.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('by ${article.author}'),
            const SizedBox(height: 16),
            Text(article.description),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Open the article in a browser
                // You can use url_launcher package here if you'd like
              },
              child: const Text('Read Full Article'),
            ),
          ],
        ),
      ),
    );
  }
}
