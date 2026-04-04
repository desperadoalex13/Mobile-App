import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../data/dish_repository.dart';
import '../domain/dish_model.dart';
import '../domain/product_model.dart';
import 'dish_providers.dart';

class DishFormScreen extends ConsumerStatefulWidget {
  const DishFormScreen({super.key, this.dish});

  /// Non-null when editing an existing dish; null when creating a new one.
  final Dish? dish;

  @override
  ConsumerState<DishFormScreen> createState() => _DishFormScreenState();
}

class _DishFormScreenState extends ConsumerState<DishFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _servingsController;
  late final List<Ingredient> _ingredients;
  late final List<String> _labels;
  late final List<TextEditingController> _instructionControllers;

  bool get _isEditing => widget.dish != null;

  @override
  void initState() {
    super.initState();
    final d = widget.dish;
    _nameController = TextEditingController(text: d?.name ?? '');
    _servingsController =
        TextEditingController(text: (d?.servings ?? 1).toString());
    _ingredients = List.from(d?.ingredients ?? []);
    _labels = List.from(d?.labels ?? []);
    _instructionControllers = (d?.instructions ?? [])
        .map((s) => TextEditingController(text: s))
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _servingsController.dispose();
    for (final c in _instructionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(dishRepositoryProvider);
    final dish = Dish(
      id: widget.dish?.id ?? repo.generateId(),
      name: _nameController.text.trim(),
      servings: int.parse(_servingsController.text.trim()),
      ingredients: _ingredients,
      labels: List.from(_labels),
      instructions: _instructionControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    );

    await ref.read(dishMutationProvider.notifier).saveDish(dish);

    if (!mounted) return;
    if (ref.read(dishMutationProvider) is AsyncData) {
      Navigator.of(context).pop();
    }
  }

  // ---------------------------------------------------------------------------
  // Ingredient management
  // ---------------------------------------------------------------------------

  Future<void> _addIngredient() async {
    final ingredient = await showDialog<Ingredient>(
      context: context,
      builder: (_) => const _IngredientDialog(),
    );
    if (ingredient != null) setState(() => _ingredients.add(ingredient));
  }

  Future<void> _editIngredient(int index) async {
    final updated = await showDialog<Ingredient>(
      context: context,
      builder: (_) => _IngredientDialog(initial: _ingredients[index]),
    );
    if (updated != null) setState(() => _ingredients[index] = updated);
  }

  void _removeIngredient(int index) =>
      setState(() => _ingredients.removeAt(index));

  // ---------------------------------------------------------------------------
  // Instruction management
  // ---------------------------------------------------------------------------

  void _addInstruction() {
    setState(() => _instructionControllers.add(TextEditingController()));
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructionControllers[index].dispose();
      _instructionControllers.removeAt(index);
    });
  }

  // ---------------------------------------------------------------------------
  // Nutrition totals (computed from current ingredient list)
  // ---------------------------------------------------------------------------

  double get _totalCalories =>
      _ingredients.fold(0, (acc, i) => acc + i.caloriesPerServing);
  double get _totalProtein =>
      _ingredients.fold(0, (acc, i) => acc + i.proteinPerServing);
  double get _totalFat =>
      _ingredients.fold(0, (acc, i) => acc + i.fatPerServing);
  double get _totalCarbs =>
      _ingredients.fold(0, (acc, i) => acc + i.carbsPerServing);

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mutationState = ref.watch(dishMutationProvider);
    final isSaving = mutationState is AsyncLoading;

    ref.listen(dishMutationProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.saveDishFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editDishTitle : l10n.addDishTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Name ──────────────────────────────────────────────────────
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.dishNameLabel,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.dishNameError : null,
            ),
            const SizedBox(height: 16),

            // ── Servings ──────────────────────────────────────────────────
            TextFormField(
              controller: _servingsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.servingsLabel,
                helperText: l10n.servingsHelper,
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 1) return l10n.servingsError;
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Labels ────────────────────────────────────────────────────
            Text(
              l10n.labelsOptional,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: Dish.availableLabels.map((label) {
                return FilterChip(
                  label: Text(context.localizeLabel(label)),
                  selected: _labels.contains(label),
                  onSelected: (selected) => setState(() {
                    selected ? _labels.add(label) : _labels.remove(label);
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Ingredients ───────────────────────────────────────────────
            _SectionHeader(
              title: l10n.ingredientsSection,
              onAdd: _addIngredient,
              addLabel: l10n.addIngredientLabel,
            ),
            if (_ingredients.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.noIngredientsYet,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              )
            else
              ...List.generate(_ingredients.length, (i) {
                final ing = _ingredients[i];
                return _IngredientRow(
                  ingredient: ing,
                  onEdit: () => _editIngredient(i),
                  onDelete: () => _removeIngredient(i),
                );
              }),
            const SizedBox(height: 24),

            // ── Instructions ──────────────────────────────────────────────
            _SectionHeader(
              title: l10n.instructionsOptional,
              onAdd: _addInstruction,
              addLabel: l10n.addStep,
            ),
            if (_instructionControllers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.noStepsAdded,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              )
            else
              ...List.generate(_instructionControllers.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 14, right: 8),
                        child: Text(
                          '${i + 1}.',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _instructionControllers[i],
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: l10n.stepPlaceholder,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: l10n.removeStep,
                        onPressed: () => _removeInstruction(i),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 24),

            // ── Nutrition summary ─────────────────────────────────────────
            if (_ingredients.isNotEmpty) ...[
              _NutritionCard(
                calories: _totalCalories,
                protein: _totalProtein,
                fat: _totalFat,
                carbs: _totalCarbs,
              ),
              const SizedBox(height: 24),
            ],

            // ── Save ──────────────────────────────────────────────────────
            FilledButton(
              onPressed: isSaving ? null : _save,
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.saveDishButton),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Formats a double as an integer string when it has no fractional part
/// (e.g. 100.0 → "100", 12.5 → "12.5").
String _fmtNum(double v) =>
    v % 1 == 0 ? v.toInt().toString() : v.toString();

// ============================================================================
// Section header with "add" button
// ============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onAdd,
    required this.addLabel,
  });

  final String title;
  final VoidCallback onAdd;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: Text(addLabel),
        ),
      ],
    );
  }
}

