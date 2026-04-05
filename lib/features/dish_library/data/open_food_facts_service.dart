import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../domain/product_model.dart';

class OpenFoodFactsService {
  // The v2 search endpoint returns 503 when lc=uk is used.
  // The legacy CGI endpoint handles Cyrillic queries reliably.
  static const _baseUrl = 'https://world.openfoodfacts.org/cgi/search.pl';
  static const _userAgent = 'MealPlannerApp/1.0 (github.com/desperadoalex13)';
  static const _timeout = Duration(seconds: 12);
  static const _retryDelay = Duration(milliseconds: 800);

  /// Searches Open Food Facts for [query].
  ///
  /// [languageCode] — ISO 639-1 code ('en', 'uk', …).
  /// When non-English, `lc=<languageCode>` is included so OFF searches and
  /// returns product names in that language. The CGI endpoint handles Cyrillic
  /// queries natively. On failure or empty response the request is retried
  /// once after [_retryDelay] to handle transient server issues.
  Future<List<ProductEntry>> search(
    String query, {
    String languageCode = 'en',
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final params = <String, String>{
      'search_terms': trimmed,
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'fields': 'code,product_name,product_name_$languageCode,nutriments',
      'page_size': '20',
    };
    if (languageCode != 'en') params['lc'] = languageCode;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: params);

    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await http
            .get(uri, headers: {'User-Agent': _userAgent})
            .timeout(_timeout);

        if (response.statusCode != 200) {
          if (attempt == 0) await Future.delayed(_retryDelay);
          continue;
        }

        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final rawProducts = (json['products'] as List<dynamic>?) ?? [];

        // Empty response on first attempt → retry once.
        if (rawProducts.isEmpty && attempt == 0) {
          await Future.delayed(_retryDelay);
          continue;
        }

        final results = <ProductEntry>[];
        for (final item in rawProducts) {
          final p = item as Map<String, dynamic>;
          final code = (p['code'] as String?) ?? '';

          // Prefer the localised name; fall back to generic product_name
          // (which already contains Cyrillic for UA/RU products).
          final nameLocal =
              ((p['product_name_$languageCode'] as String?) ?? '').trim();
          final nameEn = ((p['product_name'] as String?) ?? '').trim();
          final name = nameLocal.isNotEmpty ? nameLocal : nameEn;
          if (code.isEmpty || name.isEmpty) continue;

          final n = (p['nutriments'] as Map<String, dynamic>?) ?? {};
          final kcal = (n['energy-kcal_100g'] as num?)?.toDouble();
          final protein = (n['proteins_100g'] as num?)?.toDouble();
          final fat = (n['fat_100g'] as num?)?.toDouble();
          final carbs = (n['carbohydrates_100g'] as num?)?.toDouble();

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
      } on Exception {
        // Network error / timeout — retry once, then give up silently.
        if (attempt == 0) await Future.delayed(_retryDelay);
      }
    }
    return [];
  }
}

final openFoodFactsServiceProvider = Provider<OpenFoodFactsService>(
  (_) => OpenFoodFactsService(),
);
