import 'package:flutter/material.dart';

class UserAccount {
  UserAccount({required this.name, required this.username, required this.email});

  String name;
  String username;
  String email;
}

class SavedFlowerPhoto {
  const SavedFlowerPhoto({required this.image, this.label});

  final ImageProvider image;
  final String? label;
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, this.savedFlowerPhotos = const []});

  final List<SavedFlowerPhoto> savedFlowerPhotos;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserAccount _account = UserAccount(
    name: 'New Flower Finder User',
    username: 'flower_finder_user',
    email: 'user@example.com',
  );

  final List<String> _savedStickers = const [];

  Future<void> _editAccount() async {
    final updatedAccount = await showModalBottomSheet<UserAccount>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditAccountSheet(account: _account),
    );
    if (updatedAccount == null) return;
    setState(() {
      _account
        ..name = updatedAccount.name
        ..username = updatedAccount.username
        ..email = updatedAccount.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My account'),
        actions: [
          IconButton(
            onPressed: _editAccount,
            tooltip: 'Edit account',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xffdce9d8),
              child: Text(
                _account.name.substring(0, 1),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff2f6b4f),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _account.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text('@${_account.username}', style: TextStyle(color: Colors.grey.shade600)),
          ),
          const SizedBox(height: 28),
          Card(
            child: Column(
              children: [
                _AccountRow(icon: Icons.person_outline, label: 'Name', value: _account.name),
                _AccountRow(icon: Icons.alternate_email, label: 'Username', value: _account.username),
                _AccountRow(icon: Icons.email_outlined, label: 'Email', value: _account.email),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Flower identification', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const _ActivityTile(icon: Icons.bookmark_outline, title: 'Saved flowers', value: '12'),
          const _ActivityTile(icon: Icons.camera_alt_outlined, title: 'Flowers identified', value: '27'),
          const _ActivityTile(icon: Icons.collections_bookmark_outlined, title: 'Collections', value: '4'),
          const SizedBox(height: 24),
          _SavedFlowerPhotosSection(photos: widget.savedFlowerPhotos),
          const SizedBox(height: 24),
          _SavedItemsSection(
            title: 'Saved stickers',
            items: _savedStickers,
            emptyIcon: Icons.emoji_emotions_outlined,
            emptyTitle: 'No saved stickers yet',
            emptyMessage: 'Stickers created from identified flowers will appear here.',
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _SavedFlowerPhotosSection extends StatelessWidget {
  const _SavedFlowerPhotosSection({required this.photos});

  final List<SavedFlowerPhoto> photos;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saved flower photos', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (photos.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xffe7eee3),
                      child: Icon(Icons.photo_library_outlined, color: Color(0xff2f6b4f)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('No saved flower photos yet', style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Photos from future flower scans will appear here.', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              clipBehavior: Clip.antiAlias,
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image(image: photo.image, fit: BoxFit.cover),
                        if (photo.label != null)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              color: Colors.black54,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: Text(
                                photo.label!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      );
}

class _SavedItemsSection extends StatelessWidget {
  const _SavedItemsSection({
    required this.title,
    required this.items,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final String title;
  final List<String> items;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xffe7eee3),
                      child: Icon(emptyIcon, color: const Color(0xff2f6b4f)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(emptyTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(emptyMessage, style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  for (final item in items) ListTile(title: Text(item)),
                ],
              ),
            ),
        ],
      );
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: const Color(0xff2f6b4f)),
        title: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      );
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: const Color(0xffe7eee3),
          child: Icon(icon, color: const Color(0xff2f6b4f)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      );
}

class _EditAccountSheet extends StatefulWidget {
  const _EditAccountSheet({required this.account});

  final UserAccount account;

  @override
  State<_EditAccountSheet> createState() => _EditAccountSheetState();
}

class _EditAccountSheetState extends State<_EditAccountSheet> {
  late final _nameController = TextEditingController(text: widget.account.name);
  late final _usernameController = TextEditingController(text: widget.account.username);
  late final _emailController = TextEditingController(text: widget.account.email);

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Material(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit account', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 12),
                TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.alternate_email))),
                const SizedBox(height: 12),
                TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text('Save changes'))),
              ],
            ),
          ),
        ),
      );

  void _save() {
    if (_nameController.text.trim().isEmpty || _usernameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) return;
    Navigator.pop(
      context,
      UserAccount(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
      ),
    );
  }
}
