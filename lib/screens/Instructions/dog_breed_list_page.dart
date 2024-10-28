import 'package:doggi_app/screens/Instructions/dog_breed_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:doggi_app/models/dog_breed.dart';
import 'package:doggi_app/services/dog_breed_service.dart';

class DogBreedListPage extends StatefulWidget {
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
      appBar: AppBar(title: Text('Dog Breeds')),
      body: FutureBuilder<List<DogBreed>>(
        future: futureDogBreeds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No breeds found.'));
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

  DogBreedCard({required this.breed});

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
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            breed.imageUrl != ''
                ? ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
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
              child: Center(child: Text('No Image')),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Temperament: ${breed.temperament}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Lifespan: ${breed.lifeSpan}',
                    style: TextStyle(fontSize: 14),
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
