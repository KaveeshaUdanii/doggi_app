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
  String? userPhoneNumber;
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
          userPhoneNumber = userDoc['phone_number'] ?? 'Not provided';
          userAddress = userDoc['address'] ?? 'Not provided';
          userProfileUrl = userDoc['profileImageUrl'];
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Account Info", style: TextStyle(color: Color(0xFFFFF2F2),)),
        backgroundColor: const Color(0xFF7286D3),
      ),
      body: userName == null || userEmail == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _buildDetailCard("Email", userEmail ?? "Not available"),
              _buildDetailCard("Phone Number", userPhoneNumber ?? "Not available"),
              _buildDetailCard("Address", userAddress ?? "Not available"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: userProfileUrl != null && userProfileUrl!.isNotEmpty
                ? NetworkImage(userProfileUrl!)
                : const AssetImage('assets/profile_image.jpg') as ImageProvider,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName ?? "Loading...",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                userEmail ?? "Loading...",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
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
    );
  }
}
