import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment", style: TextStyle(color: Color(0xFFE8E8E8))),
        backgroundColor: const Color(0xFF7286D3),
        iconTheme: const IconThemeData(color: Color(0xFFE8E8E8)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Complete Your Payment",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF7286D3)),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your payment details below to complete your purchase.",
              style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_nameController, 'Cardholder Name', Icons.person, 'Please enter your name'),
                  const SizedBox(height: 15),
                  _buildTextField(_cardNumberController, 'Card Number', Icons.credit_card, 'Please enter your card number', isNumeric: true),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(_expiryController, 'Expiry Date (MM/YY)', Icons.date_range, 'Enter expiry date', isNumeric: true),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildTextField(_cvvController, 'CVV', Icons.lock, 'Enter CVV', isNumeric: true, maxLength: 3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7286D3),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Pay Now',
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

  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData icon, String validationMsg,
      {bool isNumeric = false, int maxLength = 20}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF555555)),
        prefixIcon: Icon(icon, color: Color(0xFF7286D3)),
        filled: true,
        fillColor: const Color(0xFFF3E7F3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      ),
      maxLength: maxLength,
      validator: (value) => value!.isEmpty ? validationMsg : null,
    );
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment processing...")),
      );
      // Simulate processing time, then show confirmation.
      Future.delayed(const Duration(seconds: 2), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Successful!")),
        );
      });
    }
  }
}
