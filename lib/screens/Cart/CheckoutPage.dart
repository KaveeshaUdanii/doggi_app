import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? userName;
  String? email;
  String? address;
  String? phoneNumber;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('UserDetails')
            .doc(user.uid)
            .get();

        setState(() {
          userName = userDoc['name'] ?? '';
          email = userDoc['email'] ?? '';
          address = userDoc['address'] ?? '';
          phoneNumber = userDoc['phone_number'] ?? '';
          isLoading = false;
        });
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      User? user = _auth.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance.collection('Orders').add({
            'UID': user.uid,
            'name': userName,
            'email': email,
            'address': address,
            'phone_number': phoneNumber,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Order placed successfully!")),
          );
          Navigator.pop(context);
        } catch (e) {
          print("Error placing order: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error placing order: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: const Color(0xFF7286D3),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Review Your Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8EA7E9),
                ),
              ),
              const SizedBox(height: 20),
              _buildReadOnlyField("Username", userName ?? ""),
              _buildReadOnlyField("Email", email ?? ""),
              _buildEditableField("Address", address ?? "", (value) {
                address = value;
              }),
              _buildEditableField("Phone Number", phoneNumber ?? "",
                      (value) {
                    phoneNumber = value;
                  }),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color(0xFF8EA7E9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    "Confirm Order",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Color(0xFF8EA7E9)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: Text(
            value.isNotEmpty ? value : "Not provided",
            style: const TextStyle(fontSize: 16, color: Color(0xFF374151)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEditableField(
      String label, String value, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF8EA7E9)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "$label cannot be empty";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
