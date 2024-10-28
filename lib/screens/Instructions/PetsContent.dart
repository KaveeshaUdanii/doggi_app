import 'package:doggi_app/screens/Instructions/dog_breed_list_page.dart';
import 'package:flutter/material.dart';


class PetsContent extends StatefulWidget {
  const PetsContent({super.key});

  @override
  State<PetsContent> createState() => _PetsContentState();
}

class _PetsContentState extends State<PetsContent> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DogBreedListPage(),
    );
  }
}
