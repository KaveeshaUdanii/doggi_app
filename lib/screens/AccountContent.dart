import 'package:flutter/material.dart';


// Account Page Content
class AccountContent extends StatelessWidget {
  const AccountContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Account Information",
        style: TextStyle(fontSize: 28, color: const Color(0xFF7286D3)),
      ),
    );
  }
}