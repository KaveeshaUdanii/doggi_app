import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doggi_app/models/dog_breed.dart';

class DogBreedService {
  final String apiKey = 'live_PPISIC4zUtKcC6j3HlWyjmmUuXBvMZVw9HctjD8PHoiaaK02esJ9hyYFmeJrB10m';
  final String apiUrl = 'https://api.thedogapi.com/v1/breeds';

  Future<List<DogBreed>> fetchDogBreeds() async {
    final response = await http.get(Uri.parse(apiUrl), headers: {
      'x-api-key': apiKey,
    });

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => DogBreed.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load dog breeds');
    }
  }
}
