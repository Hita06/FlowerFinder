import 'package:flutter/material.dart';

class DiaryEntry {
  DiaryEntry({
    required this.flowerName,
    required this.location,
    required this.notes,
    required this.date,
  });

  String flowerName;
  String location;
  String notes;
  DateTime date;
}

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<DiaryEntry> _entries = [
    DiaryEntry(
      flowerName: 'Purple Orchid',
      location: 'Near campus',
      notes: 'A bright purple orchid growing beside the walking path.',
      date: DateTime(2026, 9, 14),
    ),
    DiaryEntry(
      flowerName: 'Sunflower',
      location: 'Community garden',
      notes: 'A tall sunflower facing towards the afternoon sunlight.',
      date: DateTime(2026, 9, 12),
    ),
  ];

  String _searchText = '';

  List<DiaryEntry> get _filteredEntries {
    if (_searchText.trim().isEmpty) {
      return _entries;
    }

    final query = _searchText.toLowerCase();

    return _entries.where((entry) {
      return entry.flowerName.toLowerCase().contains(query) ||
          entry.location.toLowerCase().contains(query) ||
          entry.notes.toLowerCase().contains(query);
    }).toList();
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _showEntryForm({DiaryEntry? existingEntry}) async {
    final flowerNameController = TextEditingController(
      text: existingEntry?.flowerName ?? '',
    );

    final locationController = TextEditingController(
      text: existingEntry?.location ?? '',
    );

    final notesController = TextEditingController(
      text: existingEntry?.notes ?? '',
    );

    final formKey = GlobalKey<FormState>();

    final shouldSave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            existingEntry == null ? 'Add Diary Entry' : 'Edit Diary Entry',
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: flowerNameController,
                      autofocus: existingEntry == null,
                      decoration: const InputDecoration(
                        labelText: 'Flower name',
                        prefixIcon: Icon(Icons.local_florist),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a flower name';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a location';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final formIsValid = formKey.currentState?.validate() ?? false;

                if (formIsValid) {
                  Navigator.pop(dialogContext, true);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3F6B45),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (shouldSave != true || !mounted) {
      return;
    }

    final flowerName = flowerNameController.text.trim();
    final location = locationController.text.trim();
    final notes = notesController.text.trim();

    setState(() {
      if (existingEntry == null) {
        _entries.insert(
          0,
          DiaryEntry(
            flowerName: flowerName,
            location: location,
            notes: notes,
            date: DateTime.now(),
          ),
        );
      } else {
        existingEntry.flowerName = flowerName;
        existingEntry.location = location;
        existingEntry.notes = notes;
      }
    });

    final message = existingEntry == null
        ? 'Diary entry added'
        : 'Diary entry updated';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteEntry(DiaryEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete diary entry?'),
          content: Text('Are you sure you want to delete ${entry.flowerName}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    setState(() {
      _entries.remove(entry);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Diary entry deleted')));
  }

  Future<void> _showEntryDetails(DiaryEntry entry) async {
    final shouldEdit = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(entry.flowerName),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.local_florist,
                    size: 64,
                    color: Color(0xFF3F6B45),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Location: ${entry.location}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text('Date: ${_formatDate(entry.date)}'),
                const SizedBox(height: 16),
                const Text(
                  'Observations',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.notes.isEmpty
                      ? 'No observations were recorded.'
                      : entry.notes,
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );

    if (shouldEdit == true && mounted) {
      await _showEntryForm(existingEntry: entry);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleEntries = _filteredEntries;

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Flower Memories',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF294D32),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Keep track of the flowers you discover and record your observations.',
                style: TextStyle(fontSize: 16, color: Color(0xFF5F6F63)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search diary entries',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchText.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();

                            setState(() {
                              _searchText = '';
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${visibleEntries.length} '
                '${visibleEntries.length == 1 ? 'entry' : 'entries'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5F6F63),
                ),
              ),
              const SizedBox(height: 12),
              if (visibleEntries.isEmpty)
                const _EmptyDiaryMessage()
              else
                ...visibleEntries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DiaryEntryCard(
                      flowerName: entry.flowerName,
                      location: entry.location,
                      date: _formatDate(entry.date),
                      onTap: () {
                        _showEntryDetails(entry);
                      },
                      onEdit: () {
                        _showEntryForm(existingEntry: entry);
                      },
                      onDelete: () {
                        _deleteEntry(entry);
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showEntryForm();
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
    required this.location,
    required this.date,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final String flowerName;
  final String location;
  final String date;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        leading: const CircleAvatar(
          radius: 26,
          backgroundColor: Color(0xFFE4F0E4),
          child: Icon(Icons.local_florist, color: Color(0xFF3F6B45)),
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
            '$location\n$date',
            style: const TextStyle(height: 1.5, color: Color(0xFF5F6F63)),
          ),
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'Diary entry options',
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Delete'),
                  ],
                ),
              ),
            ];
          },
        ),
      ),
    );
  }
}

class _EmptyDiaryMessage extends StatelessWidget {
  const _EmptyDiaryMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.menu_book_outlined, size: 70, color: Color(0xFF8AA18D)),
          SizedBox(height: 16),
          Text(
            'No diary entries found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF294D32),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add a new flower memory or try another search.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF5F6F63)),
          ),
        ],
      ),
    );
  }
}
