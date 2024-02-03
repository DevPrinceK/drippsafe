// ignore_for_file: use_build_context_synchronously

import 'package:drippsafe/screens/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Call a function to navigate after 3 seconds
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for 3 seconds
    await Future.delayed(const Duration(seconds: 5));

    // Navigate to onboarding screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            'd r i p p s a f e',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.pink[900],
            ),
          ),
        ),
        const SizedBox(height: 20),
        CircularProgressIndicator(
          color: Colors.pink[900],
        ),
      ],
    ));
  }
}