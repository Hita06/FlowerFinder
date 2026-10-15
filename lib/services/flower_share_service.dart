import 'package:share_plus/share_plus.dart';

class FlowerShareService {
  const FlowerShareService();

  String buildFlowerShareText({
    required String flowerName,
    required String scientificName,
    required String description,
    required String flowerType,
    required String flowerColour,
    required String season,
    required String careTips,
  }) {
    final cleanFlowerName = _cleanValue(flowerName, fallback: 'Unknown flower');

    final lines = <String>[
      '🌸 Flower identified with FlowerFinder',
      '',
      'Name: $cleanFlowerName',
    ];

    _addOptionalDetail(
      lines,
      label: 'Scientific name',
      value: scientificName,
      ignoredValues: {
        cleanFlowerName.toLowerCase(),
        'unknown',
        'unknown flower',
      },
    );

    _addOptionalDetail(lines, label: 'Type', value: flowerType);

    _addOptionalDetail(lines, label: 'Colour', value: flowerColour);

    _addOptionalDetail(lines, label: 'Season', value: season);

    final cleanDescription = description.trim();

    if (_hasUsefulValue(cleanDescription)) {
      lines
        ..add('')
        ..add(cleanDescription);
    }

    final cleanCareTips = careTips.trim();

    if (_hasUsefulValue(cleanCareTips)) {
      lines
        ..add('')
        ..add('Care tips:')
        ..add(cleanCareTips);
    }

    lines
      ..add('')
      ..add('Shared from FlowerFinder.');

    return lines.join('\n');
  }

  Future<ShareResult> shareFlower({
    required String flowerName,
    required String scientificName,
    required String description,
    required String flowerType,
    required String flowerColour,
    required String season,
    required String careTips,
  }) {
    final shareText = buildFlowerShareText(
      flowerName: flowerName,
      scientificName: scientificName,
      description: description,
      flowerType: flowerType,
      flowerColour: flowerColour,
      season: season,
      careTips: careTips,
    );

    return SharePlus.instance.share(
      ShareParams(
        title: 'FlowerFinder result',
        subject: 'Flower identified: $flowerName',
        text: shareText,
      ),
    );
  }

  void _addOptionalDetail(
    List<String> lines, {
    required String label,
    required String value,
    Set<String> ignoredValues = const {},
  }) {
    final cleanValue = value.trim();

    if (!_hasUsefulValue(cleanValue)) {
      return;
    }

    if (ignoredValues.contains(cleanValue.toLowerCase())) {
      return;
    }

    lines.add('$label: $cleanValue');
  }

  bool _hasUsefulValue(String value) {
    final normalizedValue = value.trim().toLowerCase();

    return normalizedValue.isNotEmpty &&
        normalizedValue != 'not available' &&
        normalizedValue != 'n/a' &&
        normalizedValue != 'unknown';
  }

  String _cleanValue(String value, {required String fallback}) {
    final cleanValue = value.trim();

    if (cleanValue.isEmpty) {
      return fallback;
    }

    return cleanValue;
  }
}
