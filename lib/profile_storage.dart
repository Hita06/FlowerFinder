import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user_profile.dart';

class EditableProfileDetails {
  const EditableProfileDetails({this.name, this.email, this.profileColorId});

  final String? name;
  final String? email;
  final String? profileColorId;

  bool get isEmpty => name == null && email == null && profileColorId == null;
}

class ProfileStorage {
  const ProfileStorage({this.directoryProvider});

  final Future<Directory> Function()? directoryProvider;

  Future<EditableProfileDetails?> loadProfile(String accountId) async {
    final file = await _fileFor(accountId);
    if (!await file.exists()) return null;

    try {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final details = EditableProfileDetails(
        name: _stringOrNull(decoded['name']),
        email: _stringOrNull(decoded['email']),
        profileColorId: _knownColorIdOrNull(decoded['profileColorId']),
      );
      return details.isEmpty ? null : details;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(
    String accountId,
    EditableProfileDetails details,
  ) async {
    final file = await _fileFor(accountId);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode(<String, Object?>{
        'name': details.name,
        'email': details.email,
        'profileColorId': _knownColorIdOrNull(details.profileColorId),
      }),
      flush: true,
    );
  }

  Future<File> _fileFor(String accountId) async {
    final baseDirectory = directoryProvider == null
        ? await getApplicationDocumentsDirectory()
        : await directoryProvider!();
    final safeId = base64Url.encode(utf8.encode(accountId)).replaceAll('=', '');
    return File('${baseDirectory.path}/flower_finder/profile_$safeId.json');
  }

  static String? _stringOrNull(Object? value) {
    final string = value?.toString().trim();
    return string == null || string.isEmpty ? null : string;
  }

  static String? _knownColorIdOrNull(Object? value) {
    final colorId = _stringOrNull(value);
    if (colorId == null) return null;
    final exists = ProfilePalette.choices.any((choice) => choice.id == colorId);
    return exists ? colorId : null;
  }
}
