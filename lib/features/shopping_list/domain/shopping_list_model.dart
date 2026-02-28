class ShoppingList {
  ShoppingList({required this.items});

  final List<ShoppingItem> items;

  List<ShoppingItem> get unchecked => items.where((i) => !i.isPurchased).toList();
  List<ShoppingItem> get checked => items.where((i) => i.isPurchased).toList();

  Map<String, List<ShoppingItem>> get groupedByCategory {
    final grouped = <String, List<ShoppingItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }
}

class ShoppingItem {
  ShoppingItem({
    required this.productId,
    required this.name,
    required this.totalAmount,
    required this.unit,
    required this.category,
    this.isPurchased = false,
  });

  final String productId;
  final String name;
  final double totalAmount;
  final String unit;
  final String category;
  bool isPurchased;

  ShoppingItem copyWith({bool? isPurchased}) => ShoppingItem(
        productId: productId,
        name: name,
        totalAmount: totalAmount,
        unit: unit,
        category: category,
        isPurchased: isPurchased ?? this.isPurchased,
      );
}
