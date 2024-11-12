import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<DocumentSnapshot> _productDetails;

  @override
  void initState() {
    super.initState();
    _productDetails = FirebaseFirestore.instance
        .collection('Food')
        .doc(widget.productId)  // Fetch the product using its ID
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _productDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No product found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Extract the product details
          final productName = data['F_Name'] ?? 'No Name';
          final description = data['Description'] ?? 'No Description';
          final price = double.tryParse(data['Price']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0.0');
          final imageUrl = data['image'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(imageUrl, fit: BoxFit.cover),
                SizedBox(height: 10),
                Text(
                  productName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Text(
                  'Rs. ${price?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Add to cart functionality here
                    addToCart(productName);
                  },
                  child: Text('Add to Cart'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> addToCart(String itemName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final foodSnapshot = await FirebaseFirestore.instance
          .collection('Food')
          .where('F_Name', isEqualTo: itemName)
          .limit(1)
          .get();

      if (foodSnapshot.docs.isNotEmpty) {
        final foodDocId = foodSnapshot.docs.first.id;

        await FirebaseFirestore.instance.collection('cart').add({
          'user_id': user.uid,
          'item_name': itemName,
          'food_doc_id': foodDocId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$itemName added to cart'),
        ));
      }
    }
  }
}
