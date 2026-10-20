
class Flower {
  final String name;
  final String scientificName;
  final String description;
  final String imagePath;

  const Flower({
    required this.name,
    required this.scientificName,
    required this.description,
    required this.imagePath,
  });
}

class FlowerLibrary {
  static const List<Flower> flowers = [
    Flower(
      name: 'Rose',
      scientificName: 'Rosa',
      description:
          'Roses are popular flowering plants known for their '
          'beautiful petals and variety of colours.',
      imagePath: 'assets/flowers/rose.jpg',
    ),
    Flower(
      name: 'Sunflower',
      scientificName: 'Helianthus annuus',
      description:
          'Sunflowers are bright, sun-loving flowers with large '
          'golden petals and distinctive centres.',
      imagePath: 'assets/flowers/sunflower.jpg',
    ),
    Flower(
      name: 'Tulip',
      scientificName: 'Tulipa',
      description:
          'Tulips are spring flowers recognised by their '
          'cup-shaped blooms and vibrant colours.',
      imagePath: 'assets/flowers/tulip.jpg',
    ),
    Flower(
      name: 'Daisy',
      scientificName: 'Bellis perennis',
      description:
          'Daisies have delicate white petals surrounding a '
          'bright yellow centre.',
      imagePath: 'assets/flowers/daisy.jpg',
    ),
    Flower(
      name: 'Cosmos',
      scientificName: 'Cosmos bipinnatus',
      description:
          'Cosmos flowers have delicate petals and attract '
          'pollinators such as bees and butterflies.',
      imagePath: 'assets/flowers/cosmos.jpg',
    ),
    Flower(
      name: 'Lavender',
      scientificName: 'Lavandula',
      description:
          'Lavender is known for its purple flower spikes, '
          'fragrance, and attraction to pollinators.',
      imagePath: 'assets/flowers/lavender.jpg',
    ),
  ];

  static Flower getFlowerOfTheDay([DateTime? date]) {
    final today = date ?? DateTime.now();

    // Use UTC calendar dates to avoid timezone boundary issues.
    final day = DateTime.utc(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime.utc(2026, 1, 1)).inDays;

    final index = day % flowers.length;
    return flowers[(index + flowers.length) % flowers.length];
  }
}
