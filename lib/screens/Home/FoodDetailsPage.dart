import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Cart/CheckoutPage.dart';
import '../Favourite/FavoritesContent.dart';

class FoodDetailsPage extends StatefulWidget {
  final Product product;

  const FoodDetailsPage({super.key, required this.product});

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
          style: const TextStyle(color: Color(0xFFFFF2F2),),
        ),
        backgroundColor: const Color(0xFF7286D3),
        elevation: 4.0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
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
                      style: const TextStyle(
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
                        const Icon(Icons.access_time, color: Color(0xFF8EA7E9)),
                        const SizedBox(width: 4),
                        Text(
                          'Delivery Time: 30 min',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price
                    Text(
                      '\$${widget.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
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
                          icon: const Icon(Icons.remove, color: Color(0xFF8EA7E9)),
                          onPressed: decreaseQuantity,
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Color(0xFF8EA7E9)),
                          onPressed: increaseQuantity,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Total Price
                    Text(
                      'Total: \$${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
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

          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                GestureDetector(
                  onTap: () async {
                    await addToCart(widget.product.name);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item added successfully!')),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF8EA7E9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Icon(
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
                    backgroundColor: WidgetStateProperty.all(const Color(0xFF7286D3)),
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16, horizontal: 60)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    )),
                    elevation: WidgetStateProperty.all(4),
                  ),
                  child: const Text(
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

  Future<void> addToCart(String fName) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch the food document ID first
      final foodSnapshot = await FirebaseFirestore.instance
          .collection('Food')
          .where('F_Name', isEqualTo: fName) // Assuming 'F_Name' is unique
          .limit(1)
          .get();

      if (foodSnapshot.docs.isNotEmpty) {
        final foodDoc = foodSnapshot.docs.first;
        final foodData = foodDoc.data();

        // Get the price and convert it to an integer (in cents, for example)
        double price = foodData['price']?.toDouble() ?? 0.0;
        int priceInCents = (price * 100).toInt(); // Convert to integer (cents)

        // Save to Firestore in 'cart' collection
        await FirebaseFirestore.instance.collection('cart').add({
          'user_id': user.uid,
          'F_name': fName,
          'food_doc_id': foodDoc.id, // Save the food document ID
          'Image': foodData['Image'], // Add the Image URL from Firestore
          'price': priceInCents, // Save as integer (cents)
          'quantity': 1, // Default quantity
          'timestamp': FieldValue.serverTimestamp(),
        });

        print("Item added to cart with price (in cents): $priceInCents");
      } else {
        print("Food item not found in Firestore");
      }
    } else {
      print("User is not logged in");
    }
  }

}
