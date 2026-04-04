import '../domain/dish_model.dart';

/// Parses a two-column CSV (dish name, ingredients) into a list of [Dish].
///
/// Expected CSV format (exported from Google Sheets / Excel):
///   Column 1 — dish name
///   Column 2 — ingredient lines, one per line, optionally followed by
///              " - <amount> <unit>" which is stripped to extract just the name
///
/// Defaults applied to every ingredient:
///   amountPerServing = 1, unit = 'pcs'
///   caloriesPerServing = 0, proteinPerServing = 1,
///   fatPerServing = 1, carbsPerServing = 1
abstract class CsvDishParser {
  static List<Dish> parse(String csvContent) {
    // Strip UTF-8 BOM if present
    if (csvContent.startsWith('\uFEFF')) {
      csvContent = csvContent.substring(1);
    }

    final rows = _parseCsv(csvContent);
    final dishes = <Dish>[];
    final base = DateTime.now().millisecondsSinceEpoch;

    for (var di = 0; di < rows.length; di++) {
      final row = rows[di];
      if (row.length < 2) continue;
      final dishName = row[0].trim();
      final ingredientsRaw = row[1].trim();
      if (dishName.isEmpty || ingredientsRaw.isEmpty) continue;

      final ingredientLines = ingredientsRaw
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      final ingredients = <Ingredient>[];
      for (var ii = 0; ii < ingredientLines.length; ii++) {
        final line = ingredientLines[ii];
        // Strip " - amount unit" suffix to get a clean ingredient name
        final dashIndex = line.indexOf(' - ');
        final name =
            dashIndex >= 0 ? line.substring(0, dashIndex).trim() : line;

        ingredients.add(Ingredient(
          productId: 'manual_${base}_${di}_$ii',
          name: name,
          amountPerServing: 1,
          unit: 'pcs',
          caloriesPerServing: 0,
          proteinPerServing: 1,
          fatPerServing: 1,
          carbsPerServing: 1,
        ));
      }

      dishes.add(Dish(
        id: 'csv_${base}_$di',
        name: dishName,
        servings: 1,
        ingredients: ingredients,
      ));
    }

    return dishes;
  }

  // ---------------------------------------------------------------------------
  // Minimal RFC-4180 CSV parser (handles quoted multi-line cells and "" escapes)
  // ---------------------------------------------------------------------------

  static List<List<String>> _parseCsv(String content) {
    content = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    final rows = <List<String>>[];
    final fields = <String>[];
    var field = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < content.length; i++) {
      final ch = content[i];

      if (inQuotes) {
        if (ch == '"') {
          // "" inside quotes → literal "
          if (i + 1 < content.length && content[i + 1] == '"') {
            field.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          field.write(ch);
        }
      } else {
        if (ch == '"') {
          inQuotes = true;
        } else if (ch == ',') {
          fields.add(field.toString());
          field.clear();
        } else if (ch == '\n') {
          fields.add(field.toString());
          field.clear();
          if (fields.any((f) => f.isNotEmpty)) {
            rows.add(List<String>.from(fields));
          }
          fields.clear();
        } else {
          field.write(ch);
        }
      }
    }

    // Handle last row (no trailing newline)
    fields.add(field.toString());
    if (fields.any((f) => f.isNotEmpty)) {
      rows.add(List<String>.from(fields));
    }

    return rows;
  }
}
