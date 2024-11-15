import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

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
          _nameController.text = userDoc['name'] ?? '';
          _emailController.text = userDoc['email'] ?? '';
          _addressController.text = userDoc['address'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user data: $e")),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Map<String, dynamic> updatedData = {};
          if (_nameController.text.isNotEmpty) updatedData['name'] = _nameController.text;
          if (_emailController.text.isNotEmpty) updatedData['email'] = _emailController.text;
          if (_addressController.text.isNotEmpty) updatedData['address'] = _addressController.text;

          await FirebaseFirestore.instance.collection('UserDetails').doc(user.uid).update(updatedData);

          if (_passwordController.text.isNotEmpty) {
            await user.updatePassword(_passwordController.text);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Color(0xFFE5E0FF))),
        backgroundColor: const Color(0xFF7286D3),
        iconTheme: const IconThemeData(color: Color(0xFFE5E0FF)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameController, 'Username', Icons.person, 'Please enter a username'),
              const SizedBox(height: 15),
              _buildTextField(_emailController, 'Email', Icons.email, 'Please enter a valid email'),
              const SizedBox(height: 15),
              _buildTextField(_passwordController, 'Password (Leave blank to keep unchanged)', Icons.lock, 'Enter new password', obscureText: true),
              const SizedBox(height: 15),
              _buildTextField(_addressController, 'Address', Icons.location_on, 'Please enter your address'),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7286D3),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String labelText,
      IconData icon,
      String validationMsg, {
        bool obscureText = false,
      }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF555555)),
        prefixIcon: Icon(icon, color: const Color(0xFF7286D3)),
        filled: true,
        fillColor: const Color(0xFFF0F0F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      ),
      obscureText: obscureText,
      validator: (value) => value!.isEmpty ? validationMsg : null,
    );
  }
}
