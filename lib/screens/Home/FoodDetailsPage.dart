import 'package:flutter/material.dart';
import '../Favourite/FavoritesContent.dart';

class FoodDetailsPage extends StatelessWidget {
  final Product product;

  const FoodDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displaying the product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                height: 250,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    height: 250,
                    width: double.infinity,
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Product name
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Product description
            Text(
              product.subtitle,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Product price
            Text(
              'Rs. ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Product reviews
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow),
                Text(
                  '${product.reviews.toStringAsFixed(1)} Reviews',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
