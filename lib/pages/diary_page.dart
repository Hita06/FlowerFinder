import 'package:flutter/material.dart';

const Color diaryMainGreen = Color(0xFF5BC68D);
const Color diaryDarkGreen = Color(0xFF276749);
const Color diaryCream = Color(0xFFFFF9F2);
const Color diaryLightGreen = Color(0xFFE4F3E8);
const Color diaryPinkAccent = Color(0xFFF7A8C4);
const Color diaryTextGrey = Color(0xFF68776D);
const Color diaryBorderGreen = Color(0xFFD5EDE0);

class DiaryEntry {
  DiaryEntry({
    required this.flowerName,
    required this.location,
    required this.notes,
    required this.date,
    required this.sticker,
    this.isFavorite = false,
  });

  String flowerName;
  String location;
  String notes;
  DateTime date;
  String sticker;
  bool isFavorite;
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
      isFavorite: true,
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
  bool _showFavoritesOnly = false;

  List<DiaryEntry> get _visibleEntries {
    Iterable<DiaryEntry> entries = _entries;

    if (_showFavoritesOnly) {
      entries = entries.where((entry) => entry.isFavorite);
    }

    final query = _searchText.trim().toLowerCase();

    if (query.isNotEmpty) {
      entries = entries.where((entry) {
        return entry.flowerName.toLowerCase().contains(query) ||
            entry.location.toLowerCase().contains(query) ||
            entry.notes.toLowerCase().contains(query) ||
            entry.sticker.contains(query);
      });
    }

    final visibleEntries = entries.toList();

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

    return visibleEntries;
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

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    String? hint,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: alignLabelWithHint,
      prefixIcon: Icon(icon, color: diaryDarkGreen),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: diaryBorderGreen, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: diaryMainGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade600),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade700, width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: diaryDarkGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _toggleFavorite(DiaryEntry entry) {
    setState(() {
      entry.isFavorite = !entry.isFavorite;
    });

    _showMessage(
      entry.isFavorite
          ? '${entry.flowerName} added to favourites'
          : '${entry.flowerName} removed from favourites',
    );
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
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: diaryCream,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: const BoxDecoration(
                      color: diaryLightGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      existingEntry == null
                          ? Icons.menu_book_outlined
                          : Icons.edit_outlined,
                      color: diaryDarkGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      existingEntry == null
                          ? 'Add Diary Entry'
                          : 'Edit Diary Entry',
                      style: const TextStyle(
                        color: diaryDarkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
                          textInputAction: TextInputAction.next,
                          decoration: _fieldDecoration(
                            label: 'Flower name',
                            icon: Icons.local_florist,
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
                          textInputAction: TextInputAction.next,
                          decoration: _fieldDecoration(
                            label: 'Location',
                            icon: Icons.location_on,
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
                          decoration: _fieldDecoration(
                            label: 'Diary entry or observations',
                            hint: 'Write something about this flower memory.',
                            icon: Icons.notes,
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: selectedSticker,
                          decoration: _fieldDecoration(
                            label: 'Choose a sticker',
                            icon: Icons.emoji_emotions_outlined,
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
                            if (value == null) {
                              return;
                            }

                            setDialogState(() {
                              selectedSticker = value;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: diaryLightGreen,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: diaryMainGreen),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Sticker preview',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: diaryDarkGreen,
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
                TextButton.icon(
                  onPressed: () {
                    flowerNameController.clear();
                    locationController.clear();
                    notesController.clear();

                    setDialogState(() {
                      selectedSticker = '🌸';
                    });
                  },
                  icon: const Icon(Icons.cleaning_services_outlined),
                  label: const Text('Clear'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    final isValid = formKey.currentState?.validate() ?? false;

                    if (!isValid) {
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
                    backgroundColor: diaryDarkGreen,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    // Do not dispose the three dialog controllers here.
    // Flutter may still be removing the dialog text fields.
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

    _showMessage(
      existingEntry == null ? 'Diary entry added' : 'Diary entry updated',
    );
  }

  Future<void> _deleteEntry(DiaryEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: diaryCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 10),
              Expanded(child: Text('Delete diary entry?')),
            ],
          ),
          content: Text(
            'Are you sure you want to delete '
            '${entry.flowerName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
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

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: diaryDarkGreen,
          behavior: SnackBarBehavior.floating,
          content: Text('${entry.flowerName} deleted'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: diaryMainGreen,
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
    final selectedAction = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: diaryCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Text(entry.sticker, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.flowerName,
                  style: const TextStyle(
                    color: diaryDarkGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (entry.isFavorite)
                const Icon(Icons.star, color: diaryPinkAccent),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
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
                        color: diaryLightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        entry.sticker,
                        style: const TextStyle(fontSize: 58),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: diaryDarkGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.location,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: diaryDarkGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(_formatDate(entry.date)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Diary entry',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: diaryDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.notes.isEmpty
                        ? 'No diary notes were recorded.'
                        : entry.notes,
                    style: const TextStyle(height: 1.5, color: diaryTextGrey),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, 'favorite');
              },
              icon: Icon(
                entry.isFavorite ? Icons.star : Icons.star_border,
                color: diaryPinkAccent,
              ),
              label: Text(entry.isFavorite ? 'Unfavourite' : 'Favourite'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, 'edit');
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, 'close');
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (selectedAction == 'favorite') {
      _toggleFavorite(entry);
    } else if (selectedAction == 'edit') {
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
    final visibleEntries = _visibleEntries;

    final favoriteCount = _entries.where((entry) => entry.isFavorite).length;

    return Scaffold(
      backgroundColor: diaryCream,
      appBar: AppBar(
        title: const Text(
          'My Diary',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: diaryMainGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
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
                  color: diaryDarkGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Write about flowers you discover and '
                'customize each memory with a sticker.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: diaryTextGrey,
                ),
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
                  prefixIcon: const Icon(Icons.search, color: diaryDarkGreen),
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
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: diaryBorderGreen,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: diaryMainGreen,
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _sortOption,
                decoration: InputDecoration(
                  labelText: 'Sort entries',
                  prefixIcon: const Icon(Icons.sort, color: diaryDarkGreen),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: diaryBorderGreen,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: diaryMainGreen,
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
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
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _sortOption = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Uses Row and Switch rather than SwitchListTile.
              Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: diaryBorderGreen),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _showFavoritesOnly ? Icons.star : Icons.star_border,
                        color: diaryPinkAccent,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Show favourites only',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: diaryDarkGreen,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$favoriteCount '
                              '${favoriteCount == 1 ? 'favourite' : 'favourites'}',
                              style: const TextStyle(color: diaryTextGrey),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _showFavoritesOnly,
                        activeThumbColor: Colors.white,
                        activeTrackColor: diaryMainGreen,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFFB8C1BA),
                        onChanged: (value) {
                          setState(() {
                            _showFavoritesOnly = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${visibleEntries.length} '
                '${visibleEntries.length == 1 ? 'entry' : 'entries'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: diaryTextGrey,
                ),
              ),
              const SizedBox(height: 12),
              if (visibleEntries.isEmpty)
                _EmptyDiaryMessage(
                  isSearching: _searchText.trim().isNotEmpty,
                  favoritesOnly: _showFavoritesOnly,
                )
              else
                ...visibleEntries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DiaryEntryCard(
                      flowerName: entry.flowerName,
                      location: entry.location,
                      date: _formatDate(entry.date),
                      sticker: entry.sticker,
                      isFavorite: entry.isFavorite,
                      onFavorite: () {
                        _toggleFavorite(entry);
                      },
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
        backgroundColor: diaryDarkGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        tooltip: 'Create a new diary entry',
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Entry',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final String flowerName;
  final String location;
  final String date;
  final String sticker;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5EEE7)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: diaryLightGreen,
          child: Text(sticker, style: const TextStyle(fontSize: 28)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                flowerName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: diaryDarkGreen,
                ),
              ),
            ),
            if (isFavorite)
              const Icon(Icons.star, color: diaryPinkAccent, size: 22),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '$location\n$date',
            style: const TextStyle(height: 1.5, color: diaryTextGrey),
          ),
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'Diary entry options',
          icon: const Icon(Icons.more_vert, color: diaryDarkGreen),
          onSelected: (value) {
            if (value == 'favorite') {
              onFavorite();
            } else if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 'favorite',
                child: Row(
                  children: [
                    Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: diaryPinkAccent,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isFavorite
                          ? 'Remove from favourites'
                          : 'Add to favourites',
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: diaryDarkGreen),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
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
  const _EmptyDiaryMessage({
    required this.isSearching,
    required this.favoritesOnly,
  });

  final bool isSearching;
  final bool favoritesOnly;

  @override
  Widget build(BuildContext context) {
    late final String title;
    late final String message;
    late final IconData icon;

    if (favoritesOnly) {
      title = 'No favourite entries';
      message = 'Mark an entry with a star to see it here.';
      icon = Icons.star_border;
    } else if (isSearching) {
      title = 'No matching diary entries';
      message = 'Try another flower name, location, note, or sticker.';
      icon = Icons.search_off;
    } else {
      title = 'Start your flower diary';
      message = 'Add your first entry to begin recording flower memories.';
      icon = Icons.menu_book_outlined;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: diaryBorderGreen),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: diaryLightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 46, color: diaryDarkGreen),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: diaryDarkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.5, color: diaryTextGrey),
          ),
        ],
      ),
    );
  }
}
