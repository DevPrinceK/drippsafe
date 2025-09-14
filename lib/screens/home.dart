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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(.55),
              Colors.black.withOpacity(.15),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          border: Border.all(color: Colors.white.withOpacity(.12), width: 1),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8 + 6),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home,
                label: 'Home',
                active: currentIndex == 0,
                onTap: () => _onNavTap(0),
              ),
              _NavItem(
                icon: Icons.tips_and_updates,
                label: 'Tips',
                active: currentIndex == 1,
                onTap: () => _onNavTap(1),
              ),
              _NavItem(
                icon: Icons.favorite_rounded,
                label: 'Favorites',
                active: currentIndex == 2,
                onTap: () => _onNavTap(2),
              ),
              _NavItem(
                icon: Icons.settings,
                label: 'Settings',
                active: currentIndex == 3,
                onTap: () => _onNavTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => currentIndex = index);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem(
      {required this.icon,
      required this.label,
      required this.active,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : Colors.white70;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .3)),
          ],
        ),
      ),
    );
  }
}
