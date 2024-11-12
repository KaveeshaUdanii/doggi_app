import 'package:flutter/material.dart';
import 'package:doggi_app/models/dog_breed.dart';

class DogBreedDetailPage extends StatelessWidget {
  final DogBreed breed;

  const DogBreedDetailPage({super.key, required this.breed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(breed.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            breed.imageUrl != ''
                ? Image.network(breed.imageUrl)
                : Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: Text('No Image')),
            ),
            const SizedBox(height: 16),
            Text(
              breed.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Temperament: ${breed.temperament}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Lifespan: ${breed.lifeSpan}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'More detailed information about this breed can be added here...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
