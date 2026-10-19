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

  Future<ProfileCollectionSettings> loadCollectionSettings(
    String accountId,
  ) async {
    final file = await _collectionFileFor(accountId);
    if (!await file.exists()) return const ProfileCollectionSettings();

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        return const ProfileCollectionSettings();
      }
      final encodedPhotos = decoded['uploadedPhotos'];
      final photos = encodedPhotos is List
          ? encodedPhotos
                .whereType<Map<String, dynamic>>()
                .map(_photoFromEntry)
                .whereType<ProfilePhotoData>()
                .toList()
          : const <ProfilePhotoData>[];
      return ProfileCollectionSettings(
        displaySizeId: decoded['displaySizeId'] == 'largeSquare'
            ? 'largeSquare'
            : 'smallGrid',
        uploadedPhotos: photos,
      );
    } catch (_) {
      return const ProfileCollectionSettings();
    }
  }

  Future<void> saveCollectionSettings(
    String accountId,
    ProfileCollectionSettings settings,
  ) async {
    final file = await _collectionFileFor(accountId);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode(<String, Object?>{
        'displaySizeId': settings.displaySizeId == 'largeSquare'
            ? 'largeSquare'
            : 'smallGrid',
        'uploadedPhotos': settings.uploadedPhotos
            .map(
              (photo) => <String, Object?>{
                'imageBytes': base64Encode(photo.imageBytes),
                'label': photo.label,
                'sizeId': photo.sizeId == 'large' ? 'large' : 'small',
              },
            )
            .toList(),
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

  Future<File> _collectionFileFor(String accountId) async {
    final baseDirectory = directoryProvider == null
        ? await getApplicationDocumentsDirectory()
        : await directoryProvider!();
    final safeId = base64Url.encode(utf8.encode(accountId)).replaceAll('=', '');
    return File(
      '${baseDirectory.path}/flower_finder/profile_collection_$safeId.json',
    );
  }

  static ProfilePhotoData? _photoFromEntry(Map<String, dynamic> entry) {
    final encodedBytes = entry['imageBytes'];
    if (encodedBytes is! String) return null;
    try {
      return ProfilePhotoData(
        imageBytes: base64Decode(encodedBytes),
        label: _stringOrNull(entry['label']) ?? 'Gallery photo',
        sizeId: entry['sizeId'] == 'large' ? 'large' : 'small',
      );
    } catch (_) {
      return null;
    }
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
