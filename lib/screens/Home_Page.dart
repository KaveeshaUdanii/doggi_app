import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:doggi_app/screens/Home/HomeContent.dart';
import 'package:doggi_app/screens/Cart/CartContent.dart';
import 'package:doggi_app/screens/Instructions/StoriesContent.dart';
import 'package:doggi_app/screens/Favourite/FavoritesContent.dart';
import 'package:doggi_app/screens/Account/AccountContent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isMenuOpen = false;
  int _currentIndex = 0; // Keeps track of the selected index for navigation

  final items = [
    const Icon(Icons.home, size: 35, color: Color(0xFFE5E0FF)),
    const Icon(Icons.add_shopping_cart, size: 35, color: Color(0xFFE5E0FF)),
    const Icon(Icons.auto_stories_rounded, size: 35, color: Color(0xFFE5E0FF)),
    const Icon(Icons.favorite, size: 35, color: Color(0xFFE5E0FF)),
    const Icon(Icons.account_circle_rounded, size: 35, color: Color(0xFFE5E0FF)),
  ];

  // List of body content pages (separate classes for each section)
  final List<Widget> bodyPages = [
    const HomeContent(),
    const CartContent(),
    const StoriesContent(),
    const FavoritesContent(), // Ensure this is the correct FavoritesContent widget
    const AccountContent(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
      isMenuOpen ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7286D3), // Set AppBar color
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 35, color: Color(0xFFE5E0FF)),
          onPressed: toggleMenu,
        ),
        title: const Text(
          "DOGGI",
          style: TextStyle(fontSize: 20, color: Color(0xFFE5E0FF)),
        ),
      ),
      body: Stack(
        children: [
          // Main content that changes with bottom navigation
          bodyPages[_currentIndex], // Display the current page content

          // Animated Menu
          Positioned(
            left: 0,
            top: 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-250 * (1 - _controller.value), 0),
                  child: Menu(
                    controller: _controller,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index; // Update the index when a menu item is tapped
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        backgroundColor: Colors.transparent,
        color: const Color(0xFF7286D3),
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the index when the user taps a navigation icon
          });
        },
      ),
    );
  }
}

//-----------------------------------------------------------------------------------------------------------

// Side Menu Widget
class Menu extends StatelessWidget {
  final AnimationController controller;
  final Function(int) onTap; // Add onTap parameter to the constructor

  Menu({required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: MediaQuery.of(context).size.height,
      color: const Color(0xFF8EA7E9), // Background color for the menu
      child: Column(
        children: [
          // User profile photo
          Container(
            margin: const EdgeInsets.symmetric(vertical: 30.0), // Adds space above and below
            child: CircleAvatar(
              radius: 50, // Size of the avatar (you can adjust this)
              backgroundColor: Colors.white, // Background color for the circle
              backgroundImage: AssetImage('assets/user_profile.jpg'), // Add your image asset here
            ),
          ),
          // Menu items
          _buildStaggeredMenuItem(Icons.home, "Home", 0),
          _buildStaggeredMenuItem(Icons.favorite, "Favorite", 1),
          _buildStaggeredMenuItem(Icons.pets, "Dog Nutrition", 2),
          _buildStaggeredMenuItem(Icons.contact_page, "Contact Us", 3),
          _buildStaggeredMenuItem(Icons.exit_to_app, "Logout", 4),
        ],
      ),
    );
  }

  Widget _buildStaggeredMenuItem(IconData icon, String title, int index) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.1 * index, // Stagger each item
          1.0,
          curve: Curves.easeIn,
        ),
      )),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0), // Padding for the background around the icon
          decoration: const BoxDecoration(
            color: Color(0xFFE5E0FF), // Icon background color
            shape: BoxShape.circle,   // Makes the background circular
          ),
          child: Icon(icon, color: const Color(0xFF7286D3)), // Icon color
        ),
        title: Text(
          title,
          style: const TextStyle(color: Color(0xFFF2F2F2), fontSize: 18), // Text color
        ),
        onTap: () {
          onTap(index); // Pass the index to the onTap callback
        },
      ),
    );
  }
}
