import 'package:flutter/material.dart';


// Cart Page Content
class CartContent extends StatelessWidget {
  const CartContent({Key? key}) : super(key: key);

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