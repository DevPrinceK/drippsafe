import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:drippsafe/screens/tabs/dashboard.dart';
import 'package:drippsafe/screens/tabs/favourites.dart';
import 'package:drippsafe/screens/tabs/settings.dart';
import 'package:drippsafe/screens/tabs/tips.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // dynamic body
      body: _buildBody(currentIndex),

      // bottom navigation bar
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.pink[900],
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.tips_and_updates, title: 'Tips'),
          TabItem(icon: Icons.favorite_rounded, title: 'Favorites'),
          TabItem(icon: Icons.settings, title: 'Settings'),
        ],
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }

  // build screen
  Widget _buildBody(currentIndex) {
    switch (currentIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const TipScreen();
      case 2:
        return const FavouritScreen();
      case 3:
        return const SettingScreen();
      default:
        return const DashboardScreen();
    }
  }
}
