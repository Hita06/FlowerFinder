
import 'package:flutter/material.dart';
import 'weather_service.dart';
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

  String _getGreeting(String name) {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good morning $name! 🌞';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon $name! 🌷';
    } else {
      return 'Good evening $name! 🌙';
    }
  }

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
          Text(
            _getGreeting('there'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to explore, discover new blooms, '
            'and help your flowers thrive? 🌿',
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
            onTap: null,
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
            onTap: null, // Replace with onOpenRecentlyIdentified when implemented
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
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _WeatherCard extends StatefulWidget {
  const _WeatherCard();

  @override
  State<_WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<_WeatherCard> {
  late Future<WeatherData> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = WeatherService.fetchCurrentWeather();
  }

  Future<void> _refreshWeather() async {
    setState(() {
      _weatherFuture = WeatherService.fetchCurrentWeather();
    });

    try {
      await _weatherFuture;
    } catch (_) {
      // The FutureBuilder below displays the error and retry option.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: FutureBuilder<WeatherData>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          final isLoading =
              snapshot.connectionState == ConnectionState.waiting;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Auckland, New Zealand',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh weather',
                    onPressed: isLoading ? null : _refreshWeather,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (snapshot.hasError || !snapshot.hasData)
                _buildError(context)
              else
                _buildWeather(context, snapshot.data!),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeather(BuildContext context, WeatherData weather) {
    final formattedTime =
        '${weather.time.hour.toString().padLeft(2, '0')}:'
        '${weather.time.minute.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              weather.emoji,
              style: const TextStyle(fontSize: 38),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.round()}°C',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Current weather · Updated at $formattedTime',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Weather data by Open-Meteo',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.cloud_off_outlined,
          color: AppColors.green,
          size: 36,
        ),
        const SizedBox(height: 8),
        Text(
          'Weather is currently unavailable.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Check your internet connection and try again.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _refreshWeather,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ),
      ],
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
                child: Icon(
                  icon,
                  color: AppColors.green,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
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
                Text(
                  'Rose',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
