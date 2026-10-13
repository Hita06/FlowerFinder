import 'package:flutter/material.dart';

class DiaryEntry {
  DiaryEntry({
    required this.flowerName,
    required this.location,
    required this.notes,
    required this.date,
    required this.sticker,
  });

  String flowerName;
  String location;
  String notes;
  DateTime date;
  String sticker;
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
      sticker: '🌸',
    ),
    DiaryEntry(
      flowerName: 'Sunflower',
      location: 'Community garden',
      notes: 'A tall sunflower facing towards the afternoon sunlight.',
      date: DateTime(2026, 9, 12),
      sticker: '🌻',
    ),
  ];

  String _searchText = '';
  String _sortOption = 'Newest';

  List<DiaryEntry> get _filteredEntries {
    if (_searchText.trim().isEmpty) {
      return _entries;
    }

    final query = _searchText.trim().toLowerCase();

    return _entries.where((entry) {
      return entry.flowerName.toLowerCase().contains(query) ||
          entry.location.toLowerCase().contains(query) ||
          entry.notes.toLowerCase().contains(query) ||
          entry.sticker.contains(query);
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
    String selectedSticker = existingEntry?.sticker ?? '🌸';

    final result = await showDialog<_DiaryFormResult>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
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
                          maxLength: 300,
                          decoration: const InputDecoration(
                            labelText: 'Diary entry or observations',
                            prefixIcon: Icon(Icons.notes),
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                            hintText:
                                'Write something about this flower memory.',
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: selectedSticker,
                          decoration: const InputDecoration(
                            labelText: 'Choose a sticker',
                            prefixIcon: Icon(Icons.emoji_emotions_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: '🌸',
                              child: Text('🌸 Blossom'),
                            ),
                            DropdownMenuItem(
                              value: '🌻',
                              child: Text('🌻 Sunflower'),
                            ),
                            DropdownMenuItem(
                              value: '🌹',
                              child: Text('🌹 Rose'),
                            ),
                            DropdownMenuItem(
                              value: '🌼',
                              child: Text('🌼 Daisy'),
                            ),
                            DropdownMenuItem(
                              value: '🌷',
                              child: Text('🌷 Tulip'),
                            ),
                            DropdownMenuItem(
                              value: '🪻',
                              child: Text('🪻 Hyacinth'),
                            ),
                            DropdownMenuItem(
                              value: '🍀',
                              child: Text('🍀 Lucky leaf'),
                            ),
                            DropdownMenuItem(
                              value: '🦋',
                              child: Text('🦋 Butterfly'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedSticker = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7EF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFC8DDC8)),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Sticker preview',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5F6F63),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                selectedSticker,
                                style: const TextStyle(fontSize: 48),
                              ),
                            ],
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
                    flowerNameController.clear();
                    locationController.clear();
                    notesController.clear();

                    setDialogState(() {
                      selectedSticker = '🌸';
                    });
                  },
                  child: const Text('Clear'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final formIsValid =
                        formKey.currentState?.validate() ?? false;

                    if (!formIsValid) {
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      _DiaryFormResult(
                        flowerName: flowerNameController.text.trim(),
                        location: locationController.text.trim(),
                        notes: notesController.text.trim(),
                        sticker: selectedSticker,
                      ),
                    );
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
      },
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      if (existingEntry == null) {
        _entries.insert(
          0,
          DiaryEntry(
            flowerName: result.flowerName,
            location: result.location,
            notes: result.notes,
            date: DateTime.now(),
            sticker: result.sticker,
          ),
        );
      } else {
        existingEntry.flowerName = result.flowerName;
        existingEntry.location = result.location;
        existingEntry.notes = result.notes;
        existingEntry.sticker = result.sticker;
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

    final deletedIndex = _entries.indexOf(entry);

    setState(() {
      _entries.remove(entry);
    });

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${entry.flowerName} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            if (!mounted) {
              return;
            }

            setState(() {
              final restoreIndex = deletedIndex.clamp(0, _entries.length);

              _entries.insert(restoreIndex, entry);
            });
          },
        ),
      ),
    );
  }

  Future<void> _showEntryDetails(DiaryEntry entry) async {
    final shouldEdit = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Text(entry.sticker, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(child: Text(entry.flowerName)),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE4F0E4),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      entry.sticker,
                      style: const TextStyle(fontSize: 58),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Location: ${entry.location}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text('Date: ${_formatDate(entry.date)}'),
                const SizedBox(height: 16),
                const Text(
                  'Diary entry',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.notes.isEmpty
                      ? 'No diary notes were recorded.'
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
    final visibleEntries = List<DiaryEntry>.from(_filteredEntries);

    if (_sortOption == 'Newest') {
      visibleEntries.sort(
        (firstEntry, secondEntry) =>
            secondEntry.date.compareTo(firstEntry.date),
      );
    } else {
      visibleEntries.sort(
        (firstEntry, secondEntry) =>
            firstEntry.date.compareTo(secondEntry.date),
      );
    }

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
                'Write about flowers you discover and customize each memory with a sticker.',
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
              DropdownButtonFormField<String>(
                initialValue: _sortOption,
                decoration: const InputDecoration(
                  labelText: 'Sort entries',
                  prefixIcon: Icon(Icons.sort),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Newest',
                    child: Text('Newest first'),
                  ),
                  DropdownMenuItem(
                    value: 'Oldest',
                    child: Text('Oldest first'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortOption = value;
                    });
                  }
                },
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
                _EmptyDiaryMessage(isSearching: _searchText.trim().isNotEmpty)
              else
                ...visibleEntries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DiaryEntryCard(
                      flowerName: entry.flowerName,
                      location: entry.location,
                      date: _formatDate(entry.date),
                      sticker: entry.sticker,
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
        tooltip: 'Create a new diary entry',
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }
}

class _DiaryFormResult {
  const _DiaryFormResult({
    required this.flowerName,
    required this.location,
    required this.notes,
    required this.sticker,
  });

  final String flowerName;
  final String location;
  final String notes;
  final String sticker;
}

class DiaryEntryCard extends StatelessWidget {
  const DiaryEntryCard({
    super.key,
    required this.flowerName,
    required this.location,
    required this.date,
    required this.sticker,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final String flowerName;
  final String location;
  final String date;
  final String sticker;
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
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFE4F0E4),
          child: Text(sticker, style: const TextStyle(fontSize: 28)),
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
  const _EmptyDiaryMessage({required this.isSearching});

  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    final title = isSearching
        ? 'No matching diary entries'
        : 'Start your flower diary';

    final message = isSearching
        ? 'Try another flower name, location, note, or sticker.'
        : 'Add your first entry to begin recording flower memories.';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(
            Icons.menu_book_outlined,
            size: 70,
            color: Color(0xFF8AA18D),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF294D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF5F6F63)),
          ),
        ],
      ),
    );
  }
}
