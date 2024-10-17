import 'package:flutter/material.dart';


// Account Page Content (StatefulWidget)
class AccountContent extends StatefulWidget {
  const AccountContent({Key? key}) : super(key: key);

  @override
  _AccountContentState createState() => _AccountContentState();
}

class _AccountContentState extends State<AccountContent> {
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
