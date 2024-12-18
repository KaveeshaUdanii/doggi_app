import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

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
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
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
                child: const Icon(Icons.tune_rounded),
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
                      color: isSelected ? const Color(0xFFEDD9ED) : const Color(0xFFE5E0FF),
                      borderRadius: BorderRadius.circular(45),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          category['icon'],
                          color: isSelected ? const Color(0xFF8EA7E9) : const Color(0xFF7286D3),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category['name'],
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? const Color(0xFF8EA7E9) : const Color(0xFF7286D3),
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
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No products available'));
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
                  double Price = double.tryParse(priceString.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

                  return Product(
                    name: data['F_Name'] ?? 'No Name',
                    subtitle: data['Description'] ?? 'No Subtitle',
                    price: Price,
                    reviews: (data['reviews'] ?? 0).toDouble(),
                    imageUrl: data['Image'] ?? '',
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
class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorited = false; // Track if the product is favorited

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }

  Future<void> _checkIfFavorited() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Check Firestore to see if the product is already favorited by this user
      final favoritesSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('uid', isEqualTo: user.uid)
          .where('product_name', isEqualTo: widget.product.name)
          .get();

      setState(() {
        isFavorited = favoritesSnapshot.docs.isNotEmpty; // Update the state based on the check
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (isFavorited) {
        // Remove from favorites
        final favoritesSnapshot = await FirebaseFirestore.instance
            .collection('favorites')
            .where('uid', isEqualTo: user.uid)
            .where('product_name', isEqualTo: widget.product.name)
            .get();

        for (var doc in favoritesSnapshot.docs) {
          await doc.reference.delete(); // Delete the favorite entry
        }
      } else {
        // Add to favorites
        final foodSnapshot = await FirebaseFirestore.instance
            .collection('Food')
            .where('F_Name', isEqualTo: widget.product.name)
            .limit(1)
            .get();

        if (foodSnapshot.docs.isNotEmpty) {
          final foodDocId = foodSnapshot.docs.first.id;

          await FirebaseFirestore.instance.collection('favorites').add({
            'uid': user.uid,
            'product_name': widget.product.name,
            'food_doc_id': foodDocId,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }

      setState(() {
        isFavorited = !isFavorited;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image with favorite button
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.product.imageUrl,
                  fit: BoxFit.cover,
                  height: 100,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
                    return Container(
                      color: Colors.grey[300],
                      height: 95,
                      width: double.infinity,
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Product name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              widget.product.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          // Product subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              widget.product.subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          // Product price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Rs. ${widget.product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.1),
            child: ElevatedButton.icon(
              onPressed: () async {
                await addToCart(
                  widget.product.name,
                  widget.product.price,
                  widget.product.imageUrl,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item added successfully!')),
                );
              },
              icon: const Icon(Icons.shopping_cart, size: 16),
              label: const Text('Add to Cart', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(32),
                padding: EdgeInsets.zero,
                backgroundColor: const Color(0xFFE5E0FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addToCart(String fName, double price, String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Fetch the food document ID using the food name (assuming it’s unique)
        final foodSnapshot = await FirebaseFirestore.instance
            .collection('Food')
            .where('F_Name', isEqualTo: fName)
            .limit(1)
            .get();

        if (foodSnapshot.docs.isNotEmpty) {
          final foodDocId = foodSnapshot.docs.first.id; // Get the document ID

          // Save to Firestore in 'cart' collection with default quantity of 1
          await FirebaseFirestore.instance.collection('cart').add({
            'uid': user.uid,
            'F_name': fName,
            'price': price,
            'Image': imageUrl,
            'food_doc_id': foodDocId,
            'quantity': 1,
            'timestamp': FieldValue.serverTimestamp(),
          }).then((value) {
            print("Item added to cart with ID: ${value.id}");
          }).catchError((error) {
            print("Failed to add item to cart: $error");
          });
        } else {
          print("No food document found with name: $fName");
        }
      } catch (e) {
        print("Error adding to cart: $e");
      }
    } else {
      print("User is not signed in");
    }
  }





}
