import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../domain/product_model.dart';

class OpenFoodFactsService {
  static const _baseUrl = 'https://world.openfoodfacts.org/api/v2/search';
  static const _userAgent = 'MealPlannerApp/1.0 (github.com/desperadoalex13)';
  static const _timeout = Duration(seconds: 8);

  Future<List<ProductEntry>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'q': trimmed,
      'fields': 'code,product_name,nutriments',
      'page_size': '20',
    });

    try {
      final response = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(_timeout);

      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final rawProducts = (json['products'] as List<dynamic>?) ?? [];

      final results = <ProductEntry>[];
      for (final item in rawProducts) {
        final p = item as Map<String, dynamic>;
        final code = (p['code'] as String?) ?? '';
        final name = ((p['product_name'] as String?) ?? '').trim();
        if (code.isEmpty || name.isEmpty) continue;

        final n = (p['nutriments'] as Map<String, dynamic>?) ?? {};
        final kcal = (n['energy-kcal_100g'] as num?)?.toDouble();
        final protein = (n['proteins_100g'] as num?)?.toDouble();
        final fat = (n['fat_100g'] as num?)?.toDouble();
        final carbs = (n['carbohydrates_100g'] as num?)?.toDouble();

        // Skip products with incomplete nutrition data.
        if (kcal == null || protein == null || fat == null || carbs == null) {
          continue;
        }

        results.add(ProductEntry(
          id: 'off_$code',
          name: name,
          category: 'online',
          kcalPer100: kcal,
          proteinPer100: protein,
          fatPer100: fat,
          carbsPer100: carbs,
          defaultUnit: 'g',
        ));
      }
      return results;
    } catch (_) {
      // Network error / timeout — return empty list silently.
      return [];
    }
  }
}

final openFoodFactsServiceProvider = Provider<OpenFoodFactsService>(
  (_) => OpenFoodFactsService(),
);
