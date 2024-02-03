import 'package:drippsafe/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:intro_screen_onboarding_flutter/introduction.dart';
import 'package:intro_screen_onboarding_flutter/introscreenonboarding.dart';

class OnboardingScreen extends StatelessWidget {
  final List<Introduction> list = [
    Introduction(
      title: 'Period Tracking',
      subTitle: 'Track your period and ovulation with ease and accuracy',
      imageUrl: 'assets/images/menstrual-1.png',
    ),
    Introduction(
      title: 'Personal Care',
      subTitle: 'Get personalized insights and health tips',
      imageUrl: 'assets/images/menstrual-2.png',
    ),
    Introduction(
      title: 'Portable Guide',
      subTitle: 'Get access to your period calendar anytime, anywhere',
      imageUrl: 'assets/images/menstrual-1.png',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return IntroScreenOnboarding(
      backgroudColor: const Color(0xFFf9f9f9),
      foregroundColor: Colors.pink[900],
      introductionList: list,
      onTapSkipButton: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (route) => false,
      ),
      skipTextStyle: const TextStyle(
        color: Colors.blueGrey,
        fontSize: 18,
      ),
    );
  }
}
