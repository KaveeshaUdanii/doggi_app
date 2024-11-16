import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Color(0xFFE5E0FF),
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
          ),
        ),
        backgroundColor: const Color(0xFF8EA7E9),
        iconTheme: const IconThemeData(color: Color(0xFFE5E0FF)),
        centerTitle: true,
        elevation: 5,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .where('uid', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No orders found.',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFF8EA7E9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              List<dynamic> items = order['items'] ?? [];
              double totalPrice = order['total_price'] ?? 0.0;
              Timestamp orderDate = order['order_date'];
              String contact = order['contact'] ?? 'N/A';
              String address = order['address'] ?? 'N/A';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7286D3),
                            ),
                          ),
                          Text(
                            '#${order.id.substring(0, 8).toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, itemIndex) {
                          var item = items[itemIndex];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['food_name'] ?? 'Unknown Item',
                                  style: const TextStyle(fontSize: 16.0, color: Colors.black87),
                                ),
                                Text(
                                  'x${item['quantity']}',
                                  style: const TextStyle(fontSize: 16.0, color: Colors.black54),
                                ),
                                Text(
                                  '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 16.0, color: Colors.black87),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Price:',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8EA7E9),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20.0, color: Colors.grey),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 18, color: Color(0xFF8EA7E9)),
                          const SizedBox(width: 8),
                          Text(
                            'Contact: $contact',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18, color: Color(0xFF8EA7E9)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Address: $address',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: Color(0xFF8EA7E9)),
                          const SizedBox(width: 8),
                          Text(
                            'Date: ${orderDate.toDate()}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
