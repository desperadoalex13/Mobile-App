import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../domain/product_model.dart';

class OpenFoodFactsService {
  static const _baseUrl = 'https://world.openfoodfacts.org/api/v2/search';
  static const _translateUrl = 'https://api.mymemory.translated.net/get';
  static const _userAgent = 'MealPlannerApp/1.0 (github.com/desperadoalex13)';
  static const _timeout = Duration(seconds: 8);

  /// Translates [query] from [fromLanguage] to English using MyMemory.
  /// Returns the original query on any error so search still works.
  Future<String> _translateToEnglish(
      String query, String fromLanguage) async {
    try {
      final uri = Uri.parse(_translateUrl).replace(queryParameters: {
        'q': query,
        'langpair': '$fromLanguage|en',
      });
      final response =
          await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return query;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final translated =
          ((json['responseData'] as Map<String, dynamic>?)?['translatedText']
                  as String?)
              ?.trim();
      return (translated != null && translated.isNotEmpty) ? translated : query;
    } catch (_) {
      return query;
    }
  }

  /// [languageCode] — ISO 639-1 code (e.g. 'en', 'uk').
  /// When non-English, the query is translated to English before searching
  /// OFF (so "курка" → "chicken" for the search), but results are returned
  /// with the localised product name where available.
  Future<List<ProductEntry>> search(
    String query, {
    String languageCode = 'en',
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    // Translate the query to English so OFF can find results regardless of
    // which language the user types in.
    final searchQuery = languageCode == 'en'
        ? trimmed
        : await _translateToEnglish(trimmed, languageCode);

    final params = <String, String>{
      'q': searchQuery,
      // Request both the English name and the localised name in one call.
      'fields': 'code,product_name,product_name_$languageCode,nutriments',
      'page_size': '20',
    };
    // lc= tells OFF to prefer returning nutriment labels in that language.
    if (languageCode != 'en') params['lc'] = languageCode;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: params);

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

        // Prefer the localised name; fall back to English product_name.
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
