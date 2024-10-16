import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isMenuOpen = false;

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
          icon: const Icon(Icons.menu, size: 35,color:Color(0xFFE5E0FF),),
          onPressed: toggleMenu,
        ),
        title: const Text(
          "DOGGI",
          style: TextStyle(fontSize: 20,color:Color(0xFFE5E0FF),), // Increase the font size of the title
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_rounded, size: 35, color:Color(0xFFE5E0FF),),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          Center(
            child: Text(
              "Welcome to DOGGI",
              style: TextStyle(fontSize: 28, color: const Color(0xFF7286D3)),
            ),
          ),

          // Animated Menu
          Positioned(
            left: 0,
            top: 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-250 * (1 - _controller.value), 0),
                  child: Menu(controller: _controller), // Pass controller to Menu
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Menu extends StatelessWidget {
  final AnimationController controller;

  Menu({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: MediaQuery.of(context).size.height,
      color: const Color(0xFF8EA7E9), // Background color for the menu
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
      position: Tween<Offset>(
        begin: const Offset(-1, 0), // Start off-screen
        end: Offset.zero, // End at original position
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.1 * index, // Stagger each item
          1.0,
          curve: Curves.easeIn,
        ),
      )),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFE5E0FF)), // Icon color
        title: Text(
          title,
          style: const TextStyle(color: Color(0xFFF2F2F2), fontSize: 18), // Text color
        ),
        onTap: () {
          // Handle menu item tap here
        },
      ),
    );
  }
}

//
// class Curvebar extends StatefulWidget {
//   const Curvebar({super.key});
//
//   @override
//   State<Curvebar> createState() => _CurvebarState();
// }
//
// class _CurvebarState extends State<Curvebar> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       appBar: AppBar(
//         title: const Text(data),
//       ),
//     );
//   }
// }
