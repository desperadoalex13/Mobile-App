class ProductEntry {
  const ProductEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.kcalPer100,
    required this.proteinPer100,
    required this.fatPer100,
    required this.carbsPer100,
    this.defaultUnit = 'g',
  });

  final String id;
  final String name;
  final String category;
  final double kcalPer100;
  final double proteinPer100;
  final double fatPer100;
  final double carbsPer100;
  final String defaultUnit;

  factory ProductEntry.fromJson(Map<String, dynamic> json) => ProductEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        kcalPer100: (json['kcal'] as num).toDouble(),
        proteinPer100: (json['protein'] as num).toDouble(),
        fatPer100: (json['fat'] as num).toDouble(),
        carbsPer100: (json['carbs'] as num).toDouble(),
        defaultUnit: json['unit'] as String? ?? 'g',
      );
}
