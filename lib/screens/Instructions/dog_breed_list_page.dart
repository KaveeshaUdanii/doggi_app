import 'package:doggi_app/screens/Instructions/dog_breed_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:doggi_app/models/dog_breed.dart';
import 'package:doggi_app/services/dog_breed_service.dart';

class DogBreedListPage extends StatefulWidget {
  const DogBreedListPage({super.key});

  @override
  _DogBreedListPageState createState() => _DogBreedListPageState();
}

class _DogBreedListPageState extends State<DogBreedListPage> {
  late Future<List<DogBreed>> futureDogBreeds;

  @override
  void initState() {
    super.initState();
    futureDogBreeds = DogBreedService().fetchDogBreeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dog Breeds')),
      body: FutureBuilder<List<DogBreed>>(
        future: futureDogBreeds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No breeds found.'));
          } else {
            List<DogBreed> breeds = snapshot.data!;

            return ListView.builder(
              itemCount: breeds.length,
              itemBuilder: (context, index) {
                return DogBreedCard(breed: breeds[index]);
              },
            );
          }
        },
      ),
    );
  }
}

class DogBreedCard extends StatelessWidget {
  final DogBreed breed;

  const DogBreedCard({super.key, required this.breed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DogBreedDetailPage(breed: breed)),
        );
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            breed.imageUrl != ''
                ? ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                breed.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
                : Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: Text('No Image')),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    breed.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Temperament: ${breed.temperament}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lifespan: ${breed.lifeSpan}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
