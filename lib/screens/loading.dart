// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:math';

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
  late AnimationController _mainController; // master timeline 0..1
  late AnimationController _bgController; // looping subtle gradient

  // Alignments for the two words moving toward center
  late Animation<Alignment> _drippAlign;
  late Animation<Alignment> _safeAlign;
  late Animation<double> _drippOpacity;
  late Animation<double> _safeOpacity;
  late Animation<double> _drippSafeOpacity;
  late Animation<double> _drippSafeScale;
  late List<_SparkleSpec> _sparkles;
  late Animation<double> _sparkleMaster;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 4200),
      vsync: this,
    );

    _bgController = AnimationController(
      duration: const Duration(seconds: 14),
      vsync: this,
    )..repeat(reverse: true);

    // Dripp enters (0.0 - 0.38), Safe enters (0.0 - 0.38) from opposite corners
    _drippAlign = AlignmentTween(
      begin: const Alignment(-1.2, -1.2), // off top-left
      end: Alignment.center,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(.0, .40, curve: Curves.easeOutCubic),
    ));

    _safeAlign = AlignmentTween(
      begin: const Alignment(1.3, 1.3), // off bottom-right
      end: Alignment.center,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(.05, .45, curve: Curves.easeOutCubic),
    ));

    _drippOpacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(.0, .25, curve: Curves.easeOut),
    ));
    _safeOpacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(.07, .32, curve: Curves.easeOut),
    ));

    // Combined word appears after individual words converge (fade them out) (0.46 - 0.62)
    _drippSafeOpacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(.48, .66, curve: Curves.easeOutCubic),
    ));
    _drippSafeScale = Tween<double>(begin: .85, end: 1).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(.48, .72, curve: Curves.elasticOut),
    ));

    _sparkleMaster = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(.50, .90, curve: Curves.easeOutCubic),
    );
    _sparkles = _generateSparkles();

    _mainController.forward();
    _loadSettingsAndNavigate();
  }

  Future<void> _loadSettingsAndNavigate() async {
    final settingsProvider = context.read<SettingsProvider>();
    await settingsProvider.loadSettings();
    // Aim to navigate shortly after main animation (> 70%) ~ 3.1s
    await Future.delayed(const Duration(milliseconds: 3300));

    if (!mounted) return;

    final isConfigured = settingsProvider.isConfigured;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            isConfigured ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  List<_SparkleSpec> _generateSparkles() {
    final rand = Random();
    final List<_SparkleSpec> list = [];
    for (int i = 0; i < 14; i++) {
      final angle = (i / 14) * pi * 2 + rand.nextDouble() * .7;
      final radius = 32 + rand.nextDouble() * 44;
      final size = 4 + rand.nextDouble() * 7;
      final delay = rand.nextDouble() * .55; // fraction inside sparkle window
      list.add(_SparkleSpec(
        dx: cos(angle) * radius,
        dy: sin(angle) * radius,
        size: size,
        delay: delay,
        color: Colors.white.withOpacity(.75 + rand.nextDouble() * .25),
      ));
    }
    return list;
  }

  Widget _buildSparkles() {
    return AnimatedBuilder(
      animation: _sparkleMaster,
      builder: (_, __) {
        return Stack(
          children: [
            for (final s in _sparkles)
              _Sparkle(
                spec: s,
                progress: _sparkleMaster.value,
              )
          ],
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (_, __) {
        final showCombined = _drippSafeOpacity.value > 0;
        final hideIndividuals = _drippSafeOpacity.value > .15; // fade out early
        return SizedBox.expand(
          child: Stack(
            children: [
              // Dripp
              Align(
                alignment: _drippAlign.value,
                child: Opacity(
                  opacity: hideIndividuals
                      ? (1 - _drippSafeOpacity.value)
                      : _drippOpacity.value,
                  child: _WordShard(
                    text: 'Dripp',
                    baseColor: Colors.pink.shade300,
                    glowColor: Colors.pink.shade100,
                    fontSize: 42,
                  ),
                ),
              ),
              // Safe
              Align(
                alignment: _safeAlign.value,
                child: Opacity(
                  opacity: hideIndividuals
                      ? (1 - _drippSafeOpacity.value)
                      : _safeOpacity.value,
                  child: _WordShard(
                    text: 'Safe',
                    baseColor: Colors.indigo.shade200,
                    glowColor: Colors.indigo.shade50,
                    fontSize: 42,
                  ),
                ),
              ),
              // Combined
              if (showCombined)
                Align(
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: _drippSafeOpacity.value,
                    child: Transform.scale(
                      scale: _drippSafeScale.value,
                      child: _CombinedTitleGlow(
                        progress: _drippSafeOpacity.value,
                      ),
                    ),
                  ),
                ),
              if (showCombined) _buildSparkles(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) {
              final t = _bgController.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                          Colors.pink.shade900, Colors.deepPurple.shade800, t)!,
                      Color.lerp(
                          Colors.pink.shade400, Colors.indigo.shade500, 1 - t)!,
                    ],
                  ),
                ),
              );
            },
          ),
          // Subtle overlay noise / vignette (optional simple radial gradient)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.05,
                colors: [
                  Colors.white.withOpacity(.05),
                  Colors.black.withOpacity(.55),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
          // Title animation layer
          _buildAnimatedTitle(),
          // Bottom content (appears after ~70%)
          AnimatedBuilder(
            animation: _mainController,
            builder: (_, __) {
              final show = _mainController.value > .68;
              return IgnorePointer(
                ignoring: !show,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: show ? 1 : 0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 72.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, child) {
                              final loadingName =
                                  settingsProvider.settings.loadingName;
                              return DefaultTextStyle(
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                                child: AnimatedTextKit(
                                  animatedTexts: [
                                    TypewriterAnimatedText(
                                      loadingName,
                                      speed: const Duration(milliseconds: 95),
                                    ),
                                  ],
                                  totalRepeatCount: 1,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 34),
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Loading your safe space...',
                            style: TextStyle(
                              fontSize: 13.5,
                              letterSpacing: .3,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: .72),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WordShard extends StatelessWidget {
  final String text;
  final Color baseColor;
  final Color glowColor;
  final double fontSize;
  const _WordShard({
    required this.text,
    required this.baseColor,
    required this.glowColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withOpacity(.9),
          glowColor.withOpacity(.7),
        ],
      ).createShader(rect),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              color: glowColor.withOpacity(.6),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _CombinedTitleGlow extends StatelessWidget {
  final double progress; // 0..1 for glow intensity
  const _CombinedTitleGlow({required this.progress});

  @override
  Widget build(BuildContext context) {
    final base = Curves.easeOut.transform(progress.clamp(0, 1));
    final glow = 10 + 28 * base;
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          'DrippSafe',
          style: TextStyle(
            fontSize: 54,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  Color(0xFFF48FB1),
                  Color(0xFFB39DDB),
                  Color(0xFF90CAF9),
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 320, 80)),
            shadows: [
              Shadow(
                color: Colors.pinkAccent.withOpacity(.55),
                blurRadius: glow * .5,
              ),
              Shadow(
                color: Colors.deepPurpleAccent.withOpacity(.35),
                blurRadius: glow * .8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SparkleSpec {
  final double dx;
  final double dy;
  final double size;
  final double delay; // 0..1 relative inside sparkle window
  final Color color;
  _SparkleSpec({
    required this.dx,
    required this.dy,
    required this.size,
    required this.delay,
    required this.color,
  });
}

class _Sparkle extends StatelessWidget {
  final _SparkleSpec spec;
  final double progress; // master sparkle progress 0..1
  const _Sparkle({required this.spec, required this.progress});

  @override
  Widget build(BuildContext context) {
    double local = ((progress - spec.delay) / (1 - spec.delay)).clamp(0, 1);
    final appear = Curves.easeOutBack.transform(local);
    final opacity = (local < .1)
        ? local * 10
        : (local > .85)
            ? (1 - local) / .15
            : 1.0;
    return Positioned(
      left: MediaQuery.of(context).size.width / 2 + spec.dx,
      top: MediaQuery.of(context).size.height / 2 + spec.dy,
      child: Opacity(
        opacity: opacity.clamp(0, 1),
        child: Transform.scale(
          scale: .2 + .8 * appear,
          child: Container(
            width: spec.size,
            height: spec.size,
            decoration: BoxDecoration(
              color: spec.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: spec.color.withOpacity(.8),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
