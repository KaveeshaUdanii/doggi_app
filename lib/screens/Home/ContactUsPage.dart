import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  Future<void> _sendEmail() async {
    if (_formKey.currentState!.validate()) {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'kaveeshaudani08@gmail.com',
        queryParameters: {
          'subject': _subjectController.text,
          'body': 'Name: ${_nameController.text}\nEmail: ${_emailController.text}\n\n${_messageController.text}'
        },
      );
      //
      try {
        if (await launchUrl(emailUri)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message sent successfully!')),
          );
          // Clear the form after successful send
          _nameController.clear();
          _emailController.clear();
          _subjectController.clear();
          _messageController.clear();
        } else {
          throw 'Could not open email app';
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us', style: TextStyle(color: Color(0xFFE5E0FF))),
        backgroundColor: const Color(0xFF7286D3),
        iconTheme: const IconThemeData(color: Color(0xFFE5E0FF)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "We'd love to hear from you!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF7286D3)),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please fill out the form below to get in touch.",
              style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_nameController, 'Name', Icons.person, 'Please enter your name'),
                  const SizedBox(height: 15),
                  _buildTextField(_emailController, 'Email', Icons.email, 'Please enter your email'),
                  const SizedBox(height: 15),
                  _buildTextField(_subjectController, 'Subject', Icons.subject, 'Please enter a subject'),
                  const SizedBox(height: 15),
                  _buildTextField(_messageController, 'Message', Icons.message, 'Please enter a message', maxLines: 5),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sendEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7286D3),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Send Message',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon, String validationMsg, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF555555)),
        prefixIcon: Icon(icon, color: Color(0xFF7286D3)),
        filled: true,
        fillColor: const Color(0xFFF0F0F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      ),
      maxLines: maxLines,
      validator: (value) => value!.isEmpty ? validationMsg : null,
    );
  }
}
