import 'package:flutter/material.dart';

class PromotionsPage extends StatelessWidget {
  const PromotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exclusive Promotions", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF7286D3),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            PromotionCard(
              title: '20% OFF on First Purchase!',
              description:
              'Use code "FIRSTBUY" to get 20% off your first order on dog food. Valid for new users only.',
              expirationDate: 'Expires: 31st December 2024',
            ),
            PromotionCard(
              title: 'Buy 1 Get 1 Free!',
              description:
              'Purchase any pack of premium dog food and get another one free. Limited time offer.',
              expirationDate: 'Expires: 15th December 2024',
            ),
            PromotionCard(
              title: 'Free Shipping on Orders Above \$50',
              description:
              'Get free shipping when you purchase over \$50 worth of dog food and products.',
              expirationDate: 'No expiration date.',
            ),
            PromotionCard(
              title: '10% OFF on Dog Care Products',
              description:
              'Enjoy a 10% discount on all dog care products like grooming supplies, beds, and more.',
              expirationDate: 'Expires: 25th December 2024',
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Premium PromotionCard Widget
class PromotionCard extends StatelessWidget {
  final String title;
  final String description;
  final String expirationDate;

  const PromotionCard({
    super.key,
    required this.title,
    required this.description,
    required this.expirationDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 15,
      shadowColor: Colors.black.withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF7286D3), // Deep blue (Primary)
              const Color(0xFF8EA7E9), // Lighter blue
              const Color(0xFFD5C6E0), // Light lavender
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(5, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              expirationDate,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle action (e.g., apply promotion code)
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14), backgroundColor: const Color(0xFFE5E0FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  'Claim Offer',
                  style: TextStyle(fontSize: 16, color: Color(0xFF7286D3), fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
