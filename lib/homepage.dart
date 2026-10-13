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
      appBar: AppBar(centerTitle: true, title: const Text('Flower Finder')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Welcome to Flower Finder 🌱',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Discover, identify and care for your flowers.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          const _SectionTitle(title: 'Weather'),
          const SizedBox(height: 10),
          const _WeatherCard(),

          const SizedBox(height: 24),
          const _SectionTitle(title: 'Plant Care'),
          const SizedBox(height: 10),
          _ShortcutCard(
            icon: Icons.water_drop_outlined,
            title: 'Watering Reminders',
            subtitle: 'Check which plants need watering.',
            onTap: onOpenWateringReminders,
          ),

          const SizedBox(height: 24),
          const _SectionTitle(title: 'Identify a Flower'),
          const SizedBox(height: 10),
          _ShortcutCard(
            icon: Icons.camera_alt_outlined,
            title: 'Scan a Flower',
            subtitle: 'Take a photo to identify a flower.',
            onTap: onOpenScanner,
          ),

          const SizedBox(height: 24),
          const _SectionTitle(title: 'Recently Identified'),
          const SizedBox(height: 10),
          _ShortcutCard(
            icon: Icons.history,
            title: 'Recently Identified Flowers',
            subtitle: 'View flowers you have identified recently.',
            onTap: onOpenRecentlyIdentified,
          ),

          const SizedBox(height: 24),
          const _SectionTitle(title: 'Flower of the Day'),
          const SizedBox(height: 10),
          const _FlowerOfTheDayCard(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_outlined, color: AppColors.green, size: 42),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('18°C', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Partly cloudy',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Good conditions for exploring flowers.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.green, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlowerOfTheDayCard extends StatelessWidget {
  const _FlowerOfTheDayCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_florist,
              size: 50,
              color: AppColors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rose', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'Roses are widely recognised flowering plants.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
