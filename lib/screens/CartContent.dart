import 'package:flutter/material.dart';

// Cart Page Content (StatefulWidget)
class CartContent extends StatefulWidget {
  const CartContent({Key? key}) : super(key: key);

  @override
  _CartContentState createState() => _CartContentState();
}

class _CartContentState extends State<CartContent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Shopping Cart",
        style: TextStyle(fontSize: 28, color: const Color(0xFF7286D3)),
      ),
    );
  }
}
