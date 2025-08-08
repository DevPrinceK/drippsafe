import 'package:drippsafe/providers/settings_provider.dart';
import 'package:drippsafe/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:intro_screen_onboarding_flutter/introduction.dart';
import 'package:intro_screen_onboarding_flutter/introscreenonboarding.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  final List<Introduction> list = const [
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
      backgroudColor: Theme.of(context).colorScheme.background,
      foregroundColor: Theme.of(context).colorScheme.primary,
      introductionList: list,
      onTapSkipButton: () => _navigateToHome(context),
      skipTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
        fontSize: 18,
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
      (route) => false,
    );
  }
}
