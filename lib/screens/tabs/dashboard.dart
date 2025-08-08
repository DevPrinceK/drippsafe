import 'package:drippsafe/providers/settings_provider.dart';
import 'package:drippsafe/screens/constants/widgets/info_rect.dart';
import 'package:drippsafe/screens/constants/widgets/infocircle.dart';
import 'package:drippsafe/screens/constants/widgets/infocard.dart';
import 'package:drippsafe/screens/constants/widgets/tipcard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = context.read<SettingsProvider>();
      if (!settingsProvider.isConfigured) {
        _showSetupReminder();
      }
    });
  }

  void _showSetupReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please configure your app in Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to settings
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DrippSafe'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = settingsProvider.settings;
          final now = DateTime.now();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(settings),

                const SizedBox(height: 24),

                // Quick Stats
                _buildQuickStats(now),

                const SizedBox(height: 24),

                // Color Legend
                _buildColorLegend(),

                const SizedBox(height: 24),

                // Calendar Section
                _buildCalendarSection(settingsProvider, now),

                const SizedBox(height: 24),

                // Tips Section
                _buildTipsSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(UserSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${settings.name.isNotEmpty ? settings.name : 'User'}!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your cycle with confidence',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(DateTime now) {
    return Row(
      children: [
        Expanded(
          child: InfoCard(
            title: 'Year',
            value: DateFormat('yyyy').format(now),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InfoCard(
            title: 'Month',
            value: DateFormat('MM').format(now),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InfoCard(
            title: 'Day',
            value: DateFormat('dd').format(now),
          ),
        ),
      ],
    );
  }

  Widget _buildColorLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendar Legend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InfoRect(
                  title: 'Period',
                  color: Theme.of(context).colorScheme.primary,
                ),
                InfoRect(
                  title: 'Ovulation',
                  color: Colors.green,
                ),
                InfoRect(
                  title: 'Safe',
                  color: Colors.grey[300],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection(
      SettingsProvider settingsProvider, DateTime now) {
    final currentMonth = DateFormat('MMMM yyyy').format(now);
    final currentDay = now.day;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentMonth,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '$currentDay - ${(currentDay + 6).clamp(1, daysInMonth)} $currentMonth',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildCalendarGrid(settingsProvider, now),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(SettingsProvider settingsProvider, DateTime now) {
    final days = <Widget>[];
    final startDay = now.day;
    final endDay = (startDay + 6).clamp(1, 31);

    for (int day = startDay; day <= endDay; day++) {
      final date = DateTime(now.year, now.month, day);
      final isPeriod = settingsProvider.isPeriodDay(date);
      final isOvulation = settingsProvider.isOvulationDay(date);
      final isSafe = settingsProvider.isSafeDay(date);

      Color circleColor;
      if (isPeriod) {
        circleColor = Theme.of(context).colorScheme.primary;
      } else if (isOvulation) {
        circleColor = Colors.green;
      } else {
        circleColor = Colors.grey[300]!;
      }

      days.add(
        Expanded(
          child: InfoCircle(
            day: day.toString(),
            color: circleColor,
          ),
        ),
      );
    }

    return Row(children: days);
  }

  Widget _buildTipsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Tips',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TipCard(
              title: 'Stay Hydrated',
              description: 'Drink plenty of water throughout the day',
              icon: Icons.water_drop,
            ),
            const SizedBox(height: 12),
            TipCard(
              title: 'Exercise Regularly',
              description: 'Light exercise can help with period symptoms',
              icon: Icons.fitness_center,
            ),
          ],
        ),
      ),
    );
  }
}
