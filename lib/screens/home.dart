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

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TipScreen(),
    const FavouritScreen(),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[currentIndex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
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
}
