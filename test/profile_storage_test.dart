import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flowerfinderscanner/profile_storage.dart';

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
}
