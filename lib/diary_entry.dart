import 'dart:convert';
import 'dart:typed_data';

import 'user_profile.dart';

class DiaryEntry {
  DiaryEntry({
    required this.flowerName,
    required this.location,
    required this.notes,
    required this.date,
    required this.sticker,
    this.generatedSticker,
    this.isFavorite = false,
  });

  String flowerName;
  String location;
  String notes;
  DateTime date;
  String sticker;
  GeneratedStickerAsset? generatedSticker;
  bool isFavorite;

  Map<String, Object?> toJson() => {
    'flowerName': flowerName,
    'location': location,
    'notes': notes,
    'date': date.toIso8601String(),
    'sticker': sticker,
    'isFavorite': isFavorite,
    'generatedSticker': generatedSticker == null
        ? null
        : {
            'stickerBytes': base64Encode(generatedSticker!.stickerBytes),
            'stickerId': generatedSticker!.stickerId,
            'createdAt': generatedSticker!.createdAt?.toIso8601String(),
            'label': generatedSticker!.label,
            'animationAsset': generatedSticker!.animationAsset,
          },
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    final flowerName = json['flowerName'];
    final location = json['location'];
    final notes = json['notes'];
    final dateValue = json['date'];
    final sticker = json['sticker'];
    if (flowerName is! String ||
        location is! String ||
        notes is! String ||
        dateValue is! String ||
        sticker is! String) {
      throw const FormatException('Invalid diary entry fields');
    }

    final date = DateTime.tryParse(dateValue);
    if (date == null) {
      throw const FormatException('Invalid diary entry date');
    }

    GeneratedStickerAsset? generatedSticker;
    final generatedValue = json['generatedSticker'];
    if (generatedValue != null) {
      if (generatedValue is! Map<String, dynamic> ||
          generatedValue['stickerBytes'] is! String) {
        throw const FormatException('Invalid generated diary sticker');
      }
      try {
        generatedSticker = GeneratedStickerAsset(
          stickerBytes: Uint8List.fromList(
            base64Decode(generatedValue['stickerBytes'] as String),
          ),
          stickerId: generatedValue['stickerId'] as String?,
          createdAt: DateTime.tryParse(
            generatedValue['createdAt']?.toString() ?? '',
          ),
          label: generatedValue['label'] as String?,
          animationAsset: generatedValue['animationAsset'] as String?,
        );
      } on FormatException {
        rethrow;
      } catch (error) {
        throw FormatException('Invalid generated diary sticker: $error');
      }
    }

    return DiaryEntry(
      flowerName: flowerName,
      location: location,
      notes: notes,
      date: date,
      sticker: sticker,
      generatedSticker: generatedSticker,
      isFavorite: json['isFavorite'] == true,
    );
  }
}
