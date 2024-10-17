import 'package:flutter/material.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int selectedIndex = 0; // Keep track of the selected food category

  final List<Map<String, dynamic>> categories = [
    {'name': 'Kibble', 'icon': Icons.pets, 'image': 'assets/sri_lankan_icon.png'},
    {'name': 'Canned Food', 'icon': Icons.pets, 'image': 'assets/chinese_icon.png'},
    {'name': 'Semi-Moist Food', 'icon': Icons.pets, 'image': 'assets/italian_icon.png'},
    {'name': 'Home Cooked Food', 'icon': Icons.pets, 'image': 'assets/thai_icon.png'},
    {'name': 'Raw Dog Food', 'icon': Icons.pets, 'image': 'assets/indian_icon.png'},
  ];

  // Sample products data
  final Map<String, List<Product>> products = {
    'Kibble': [
      Product(name: 'Chicken Kibble', subtitle: 'High Protein', price: 29.99, reviews: 5),
      Product(name: 'Beef Kibble', subtitle: 'Grain Free', price: 32.50, reviews: 4.5),
      Product(name: 'Chicken Kibble', subtitle: 'High Protein', price: 29.99, reviews: 5),
      Product(name: 'Chicken Kibble', subtitle: 'High Protein', price: 29.99, reviews: 5),
      Product(name: 'Chicken Kibble', subtitle: 'High Protein', price: 29.99, reviews: 5),
      Product(name: 'Chicken Kibble', subtitle: 'High Protein', price: 29.99, reviews: 5),

    ],
    'Canned Food': [
      Product(name: 'Chicken Canned Food', subtitle: 'With Vegetables', price: 24.99, reviews: 4.8),
      Product(name: 'Fish Canned Food', subtitle: 'Rich in Omega-3', price: 22.50, reviews: 4.7),
    ],
    'Semi-Moist Food': [
      Product(name: 'Beef Semi-Moist Food', subtitle: 'Tender and Juicy', price: 26.99, reviews: 4.6),
      Product(name: 'Chicken Semi-Moist Food', subtitle: 'All Natural', price: 28.50, reviews: 4.5),
    ],
    // Add products for other categories similarly
  };

  @override
  Widget build(BuildContext context) {
    String selectedCategory = categories[selectedIndex]['name'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar and filter button row
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for Food',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(45),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey[200],
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(45),
                ),
                child: Icon(Icons.tune_rounded),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // "Food Categories" title
          const Text(
            'Food Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          // Horizontal scrollable food category buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(categories.length, (index) {
                final category = categories[index];
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFFE5E0FF) : Color(0xFFFFD9F4),
                      borderRadius: BorderRadius.circular(45),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          category['icon'],
                          color: isSelected ? Color(0xFF8EA7E9) : Color(0xFF7286D3),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category['name'],
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? Color(0xFF8EA7E9) : Color(0xFF7286D3),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Product cards section
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 20.0,
                childAspectRatio: 0.7,
              ),
              itemCount: products[selectedCategory]?.length ?? 0,
              itemBuilder: (context, index) {
                final product = products[selectedCategory]![index];
                return ProductCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Product class to hold product details
class Product {
  final String name;
  final String subtitle;
  final double price;
  final double reviews;

  Product({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.reviews,
  });
}

// ProductCard widget to display individual product details
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name
            Text(
              product.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            // Product subtitle
            Text(
              product.subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            // Product price
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Customer reviews
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(
                  product.reviews.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
