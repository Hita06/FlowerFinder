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
      name: 'Emma Bridgewater™ Rose',
      scientificName: "Rosa 'Ausb44a16'",
      description:
          'Emma Bridgewater™ is an English shrub rose with '
          'full, rosette-shaped blooms that shift through pink, '
          'coral, apricot, mauve, and lilac tones. Its flowers '
          'have a light tea-like fragrance and repeat throughout '
          'the flowering season.',
      imagePath: 'assets/flowers/englishrose.jpeg',
    ),
    Flower(
      name: 'Common Sunflower',
      scientificName: 'Helianthus annuus',
      description:
          'The common sunflower is known for its large flower head, '
          'bright yellow petals, and dark central disc. '
          'Its flowers attract pollinators, and its seeds provide food '
          'for birds and people.',
      imagePath: 'assets/flowers/sunflower.jpeg',
    ),
    Flower(
      name: 'Darwin Hybrid Tulip',
      scientificName: 'Tulipa (Darwin Hybrid Group)',
      description:
          'Darwin Hybrid tulips are known for their large, '
          'classically shaped blooms and strong stems. '
          'They are popular spring flowers available in a range '
          'of vibrant colours.',
      imagePath: 'assets/flowers/tulip.jpeg',
    ),
    Flower(
      name: 'Chrysanthemum',
      scientificName: 'Chrysanthemum × morifolium',
      description:
          'Chrysanthemums produce striking blooms in many shapes '
          'and colours, from daisy-like flowers to dense, rounded heads. '
          'They are popular ornamental flowers, especially in autumn.',
      imagePath: 'assets/flowers/chrysanthemum.jpeg',
    ),
    Flower(
      name: 'Cosmos',
      scientificName: 'Cosmos bipinnatus',
      description:
          'Cosmos bipinnatus has delicate, daisy-like flowers '
          'and finely divided foliage. Its colourful blooms attract '
          'bees and butterflies and add a light, airy look to gardens.',
      imagePath: 'assets/flowers/cosmos.jpeg',
    ),
    Flower(
      name: 'Japanese Water Iris',
      scientificName: 'Iris ensata',
      description:
          'The Japanese water iris is known for its elegant, '
          'often large and ruffled flowers in shades of purple, '
          'blue, pink, and white. It thrives in moist soil and '
          'is often grown near ponds and water gardens.',
      imagePath: 'assets/flowers/iris.jpeg',
    ),
  ];

  static Flower getFlowerOfTheDay([DateTime? date]) {
    final today = date ?? DateTime.now();

    // Select one flower per calendar day.
    final currentDate = DateTime.utc(
      today.year,
      today.month,
      today.day,
    );
    final startDate = DateTime.utc(2026, 1, 1);

    final dayNumber = currentDate.difference(startDate).inDays;
    final index = dayNumber % flowers.length;

    // Keep the index valid for dates before the start date too.
    return flowers[(index + flowers.length) % flowers.length];
  }
}
