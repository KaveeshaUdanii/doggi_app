import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../auth/login_page.dart';
import '../Payment/payment_page.dart';
import 'AccountInfoPage.dart';
import 'EditProfilePage.dart';
import 'MyOrders.dart';

class AccountContent extends StatefulWidget {
  const AccountContent({super.key});

  @override
  _AccountContentState createState() => _AccountContentState();
}

class _AccountContentState extends State<AccountContent> {
  String? userName;
  String? userEmail;
  String? userProfileUrl;

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

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'] ?? "Unknown User";
            userEmail = userDoc['email'] ?? "No email found";
            userProfileUrl = userDoc['profileImageUrl'] ?? '';
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _pickAndUploadImage() async {
    var status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied. Enable permission to upload photo.")),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          File file = File(pickedFile.path);

          String filePath = 'userProfileImages/${user.uid}.jpg';
          await FirebaseStorage.instance.ref(filePath).putFile(file);

          String downloadUrl = await FirebaseStorage.instance.ref(filePath).getDownloadURL();

          await FirebaseFirestore.instance
              .collection('UserDetails')
              .doc(user.uid)
              .update({'profileImageUrl': downloadUrl});

          setState(() {
            userProfileUrl = downloadUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile image updated")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading image: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image selected")),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  Future<void> _deleteAccount() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Account"),
            content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone.",
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        try {
          await FirebaseFirestore.instance.collection('UserDetails').doc(user.uid).delete();
          await user.delete();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting account: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.03,
              horizontal: screenWidth * 0.3,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF7286D3),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.13,
                      backgroundImage: (userProfileUrl != null && userProfileUrl!.isNotEmpty)
                          ? NetworkImage(userProfileUrl!)
                          : const AssetImage('assets/user.png') as ImageProvider,
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _pickAndUploadImage,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  userName ?? "Loading...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userEmail ?? "Loading...",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: ListView(
                children: [
                  _buildOptionCard(icon: Icons.person_outline, text: "Edit Profile", onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfilePage()),
                    );
                  }),
                  _buildOptionCard(icon: Icons.shopping_bag_outlined, text: "My Orders", onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyOrders()),
                    );
                  }),
                  _buildOptionCard(icon: Icons.payment_outlined, text: "Payment Details", onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PaymentPage()),
                    );
                  }),
                  _buildOptionCard(icon: Icons.info_outline, text: "Account Info", onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AccountInfoPage()),
                    );
                  }),
                  const Divider(height: 30),
                  _buildOptionCard(icon: Icons.delete_outline, text: "Delete Account", onTap: _deleteAccount, color: Colors.red),
                  _buildOptionCard(icon: Icons.logout, text: "Logout", onTap: _logout, color: Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5, // Increased elevation for a smoother shadow effect
      margin: const EdgeInsets.symmetric(vertical: 12),
      shadowColor: Colors.black.withOpacity(0.2), // Soft shadow for a more refined look
      child: InkWell(
        borderRadius: BorderRadius.circular(20), // Ensure the InkWell follows the card's rounded corners
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // More balanced padding
          child: Row(
            children: [
              Icon(icon, color: color, size: 24), // Larger icon for better visibility
              const SizedBox(width: 12), // Added spacing between icon and text
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600, // Slightly bolder for a stronger impact
                    fontSize: 16, // Increased font size for readability
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18), // Slightly bigger arrow
            ],
          ),
        ),
      ),
    );
  }

}
