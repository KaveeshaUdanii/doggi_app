import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'CheckoutPage.dart';

class CartContent extends StatefulWidget {
  @override
  _CartContentState createState() => _CartContentState();
}

class _CartContentState extends State<CartContent> {
  double shippingFee = 30.0;

  @override
  Widget build(BuildContext context) {
    // Get the current user UID
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      // appBar: AppBar(
      //   // title: Text('Cart'),
      //   // backgroundColor: Colors.white,
      //   // elevation: 0,
      // ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('uid', isEqualTo: userId) // Filter by user UID
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No items in cart',style: TextStyle(
              color: Color(0xFF8EA7E9),
              fontSize: 18.0,
            ),));
          }

          var cartItems = snapshot.data!.docs;
          double subtotal = 0.0;

          // Calculate subtotal
          for (var item in cartItems) {
            subtotal += item['price'] * item['quantity'];
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10.0),
                        leading: Image.network(item['Image'] ?? '', errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error);
                        }),
                        title: Text(item['F_name'] ?? 'No Name'),
                        subtitle: Text('\$${item['price']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                if (item['quantity'] > 1) {
                                  FirebaseFirestore.instance
                                      .collection('cart')
                                      .doc(item.id)
                                      .update({
                                    'quantity': item['quantity'] - 1
                                  });
                                }
                              },
                            ),
                            Text(item['quantity'].toString()),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('cart')
                                    .doc(item.id)
                                    .update({
                                  'quantity': item['quantity'] + 1
                                });
                              },
                            ),
                            // Delete Button
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('cart')
                                    .doc(item.id)
                                    .delete();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5.0,
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Selected Items'),
                        Text('\$${subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Shipping Fee'),
                        Text('\$${shippingFee.toStringAsFixed(2)}'),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal', style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),),
                        Text('\$${(subtotal + shippingFee).toStringAsFixed(2)}', style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CheckoutPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 40.0),
                          backgroundColor: Color(0xFF8EA7E9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 5.0,
                        ),
                        child: Text(
                          'Checkout',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
