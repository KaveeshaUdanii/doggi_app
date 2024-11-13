import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'CheckoutPage.dart';

class CartContent extends StatefulWidget {
  const CartContent({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartContent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> cartItems = [];
  double subtotal = 0.0;
  double deliveryCharge = 20.0;
  double tax = 10.0;
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Fetch user's cart
        final cartSnapshot = await FirebaseFirestore.instance
            .collection('cart')
            .where('user_id', isEqualTo: user.uid)
            .get();

        if (cartSnapshot.docs.isEmpty) {
          print('No items found in the cart.');
        }

        List<Map<String, dynamic>> tempCartItems = [];
        for (var doc in cartSnapshot.docs) {
          var cartItem = {
            'id': doc.id,
            ...doc.data()
          };

          // Log cart item data
          print('Cart item data: ${cartItem}');

          // Fetch corresponding food item from the food collection
          final foodDoc = await FirebaseFirestore.instance
              .collection('food')
              .doc(cartItem['food_id']) // food_id points to food document
              .get();

          if (foodDoc.exists) {
            var foodData = foodDoc.data() as Map<String, dynamic>;
            cartItem['F_name'] = foodData['F_Name']; // Update with food name
            cartItem['imageUrl'] = foodData['Image']; // Update with food image URL
            cartItem['Price'] = _parsePrice(foodData['Price'] ?? '0'); // Parse price
          } else {
            cartItem['F_name'] = 'No Name'; // Fallback for missing food
            cartItem['imageUrl'] = ''; // Fallback for missing image
            cartItem['Price'] = 0.0; // Fallback for missing price
            print('Food document not found for food_id: ${cartItem['food_id']}');
          }

          tempCartItems.add(cartItem);
        }

        setState(() {
          cartItems = tempCartItems;
          _calculateSubtotal();
        });
      } catch (e) {
        print('Error fetching cart items: $e');
      }
    } else {
      print('User is not authenticated.');
    }
  }

  double _parsePrice(String price) {
    // Remove non-numeric characters and parse to double
    price = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(price) ?? 0.0;
  }

  void _calculateSubtotal() {
    subtotal = 0;
    for (var item in cartItems) {
      double itemPrice = (item['Price'] ?? 0).toDouble();
      int itemQuantity = (item['quantity'] ?? 1).toInt();
      subtotal += itemPrice * itemQuantity;
    }
    total = subtotal + deliveryCharge + tax;
  }

  Future<void> _updateQuantity(String docId, int newQuantity) async {
    if (newQuantity < 1) return;

    await FirebaseFirestore.instance.collection('cart').doc(docId).update({
      'quantity': newQuantity,
    });

    setState(() {
      cartItems = cartItems.map((item) {
        if (item['id'] == docId) {
          item['quantity'] = newQuantity;
        }
        return item;
      }).toList();
      _calculateSubtotal();
    });
  }

  Future<void> _removeFromCart(String docId) async {
    await FirebaseFirestore.instance.collection('cart').doc(docId).delete();

    setState(() {
      cartItems.removeWhere((item) => item['id'] == docId);
      _calculateSubtotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item['imageUrl'] ?? '',
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  height: 60,
                                  width: 60,
                                  child: const Icon(Icons.error),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['F_name'] ?? 'No Name',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Rs. ${(item['Price'] ?? 0).toDouble().toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Quantity controls
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  int currentQuantity = item['quantity'] ?? 1;
                                  _updateQuantity(item['id'], currentQuantity - 1);
                                },
                              ),
                              Text(item['quantity']?.toString() ?? '1'),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  int currentQuantity = item['quantity'] ?? 1;
                                  _updateQuantity(item['id'], currentQuantity + 1);
                                },
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeFromCart(item['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Price details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Subtotal:"),
                Text("Rs. ${subtotal.toStringAsFixed(2)}"),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Delivery charge:"),
                Text("Rs. ${deliveryCharge.toStringAsFixed(2)}"),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tax:"),
                Text("Rs. ${tax.toStringAsFixed(2)}"),
              ],
            ),
            const Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rs. ${total.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Checkout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CheckoutPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Checkout",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
