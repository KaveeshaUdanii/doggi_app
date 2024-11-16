import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  late String userId;
  List<Map<String, dynamic>> cartItems = [];
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    _loadCartItems();
    _loadUserDetails();
  }

  // Load cart items from Firestore
  Future<void> _loadCartItems() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('uid', isEqualTo: userId)
        .get();

    setState(() {
      cartItems = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Include document ID for potential updates
        return data;
      }).toList();

      totalPrice = cartItems.fold(0.0, (sum, item) {
        return sum + (item['price'] * item['quantity']);
      });
    });
  }

  // Load user details from Firestore
  Future<void> _loadUserDetails() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userSnapshot.exists) {
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
      if (userData != null) {
        setState(() {
          _contactController.text = userData['contact'] ?? '';
          _addressController.text = userData['address'] ?? '';
        });
      }
    }
  }

  // Save order details to Firestore
  Future<void> _placeOrder() async {
    try {
      await FirebaseFirestore.instance.collection('Orders').add({
        'uid': userId,
        'items': cartItems.map((item) {
          return {
            'food_name': item['F_name'],
            'quantity': item['quantity'],
            'price': item['price'],
          };
        }).toList(),
        'total_price': totalPrice,
        'contact': _contactController.text,
        'address': _addressController.text,
        'order_date': FieldValue.serverTimestamp(),
      });

      // Clear cart after placing the order
      for (var item in cartItems) {
        await FirebaseFirestore.instance.collection('cart').doc(item['id']).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      Navigator.pop(context); // Navigate back to the previous page or home screen
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF8EA7E9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: 'Contact Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  var item = cartItems[index];
                  return Card(
                    child: ListTile(
                      title: Text(item['F_name'] ?? 'Item'),
                      subtitle: Text(
                          'Quantity: ${item['quantity']} | Price: \$${item['price'].toStringAsFixed(2)}'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total: \$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8EA7E9),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Confirm Order',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