// ============================================================================
// Ingredient row (in the form list)
// ============================================================================

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.ingredient,
    required this.onEdit,
    required this.onDelete,
  });

  final Ingredient ingredient;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(ingredient.name),
        subtitle: Text(
          '${_fmtNum(ingredient.amountPerServing)} ${ingredient.unit}  ·  '
          '${ingredient.caloriesPerServing.round()} ${l10n.kcal}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.edit,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.remove,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Nutrition summary card
// ============================================================================

class _NutritionCard extends StatelessWidget {
  const _NutritionCard({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.nutritionPerServing,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NutrientCell(
                    label: l10n.caloriesLabel, value: calories, unit: l10n.kcal),
                _NutrientCell(label: l10n.proteinLabel, value: protein, unit: 'g'),
                _NutrientCell(label: l10n.fatLabel, value: fat, unit: 'g'),
                _NutrientCell(label: l10n.carbsLabel, value: carbs, unit: 'g'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientCell extends StatelessWidget {
  const _NutrientCell({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final double value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(1)} $unit',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ============================================================================
// Ingredient dialog
// ============================================================================

class _IngredientDialog extends ConsumerStatefulWidget {
  const _IngredientDialog({this.initial});

  final Ingredient? initial;

  @override
  ConsumerState<_IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends ConsumerState<_IngredientDialog> {
  static const _units = ['g', 'ml', 'kg', 'L', 'piece', 'tbsp', 'tsp'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _calCtrl;
  late final TextEditingController _protCtrl;
  late final TextEditingController _fatCtrl;
  late final TextEditingController _carbsCtrl;
  late String _unit;
  ProductEntry? _linkedProduct;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _nameCtrl = TextEditingController(text: i?.name ?? '');
    _amountCtrl = TextEditingController(
        text: i != null ? _fmtNum(i.amountPerServing) : '');
    _calCtrl = TextEditingController(
        text: i != null ? _fmtNum(i.caloriesPerServing) : '');
    _protCtrl = TextEditingController(
        text: i != null ? _fmtNum(i.proteinPerServing) : '');
    _fatCtrl = TextEditingController(
        text: i != null ? _fmtNum(i.fatPerServing) : '');
    _carbsCtrl = TextEditingController(
        text: i != null ? _fmtNum(i.carbsPerServing) : '');
    _unit = i?.unit ?? 'g';
    _amountCtrl.addListener(_recalcFromProduct);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _calCtrl.dispose();
    _protCtrl.dispose();
    _fatCtrl.dispose();
    _carbsCtrl.dispose();
    super.dispose();
  }

  void _recalcFromProduct() {
    final p = _linkedProduct;
    if (p == null) return;
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final factor = amount / 100;
    _calCtrl.text = _fmtNum(p.kcalPer100 * factor);
    _protCtrl.text = _fmtNum(p.proteinPer100 * factor);
    _fatCtrl.text = _fmtNum(p.fatPer100 * factor);
    _carbsCtrl.text = _fmtNum(p.carbsPer100 * factor);
  }

  Future<void> _pickFromDatabase() async {
    final product = await showDialog<ProductEntry>(
      context: context,
      builder: (_) => const _ProductSearchDialog(),
    );
    if (product == null) return;
    setState(() {
      _linkedProduct = product;
      _nameCtrl.text = product.name;
      _unit = product.defaultUnit;
      if (_amountCtrl.text.isEmpty) _amountCtrl.text = '100';
    });
    _recalcFromProduct();
  }

  String? _validateNumber(String? v, {bool required = true}) {
    final l10n = context.l10n;
    if (v == null || v.isEmpty) return required ? l10n.requiredError : null;
    final n = double.tryParse(v);
    if (n == null || n < 0) return l10n.numberError;
    return null;
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    final productId = _linkedProduct?.id ??
        widget.initial?.productId ??
        'manual_${DateTime.now().millisecondsSinceEpoch}';
    final ingredient = Ingredient(
      productId: productId,
      name: _nameCtrl.text.trim(),
      amountPerServing: double.parse(_amountCtrl.text),
      unit: _unit,
      caloriesPerServing: double.parse(_calCtrl.text),
      proteinPerServing: double.parse(_protCtrl.text),
      fatPerServing: double.parse(_fatCtrl.text),
      carbsPerServing: double.parse(_carbsCtrl.text),
    );
    Navigator.of(context).pop(ingredient);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.initial != null
          ? l10n.editIngredientTitle
          : l10n.addIngredientTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.search, size: 18),
                label: Text(
                  _linkedProduct == null
                      ? l10n.searchDatabase
                      : l10n.changeProduct(_linkedProduct!.name),
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: _pickFromDatabase,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration:
                    InputDecoration(labelText: l10n.ingredientNameLabel),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.requiredError : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          InputDecoration(labelText: l10n.amountLabel),
                      validator: _validateNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: InputDecoration(labelText: l10n.unitLabel),
                      items: _units
                          .map((u) =>
                              DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) => setState(() => _unit = v!),
                    ),
                  ),
                ],
              ),
              if (_linkedProduct != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.autoCalculatedNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              const SizedBox(height: 12),
              _NumberField(
                controller: _calCtrl,
                label: l10n.caloriesKcalLabel,
                validate: _validateNumber,
              ),
              const SizedBox(height: 8),
              _NumberField(
                controller: _protCtrl,
                label: l10n.proteinGLabel,
                validate: _validateNumber,
              ),
              const SizedBox(height: 8),
              _NumberField(
                controller: _fatCtrl,
                label: l10n.fatGLabel,
                validate: _validateNumber,
              ),
              const SizedBox(height: 8),
              _NumberField(
                controller: _carbsCtrl,
                label: l10n.carbsGLabel,
                validate: _validateNumber,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _confirm,
          child: Text(widget.initial != null ? l10n.save : l10n.addIngredientLabel),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.validate,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validate;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      validator: validate,
    );
  }
}

// ============================================================================
// Product search dialog
// ============================================================================

class _ProductSearchDialog extends ConsumerStatefulWidget {
  const _ProductSearchDialog();

  @override
  ConsumerState<_ProductSearchDialog> createState() =>
      _ProductSearchDialogState();
}

class _ProductSearchDialogState extends ConsumerState<_ProductSearchDialog> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final productsAsync = ref.watch(productsProvider);
    return Dialog(
      child: SizedBox(
        width: 360,
        height: 520,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.searchDatabaseTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchProductsHint,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: productsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (products) {
                  final filtered = _query.trim().isEmpty
                      ? products
                      : products
                          .where((p) => p.name
                              .toLowerCase()
                              .contains(_query.toLowerCase().trim()))
                          .toList();
                  if (filtered.isEmpty) {
                    return Center(child: Text(l10n.noProductsFound));
                  }
                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final p = filtered[i];
                      return ListTile(
                        dense: true,
                        title: Text(p.name),
                        subtitle: Text(
                          '${p.kcalPer100.round()} ${l10n.kcal} · '
                          'P ${p.proteinPer100}g · '
                          'F ${p.fatPer100}g · '
                          'C ${p.carbsPer100}g'
                          '  per 100 ${p.defaultUnit}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        onTap: () => Navigator.of(context).pop(p),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
