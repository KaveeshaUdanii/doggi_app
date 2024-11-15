import 'dart:convert';
import 'package:http/http.dart' as http;

class YoutubeService {
  final String apiKey = "AIzaSyCDLc5bjcyCxiaAuVJx0DjNxnmATSL3uOg"; //  API key
  final String baseUrl = "https://www.googleapis.com/youtube/v3/search";

  Future<List<dynamic>> fetchDogNutritionVideos() async {
    final response = await http.get(Uri.parse(
        "$baseUrl?part=snippet&q=dog+nutrition&type=video&key=$apiKey"));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['items'];
    } else {
      throw Exception('Failed to load videos');
    }
  }
}
