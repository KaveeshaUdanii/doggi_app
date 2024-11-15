import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  _AccountInfoPageState createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  String? userName;
  String? userEmail;
  String? userProfileUrl;
  String? contact;
  String? userAddress;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('UserDetails')
            .doc(user.uid)
            .get();

        setState(() {
          userName = userDoc['name'];
          userEmail = userDoc['email'];
          contact = userDoc['contact'] ?? 'Not provided'; // Default fallback
          userAddress = userDoc['address'] ?? 'Not provided'; // Default fallback
          userProfileUrl = userDoc['profileImageUrl'];
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Account Info",
          style: TextStyle(color: Color(0xFFFFF2F2)),
        ),
        backgroundColor: const Color(0xFF7286D3),
      ),
      body: userName == null || userEmail == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, // Adaptive horizontal padding
          vertical: screenHeight * 0.02, // Adaptive vertical padding
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(screenWidth),
              SizedBox(height: screenHeight * 0.03), // Adaptive spacing
              _buildDetailCard("Email", userEmail ?? "Not available"),
              _buildDetailCard("Contact", contact ?? "Not available"),
              _buildDetailCard("Address", userAddress ?? "Not available"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8EA7E9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.05), // Adaptive padding
      child: Row(
        children: [
          CircleAvatar(
            radius: screenWidth * 0.12, // Adaptive radius
            backgroundImage: userProfileUrl != null && userProfileUrl!.isNotEmpty
                ? NetworkImage(userProfileUrl!)
                : const AssetImage('assets/user.png') as ImageProvider,
          ),
          SizedBox(width: screenWidth * 0.05), // Adaptive spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName ?? "Loading...",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05, // Adaptive font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenWidth * 0.01), // Spacing
                Text(
                  userEmail ?? "Loading...",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04, // Adaptive font size
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String detail) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            detail,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
