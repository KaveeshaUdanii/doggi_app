import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartContent extends StatefulWidget {
  const CartContent({Key? key}) : super(key: key);

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
      final cartSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('user_id', isEqualTo: user.uid)
          .get();

      List<Map<String, dynamic>> tempCartItems = [];
      for (var doc in cartSnapshot.docs) {
        var cartItem = {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        };

        // Fetch the corresponding food item from the food collection
        final foodDoc = await FirebaseFirestore.instance
            .collection('food')
            .doc(cartItem['food_id']) // Assuming you have a field 'food_id' in cart
            .get();

        if (foodDoc.exists) {
          var foodData = foodDoc.data() as Map<String, dynamic>;
          cartItem['name'] = foodData['name']; // Replace No Name with the actual name
          cartItem['imageUrl'] = foodData['imageUrl']; // Assuming there's an image URL

          // Convert price string to numeric value
          String priceString = foodData['Price'] ?? '0';
          double priceValue = _parsePrice(priceString);
          cartItem['Price'] = priceValue;

        } else {
          cartItem['name'] = 'No Name'; // Fallback if the food item doesn't exist
        }

        tempCartItems.add(cartItem);
      }

      setState(() {
        cartItems = tempCartItems;
        _calculateSubtotal();
      });
    }
  }

  double _parsePrice(String Price) {
    // Remove currency symbols (Rs., $, etc.), commas, and any extra spaces
    Price = Price.replaceAll(RegExp(r'[^\d.]'), '');
    // Try parsing the string to a double
    return double.tryParse(Price) ?? 0.0;
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
                  // Handle checkout action here
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
