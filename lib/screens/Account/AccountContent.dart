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

        // Check if data exists in Firestore
        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'] ?? "Unknown User";
            userEmail = userDoc['email'] ?? "No email found";
            userProfileUrl = userDoc['profileImageUrl'] ?? '';
          });
        } else {
          print("No user data found");
          setState(() {
            userName = "No name found";
            userEmail = "No email found";
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        userName = "Error loading user data";
        userEmail = "Error loading user data";
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    // Request permission to access photos
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

          // Upload the image to Firebase Storage
          String filePath = 'userProfileImages/${user.uid}.jpg';
          await FirebaseStorage.instance.ref(filePath).putFile(file);

          // Get the download URL
          String downloadUrl = await FirebaseStorage.instance.ref(filePath).getDownloadURL();

          // Update Firestore user document
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully logged out")),
      );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account deleted successfully")),
          );
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 155),
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
                      radius: 50,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userEmail ?? "Loading...",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  _buildOptionCard(
                    icon: Icons.person_outline,
                    text: "Edit Profile",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfilePage()),
                      );
                    },
                  ),
                  _buildOptionCard(
                    icon: Icons.shopping_bag_outlined,
                    text: "My Orders",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyOrders()),
                      );
                    },
                  ),
                  _buildOptionCard(
                    icon: Icons.payment_outlined,
                    text: "Payment Details",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaymentPage()),
                      );
                    },
                  ),
                  _buildOptionCard(
                    icon: Icons.info_outline,
                    text: "Account Info",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccountInfoPage()),
                      );
                    },
                  ),
                  const Divider(height: 30),
                  _buildOptionCard(
                    icon: Icons.delete_outline,
                    text: "Delete Account",
                    onTap: _deleteAccount,
                    color: Colors.red,
                  ),
                  _buildOptionCard(
                    icon: Icons.logout,
                    text: "Logout",
                    onTap: _logout,
                    color: Colors.red,
                  ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    );
  }
}
