import 'package:flutter/material.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF4),
      appBar: AppBar(
        title: const Text(
          'My Diary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3F6B45),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          Text(
            'Flower Memories',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF294D32),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Keep track of the flowers you discover and record your observations.',
            style: TextStyle(fontSize: 16, color: Color(0xFF5F6F63)),
          ),
          SizedBox(height: 24),
          DiaryEntryCard(
            flowerName: 'Purple Orchid',
            details: 'Discovered near campus',
            date: '14 September 2026',
            iconColor: Color(0xFF8E6AAE),
          ),
          SizedBox(height: 12),
          DiaryEntryCard(
            flowerName: 'Sunflower',
            details: 'Found beside the community garden',
            date: '12 September 2026',
            iconColor: Color(0xFFE0A52B),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add diary entry selected')),
          );
        },
        backgroundColor: const Color(0xFF3F6B45),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }
}

class DiaryEntryCard extends StatelessWidget {
  const DiaryEntryCard({
    super.key,
    required this.flowerName,
    required this.details,
    required this.date,
    required this.iconColor,
  });

  final String flowerName;
  final String details;
  final String date;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: Icon(Icons.local_florist, color: iconColor),
        ),
        title: Text(
          flowerName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF294D32),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '$details\n$date',
            style: const TextStyle(color: Color(0xFF5F6F63)),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF3F6B45)),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$flowerName selected')));
        },
      ),
    );
  }
}
