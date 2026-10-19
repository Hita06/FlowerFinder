import 'dart:typed_data';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flowerfinderscanner/profile_storage.dart';
import 'package:flowerfinderscanner/user_profile.dart';

void main() {
  late Directory tempDirectory;
  late ProfileStorage storage;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('profile_storage_');
    storage = ProfileStorage(directoryProvider: () async => tempDirectory);
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('stores editable profile details by login account', () async {
    await storage.saveProfile(
      'linda@example.com',
      const EditableProfileDetails(
        name: 'Linda Flower',
        email: 'display@example.com',
        profileColorId: 'rose',
      ),
    );

    final lindaProfile = await storage.loadProfile('linda@example.com');
    final irisProfile = await storage.loadProfile('iris@example.com');

    expect(lindaProfile?.name, 'Linda Flower');
    expect(lindaProfile?.email, 'display@example.com');
    expect(lindaProfile?.profileColorId, 'rose');
    expect(irisProfile, isNull);
  });

  test('ignores unknown saved profile colour ids', () async {
    await storage.saveProfile(
      'linda@example.com',
      const EditableProfileDetails(
        name: 'Linda Flower',
        profileColorId: 'unknown-colour',
      ),
    );

    final profile = await storage.loadProfile('linda@example.com');

    expect(profile?.name, 'Linda Flower');
    expect(profile?.profileColorId, isNull);
  });

  test(
    'restores uploaded profile photos and collection display settings',
    () async {
      final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
      final settings = ProfileCollectionSettings(
        displaySizeId: 'largeSquare',
        uploadedPhotos: <ProfilePhotoData>[
          ProfilePhotoData(
            imageBytes: imageBytes,
            label: 'Garden photo',
            sizeId: 'large',
          ),
        ],
      );

      await storage.saveCollectionSettings('linda@example.com', settings);

      final restored = await storage.loadCollectionSettings(
        'linda@example.com',
      );

      expect(restored.displaySizeId, 'largeSquare');
      expect(restored.uploadedPhotos, hasLength(1));
      expect(
        restored.uploadedPhotos.single.imageBytes,
        orderedEquals(imageBytes),
      );
      expect(restored.uploadedPhotos.single.label, 'Garden photo');
      expect(restored.uploadedPhotos.single.sizeId, 'large');
      expect(
        (await storage.loadCollectionSettings(
          'iris@example.com',
        )).uploadedPhotos,
        isEmpty,
      );
    },
  );
}
