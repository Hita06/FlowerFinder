import 'package:flutter/material.dart';

import 'theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.onOpenScanner,
    this.onOpenWateringReminders,
    this.onOpenRecentlyIdentified,
  });

  final VoidCallback? onOpenScanner;
  final VoidCallback? onOpenWateringReminders;
  final VoidCallback? onOpenRecentlyIdentified;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8faf7),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Flower Finder'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Welcome section.
          Text(
            'Welcome to Flower Finder 🌱',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),

          const SizedBox(height: 8),

          Text(
            'Discover, identify and care for your flowers.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          // Weather.
          _SectionTitle(
            title: 'Weather',
          ),

          const SizedBox(height: 10),

          _WeatherCard(),

          const SizedBox(height: 24),

          // Watering reminders.
          _SectionTitle(
            title: 'Plant Care',
          ),

          const SizedBox(height: 10),

          _ShortcutCard(
            icon: Icons.water_drop_outlined,
            title: 'Watering Reminders',
            subtitle: 'Check which plants need watering.',
            onTap: onOpenWateringReminders,
          ),

          const SizedBox(height: 24),

          // Scanner shortcut.
          _SectionTitle(
            title: 'Identify a Flower',
          ),

          const SizedBox(height: 10),

          _ShortcutCard(
            icon: Icons.camera_alt_outlined,
            title: 'Scan a Flower',
            subtitle: 'Take a photo to identify a flower.',
            onTap: onOpenScanner,
          ),

          const SizedBox(height: 24),

          // Recently identified shortcut.
          _SectionTitle(
            title: 'Recently Identified',
          ),

          const SizedBox(height: 10),

          _ShortcutCard(
            icon: Icons.history,
            title: 'Recently Identified Flowers',
            subtitle: 'View flowers you have identified recently.',
            onTap: onOpenRecentlyIdentified,
          ),

          const SizedBox(height: 24),

          // Flower of the day.
          _SectionTitle(
            title: 'Flower of the Day',
          ),

          const SizedBox(height: 10),

          _FlowerOfTheDayCard(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}