// ignore_for_file: use_build_context_synchronously
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:drippsafe/providers/settings_provider.dart';
import 'package:drippsafe/screens/home.dart';
import 'package:drippsafe/screens/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _startAnimations();
    _loadSettingsAndNavigate();
  }

  void _startAnimations() {
    _fadeController.forward();
    _scaleController.forward();
  }

  Future<void> _loadSettingsAndNavigate() async {
    final settingsProvider = context.read<SettingsProvider>();
    await settingsProvider.loadSettings();

    // Wait for animations to complete
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final isConfigured = settingsProvider.isConfigured;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            isConfigured ? const HomeScreen() : OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Title
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'd r i p p s a f e',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Loading Name
            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, child) {
                final loadingName = settingsProvider.settings.loadingName;

                return DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        loadingName,
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Loading Indicator
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Loading Text
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Loading your safe space...',
                style: TextStyle(
                  fontSize: 14,
                                   color: Theme.of(context)
                     .colorScheme
                     .onSurface
                     .withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
