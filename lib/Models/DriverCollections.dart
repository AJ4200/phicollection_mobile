class DriverCollection {
  final String driver;
  final int collections;
  final int breakdowns;

  const DriverCollection({
    required this.driver,
    required this.collections,
    required this.breakdowns,
  });

  factory DriverCollection.fromJson(Map<String, dynamic> json) => DriverCollection(
    driver: json['driver'],
    collections: json['collectionsCompleted'],
    breakdowns: json['breakdowns'],
  );
}