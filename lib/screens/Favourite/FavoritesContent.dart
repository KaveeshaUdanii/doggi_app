import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Home/FoodDetailsPage.dart';

// Favorites Page Content (StatefulWidget)
class FavoritesContent extends StatefulWidget {
  const FavoritesContent({Key? key}) : super(key: key);

  @override
  _FavoritesContentState createState() => _FavoritesContentState();
}

class _FavoritesContentState extends State<FavoritesContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title for the Favorites page
          Text(
            "Favorites",
            style: TextStyle(fontSize: 28, color: const Color(0xFF7286D3)),
          ),
          const SizedBox(height: 20),

          // StreamBuilder to fetch user's favorite products
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('favorites')
                  .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No favorites found'));
                }

                // Fetching product details for each favorite
                return FutureBuilder<List<Product>>(
                  future: _fetchFavoriteProducts(snapshot.data!.docs),
                  builder: (context, foodSnapshot) {
                    if (foodSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (foodSnapshot.hasError) {
                      return Center(child: Text('Error: ${foodSnapshot.error}'));
                    }

                    final favoriteProducts = foodSnapshot.data;

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 12.0,
                        crossAxisSpacing: 12.0,
                        childAspectRatio: 3.7,
                      ),
                      itemCount: favoriteProducts?.length ?? 0,
                      itemBuilder: (context, index) {
                        final product = favoriteProducts![index];
                        return ProductCard(product: product);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to fetch product details based on favorite documents
  Future<List<Product>> _fetchFavoriteProducts(List<DocumentSnapshot> favoriteDocs) async {
    List<Product> favoriteProducts = [];

    for (var doc in favoriteDocs) {
      final foodDocId = doc['food_doc_id']; // Get food document ID from favorites
      final foodDoc = await FirebaseFirestore.instance.collection('Food').doc(foodDocId).get();

      if (foodDoc.exists) {
        final data = foodDoc.data() as Map<String, dynamic>;

        favoriteProducts.add(Product(
          id: doc.id, // Store the document ID
          name: data['F_Name'] ?? 'No Name',
          subtitle: data['Description'] ?? 'No Subtitle',
          price: double.tryParse(data['Price']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0.0,
          reviews: (data['reviews'] ?? 0).toDouble(),
          imageUrl: data['image'] ?? '',
          category: data['Category'] ?? 'No Category',
        ));
      }
    }
    return favoriteProducts;
  }
}

// Product class to hold product details
class Product {
  final String id; // Added product ID
  final String name;
  final String subtitle; // For description
  final double price;
  final double reviews;
  final String imageUrl;
  final String category;

  Product({
    required this.id, // Ensure ID is passed for removal
    required this.name,
    required this.subtitle,
    required this.price,
    required this.reviews,
    required this.imageUrl,
    required this.category,
  });
}

// ProductCard widget to display individual product details
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to FoodDetailsPage when the card is clicked
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailsPage(product: product),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image on the left
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  height: 80,
                  width: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      height: 80,
                      width: 80,
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12), // Spacing between image and details

              // Product details on the right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Product category
                    Text(
                      product.category,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Product price
                    Text(
                      'Rs. ${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Heart icon button at the end of the row (remove from favorites)
              IconButton(
                icon: Icon(Icons.favorite, color: Colors.redAccent),
                onPressed: () async {
                  // Call the function to remove the product from Firestore
                  await _removeFromFavorites(product);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to remove product from favorites
  Future<void> _removeFromFavorites(Product product) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // Get the document reference for the favorite item to be removed
        final favoriteQuery = FirebaseFirestore.instance
            .collection('favorites')
            .where('user_id', isEqualTo: userId)
            .where('food_doc_id', isEqualTo: product.id);  // You need the product's 'id'

        // Find the favorite document that matches the user and product
        final snapshot = await favoriteQuery.get();

        if (snapshot.docs.isNotEmpty) {
          // If we find a match, we delete that document from Firestore
          for (var doc in snapshot.docs) {
            await doc.reference.delete();
          }
        }
      }
    } catch (e) {
      print("Error removing from favorites: $e");
    }
  }
}
