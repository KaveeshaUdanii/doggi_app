import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int selectedIndex = 0;
  late String selectedCategory;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  final List<Map<String, dynamic>> categories = [
    {'name': 'Kibble', 'icon': Icons.pets},
    {'name': 'Canned Food', 'icon': Icons.pets},
    {'name': 'Semi-Moist Food', 'icon': Icons.pets},
    {'name': 'Home Cooked Food', 'icon': Icons.pets},
    {'name': 'Raw Dog Food', 'icon': Icons.pets},
  ];

  @override
  void initState() {
    super.initState();
    selectedCategory = categories[selectedIndex]['name'];
  }

  @override
  Widget build(BuildContext context) {
    selectedCategory = categories[selectedIndex]['name'];

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
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
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
                      searchQuery = ''; // Reset search on category change
                      searchController.clear();
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Food')
                  .where('Category', isEqualTo: selectedCategory)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No products available'));
                }

                // Filter products based on search query
                final products = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['F_Name']?.toString().toLowerCase() ?? '';
                  return name.contains(searchQuery);
                }).map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  // Extract the numeric price from the formatted string
                  String priceString = data['Price'] ?? 'Rs. 0';
                  double price = double.tryParse(priceString.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

                  return Product(
                    name: data['F_Name'] ?? 'No Name',
                    subtitle: data['Description'] ?? 'No Subtitle',
                    price: price,
                    reviews: (data['reviews'] ?? 0).toDouble(),
                    imageUrl: data['image'] ?? '',
                  );
                }).toList();

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20.0,
                    crossAxisSpacing: 20.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(product: product);
                  },
                );
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
  final String imageUrl;

  Product({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.reviews,
    required this.imageUrl,
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
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image with favorite button
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        height: 100,
                        width: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          // Handle favorite button action
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                  'Rs. ${product.price.toStringAsFixed(4)}',
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
                const Spacer(),
                // Add to Cart button centered at the bottom
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Handle add to cart action
                      await addToCart(product.name);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Item added successfully!')),
                      );
                    },
                    icon: Icon(Icons.shopping_cart),
                    label: Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addToCart(String itemName) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Save to Firestore in 'cart' collection
      await FirebaseFirestore.instance.collection('cart').add({
        'user_id': user.uid,
        'item_name': itemName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}
