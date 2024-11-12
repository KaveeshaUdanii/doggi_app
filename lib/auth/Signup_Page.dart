import 'package:flutter/material.dart';
import 'login_page.dart';
import '../auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPageState extends StatefulWidget {
  const SignupPageState({super.key});

  @override
  State<SignupPageState> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPageState> {
  late Color myColor;
  late Size mediaSize;
  TextEditingController NameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool rememberUser = false;

  final AuthService _authService = AuthService();  // Auth service instance

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF7286D3),
        image: DecorationImage(
          image: const AssetImage("assets/girlD.jpeg"),
          fit: BoxFit.cover,
          colorFilter:
          ColorFilter.mode(myColor.withOpacity(0.2), BlendMode.dstATop),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          Positioned(top: 80, child: _buildTop()),
          Positioned(bottom: 0, child: _buildBottom()),
        ]),
      ),
    );
  }

  Widget _buildTop() {
    return SizedBox(
      width: mediaSize.width,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pets,
            size: 90,
            color: Colors.white,
          ),
          Text(
            "DOGGI",
            style: TextStyle(
                color: Color(0xFFE5E0FF),
                fontWeight: FontWeight.bold,
                fontSize: 40,
                letterSpacing: 2),
          )
        ],
      ),
    );
  }

  Widget _buildBottom() {
    return SizedBox(
      width: mediaSize.width,
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            )),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Create Account",
          style: TextStyle(
              color: Color(0xFF8EA7E9), fontSize: 32, fontWeight: FontWeight.w500),
        ),
        _buildGreyText("Sign up to get started"),
        const SizedBox(height: 60),
        _buildGreyText("Name"),
        _buildInputField(NameController),
        const SizedBox(height: 20),
        _buildGreyText("Email address"),
        _buildInputField(emailController),
        const SizedBox(height: 40),
        _buildGreyText("Password"),
        _buildInputField(passwordController, isPassword: true),
        const SizedBox(height: 20),
        _buildSignupButton(),
        const SizedBox(height: 20),
        _buildLogin(),
      ],
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.grey),
    );
  }

  Widget _buildInputField(TextEditingController controller,
      {isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: isPassword ? const Icon(Icons.remove_red_eye) : const Icon(Icons.done),
      ),
      obscureText: isPassword,
    );
  }

  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: () async {
        final user = await _authService.registerWithEmail(
            emailController.text.trim(), passwordController.text.trim());
        if (user != null) {
          // Add user details to Firestore
          _addUserDetails(user);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to sign up")),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        backgroundColor: const Color(0xFF8EA7E9),
        elevation: 20,
        shadowColor: myColor,
        minimumSize: const Size.fromHeight(60),
      ),
      child: const Text(
        "SIGN UP",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLogin() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the items horizontally
        children: [
          _buildGreyText("Go Back?"),
          const SizedBox(width: 5), // Add spacing between the text
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text(
              "Log in",
              style: TextStyle(
                color: Colors.deepPurple,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to add user details to Firestore
  Future<void> _addUserDetails(User user) async {
    try {
      // Add user details to 'UserDetails' collection in Firestore
      await FirebaseFirestore.instance.collection('UserDetails').doc(user.uid).set({
        'uid': user.uid,  // Store UID
        'name': NameController.text.trim(),
        'email': emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(), // Timestamp for when the account was created
      });
    } catch (e) {
      print("Error adding user details: $e");
    }
  }
}
