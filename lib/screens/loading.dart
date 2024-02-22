// ignore_for_file: use_build_context_synchronously
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:drippsafe/screens/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String loadingName = '';

  void getLoadingName() {
    // hive db
    var mybox = Hive.box('drippsafe_db');
    // get the name from the box
    var settings = mybox.get('settings') ?? {};
    try {
      var lname = settings['name'];
      if (lname != null) {
        setState(() {
          loadingName = lname;
        });
      }
    } catch (e) {
      setState(() {
        loadingName = 'Afia Kyeremaah-Yeboah';
      });
    }
    setState(() {
      loadingName = settings['loadingName'] ?? 'Afia Kyeremaah-Yeboah';
    });
  }

  @override
  void initState() {
    super.initState();
    // get the loading name
    getLoadingName();
    // navigate after 5 seconds of loading
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
        SizedBox(
          child: Center(
            child: DefaultTextStyle(
              style: const TextStyle(
                fontSize: 30.0,
                fontFamily: 'Bobbers',
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    loadingName,
                  ),
                ],
              ),
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
