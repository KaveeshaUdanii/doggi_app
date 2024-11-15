import 'dart:convert';
import 'package:doggi_app/utils/api_config.dart';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ArticleService {

  final String apiUrl = 'https://newsapi.org/v2/everything?q=dog+food';

  // Fetch dog food articles from News API using the API key
  Future<List<Article>> fetchArticles() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final response = await http.get(Uri.parse('$apiUrl&apiKey=$apiKey'), headers: headers);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> articlesJson = data['articles'];

      return articlesJson.map((article) => Article.fromJson(article)).toList();
    } else {
      throw Exception('Failed to load dog food articles');
    }
  }
}
