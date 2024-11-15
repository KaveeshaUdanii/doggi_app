import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doggi_app/screens/Home/HomeContent.dart';
import 'package:doggi_app/screens/Cart/CartContent.dart';
import 'package:doggi_app/screens/Instructions/StoriesContent.dart';
import 'package:doggi_app/screens/Favourite/FavoritesContent.dart';
import '../auth/login_page.dart';
import 'Account/AccountContent.dart';
import 'Home/ContactUsPage.dart';
import 'Home/PromotionsPage.dart';
import 'Account/MyOrders.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isMenuOpen = false;
  int _currentIndex = 0;

  final items = [
    const Icon(Icons.home, size: 35, color: Color(0xFFE5E0FF)),
    const Icon(Icons.add_shopping_cart, size: 35, color: Color(0xFFE5E0FF)),
    const Icon(Icons.auto_stories_rounded, size: 35, color: Color(0xFFE5E0FF)),
    const Icon(Icons.favorite, size: 35, color: Color(0xFFE5E0FF)),
    const Icon(Icons.account_circle_rounded, size: 35, color: Color(0xFFE5E0FF)),
  ];

  final List<Widget> bodyPages = [
    const HomeContent(),
    const CartContent(),
    const StoriesContent(),
    const FavoritesContent(),
    //const AccountContent(),
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
        backgroundColor: const Color(0xFF7286D3),
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
          bodyPages[_currentIndex],
          Positioned(
            left: 0,
            top: 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-250 * (1 - _controller.value), 0),
                  child: Menu(controller: _controller),
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
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Side Menu Widget
class Menu extends StatelessWidget {
  final AnimationController controller;

  const Menu({super.key, required this.controller});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully logged out")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: MediaQuery.of(context).size.height,
      color: const Color(0xFF8EA7E9),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 30.0),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/user_profile.jpg'),
            ),
          ),
          _buildStaggeredMenuItem(context, Icons.account_circle_rounded, "My Profile", 0),
          _buildStaggeredMenuItem(context, Icons.shopping_bag_outlined, "My Orders", 1),
          _buildStaggeredMenuItem(context, Icons.discount, "Promotions", 2),
          _buildStaggeredMenuItem(context, Icons.contact_page, "Contact Us", 3),
          _buildStaggeredMenuItem(context, Icons.exit_to_app, "Logout", 4),
        ],
      ),
    );
  }

  Widget _buildStaggeredMenuItem(BuildContext context, IconData icon, String title, int index) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.1 * index,
          1.0,
          curve: Curves.easeIn,
        ),
      )),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Color(0xFFE5E0FF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF7286D3)),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Color(0xFFF2F2F2), fontSize: 18),
        ),
        onTap: () {
          if (title == "My Orders") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyOrders()),
            );
          } else if (title == "Promotions") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PromotionsPage()),
            );
          } else if (title == "Contact Us") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactUsPage()),
            );
          } else if (title == "Logout") {
            _logout(context);
          } else if (title == "My Profile") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountContent()),
            );
          }
        },
      ),
    );
  }
}
