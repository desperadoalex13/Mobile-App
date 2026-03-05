import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/shopping_list/domain/shopping_list_model.dart';

ShoppingItem _item({
  String id = 'p1',
  String name = 'Milk',
  String category = 'Dairy',
  bool isPurchased = false,
}) =>
    ShoppingItem(
      productId: id,
      name: name,
      totalAmount: 1.0,
      unit: 'L',
      category: category,
      isPurchased: isPurchased,
    );

void main() {
  group('ShoppingItem', () {
    test('copyWith changes isPurchased', () {
      final item = _item(isPurchased: false);
      final checked = item.copyWith(isPurchased: true);
      expect(checked.isPurchased, isTrue);
      expect(checked.name, item.name);
    });

    test('copyWith without args preserves isPurchased', () {
      final item = _item(isPurchased: true);
      final copy = item.copyWith();
      expect(copy.isPurchased, isTrue);
    });
  });

  group('ShoppingList', () {
    test('unchecked returns only unpurchased items', () {
      final list = ShoppingList(items: [
        _item(id: 'a', isPurchased: false),
        _item(id: 'b', isPurchased: true),
        _item(id: 'c', isPurchased: false),
      ]);
      expect(list.unchecked.length, 2);
      expect(list.unchecked.every((i) => !i.isPurchased), isTrue);
    });

    test('checked returns only purchased items', () {
      final list = ShoppingList(items: [
        _item(id: 'a', isPurchased: false),
        _item(id: 'b', isPurchased: true),
      ]);
      expect(list.checked.length, 1);
      expect(list.checked.first.productId, 'b');
    });

    test('groupedByCategory groups correctly', () {
      final list = ShoppingList(items: [
        _item(id: 'a', category: 'Dairy'),
        _item(id: 'b', category: 'Produce'),
        _item(id: 'c', category: 'Dairy'),
      ]);
      final grouped = list.groupedByCategory;
      expect(grouped.keys, containsAll(['Dairy', 'Produce']));
      expect(grouped['Dairy']!.length, 2);
      expect(grouped['Produce']!.length, 1);
    });

    test('groupedByCategory is empty for empty list', () {
      final list = ShoppingList(items: []);
      expect(list.groupedByCategory, isEmpty);
    });

    test('unchecked and checked are empty for empty list', () {
      final list = ShoppingList(items: []);
      expect(list.unchecked, isEmpty);
      expect(list.checked, isEmpty);
    });
  });
}
