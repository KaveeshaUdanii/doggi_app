import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Cart/CheckoutPage.dart';
import '../Favourite/FavoritesContent.dart';

class FoodDetailsPage extends StatefulWidget {
  final Product product;

  const FoodDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  _FoodDetailsPageState createState() => _FoodDetailsPageState();
}

class _FoodDetailsPageState extends State<FoodDetailsPage> {
  int quantity = 1;

  // Method to increase quantity
  void increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  // Method to decrease quantity
  void decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.product.price * quantity; // Calculate total price

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF7286D3),
        elevation: 4.0, // Slight elevation for a floating effect
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between top content and button
        children: [
          Expanded( // Use Expanded to take up the remaining space for other content
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        widget.product.imageUrl,
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
                      widget.product.name,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7286D3),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Product description
                    Text(
                      widget.product.subtitle,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),

                    // Delivery time
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Color(0xFF8EA7E9)),
                        const SizedBox(width: 4),
                        Text(
                          'Delivery Time: 30 min', // Hardcoded delivery time in design
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price
                    Text(
                      '\$${widget.product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7286D3),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quantity buttons (increase/decrease)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, color: Color(0xFF8EA7E9)),
                          onPressed: decreaseQuantity,
                        ),
                        Text(
                          '$quantity', // Dynamic quantity display
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Color(0xFF8EA7E9)),
                          onPressed: increaseQuantity,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Total Price
                    Text(
                      'Total: \$${totalPrice.toStringAsFixed(2)}', // Display total price
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7286D3),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          // Add to Cart and Buy Now buttons at the bottom in a Row
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space buttons apart
              children: [
                // Add to Cart Button inside a circular container
                GestureDetector(
                  onTap: () async {
                    await addToCart(widget.product.name);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item added successfully!')),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF7286D3), // Button color
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),

                // Buy Now Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CheckoutPage()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xFF7286D3)),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16, horizontal: 70)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40), // Rounded button
                    )),
                    elevation: MaterialStateProperty.all(4), // Light shadow effect
                  ),
                  child: Text(
                    'Buy Now',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addToCart(String F_Name) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch the food document ID first
      final foodSnapshot = await FirebaseFirestore.instance
          .collection('Food')
          .where('F_Name', isEqualTo: F_Name) // Assuming 'F_Name' is unique
          .limit(1)
          .get();

      if (foodSnapshot.docs.isNotEmpty) {
        final foodDocId = foodSnapshot.docs.first.id; // Get the document ID

        // Save to Firestore in 'cart' collection
        await FirebaseFirestore.instance.collection('cart').add({
          'user_id': user.uid,
          'F_name': F_Name,
          'food_doc_id': foodDocId, // Save the food document ID
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

}
