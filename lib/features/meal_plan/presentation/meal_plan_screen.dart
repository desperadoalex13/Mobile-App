import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/utils/date_utils.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/presentation/profile_providers.dart';
import '../../dish_library/domain/dish_model.dart';
import '../../dish_library/presentation/dish_providers.dart';
import '../domain/meal_plan_model.dart';
import 'meal_plan_providers.dart';

class MealPlanScreen extends ConsumerStatefulWidget {
  const MealPlanScreen({super.key});

  @override
  ConsumerState<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends ConsumerState<MealPlanScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(mealPlanMutationProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.operationFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    final week = ref.watch(selectedWeekProvider);
    final planAsync = ref.watch(mealPlanProvider);

    return Column(
      children: [
        _WeekHeader(week: week, ref: ref),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.weekTab),
            Tab(text: l10n.monTab),
            Tab(text: l10n.tueTab),
            Tab(text: l10n.wedTab),
            Tab(text: l10n.thuTab),
            Tab(text: l10n.friTab),
            Tab(text: l10n.satTab),
            Tab(text: l10n.sunTab),
          ],
        ),
        Expanded(
          child: planAsync.when(
            loading: () => const LoadingIndicator(),
            error: (e, _) => ErrorView(
              message: l10n.loadMealPlanError,
              onRetry: () => ref.invalidate(mealPlanProvider),
            ),
            data: (plan) => TabBarView(
              controller: _tabController,
              children: [
                _WeekView(
                  week: week,
                  plan: plan,
                  onDayTap: (dayIndex) =>
                      _tabController.animateTo(dayIndex + 1),
                ),
                for (var i = 0; i < 7; i++)
                  _DayView(
                    date: week.add(Duration(days: i)),
                    plan: plan,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Week header with navigation
// ============================================================================

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.week, required this.ref});

  final DateTime week;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final endOfWeek = week.add(const Duration(days: 6));
    final rangeLabel =
        '${week.toDisplayDate()} – ${endOfWeek.toDisplayDate()}';
    final isCurrentWeek = week.isSameDay(DateTime.now().startOfWeek);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.previousWeek,
            onPressed: () => ref.read(selectedWeekProvider.notifier).state =
                week.subtract(const Duration(days: 7)),
          ),
          Expanded(
            child: Text(
              rangeLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          if (!isCurrentWeek)
            TextButton(
              onPressed: () => ref.read(selectedWeekProvider.notifier).state =
                  DateTime.now().startOfWeek,
              child: Text(l10n.today),
            ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.nextWeek,
            onPressed: () => ref.read(selectedWeekProvider.notifier).state =
                week.add(const Duration(days: 7)),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: l10n.moreOptions,
            onSelected: (value) async {
              if (value == 'copy_week') {
                await _confirmCopyWeek(context, ref, week);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'copy_week',
                child: ListTile(
                  leading: const Icon(Icons.content_copy),
                  title: Text(l10n.copyFromPreviousWeek),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCopyWeek(
      BuildContext context, WidgetRef ref, DateTime week) async {
    final l10n = context.l10n;
    final prevWeek = week.subtract(const Duration(days: 7));
    final prevEnd = prevWeek.add(const Duration(days: 6));
    final thisEnd = week.add(const Duration(days: 6));
    final thisRange =
        '${week.toDisplayDate()} – ${thisEnd.toDisplayDate()}';
    final prevRange =
        '${prevWeek.toDisplayDate()} – ${prevEnd.toDisplayDate()}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.copyWeekDialogTitle),
        content: Text(l10n.copyWeekDialogContent(thisRange, prevRange)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.copy),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final hadContent = await ref
          .read(mealPlanMutationProvider.notifier)
          .copyWeek(targetWeek: week);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hadContent
                ? l10n.weekCopied
                : l10n.noPreviousWeekDishes),
          ),
        );
      }
    }
  }
}

// ============================================================================
// Week overview (Tab 0)
// ============================================================================

class _WeekView extends ConsumerWidget {
  const _WeekView({
    required this.week,
    required this.plan,
    required this.onDayTap,
  });

  final DateTime week;
  final MealPlan? plan;
  final void Function(int dayIndex) onDayTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultSlots = ref
        .watch(userSlotsProvider)
        .map((n) => MealSlot(name: n, dishIds: []))
        .toList();
    final dishMap = _buildDishMap(ref.watch(dishesProvider));

    final dayPlans = [
      for (var i = 0; i < 7; i++)
        plan?.days.firstWhere(
              (d) => d.date.isSameDay(week.add(Duration(days: i))),
              orElse: () => DayPlan(
                  date: week.add(Duration(days: i)), mealSlots: defaultSlots),
            ) ??
            DayPlan(
                date: week.add(Duration(days: i)), mealSlots: defaultSlots),
    ];

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _WeekNutritionSummary(dayPlans: dayPlans, dishMap: dishMap),
        for (var i = 0; i < 7; i++)
          _DayCard(
            date: week.add(Duration(days: i)),
            dayPlan: dayPlans[i],
            dishMap: dishMap,
            onTap: () => onDayTap(i),
          ),
      ],
    );
  }

  Map<String, Dish> _buildDishMap(AsyncValue<List<Dish>> dishesAsync) {
    final dishes = dishesAsync.valueOrNull ?? [];
    return {for (final d in dishes) d.id: d};
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.date,
    required this.dayPlan,
    required this.dishMap,
    required this.onTap,
  });

  final DateTime date;
  final DayPlan dayPlan;
  final Map<String, Dish> dishMap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final isToday = date.isSameDay(DateTime.now());
    final label = '${context.dayAbbr(date.weekday)} ${date.toDisplayDate()}';
    final nutrition = _calcDayNutrition(dayPlan, dishMap);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isToday ? colorScheme.primary : null,
                        ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.today,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (nutrition.kcal > 0)
                    Text(
                      '${nutrition.kcal.round()} ${l10n.kcal}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right,
                      size: 16, color: colorScheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 8),
              ...dayPlan.mealSlots
                  .map((slot) => _SlotChipRow(slot: slot, dishMap: dishMap)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotChipRow extends StatelessWidget {
  const _SlotChipRow({required this.slot, required this.dishMap});

  final MealSlot slot;
  final Map<String, Dish> dishMap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              slot.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: slot.dishIds.isEmpty
                ? Text(
                    '—',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outlineVariant,
                        ),
                  )
                : Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: slot.dishIds
                        .map(
                          (id) => Chip(
                            label: Text(
                              dishMap[id]?.name ?? id,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Single day view (Tabs 1–7)
// ============================================================================

class _DayView extends ConsumerWidget {
  const _DayView({required this.date, required this.plan});

  final DateTime date;
  final MealPlan? plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultSlots = ref
        .watch(userSlotsProvider)
        .map((n) => MealSlot(name: n, dishIds: []))
        .toList();
    final dayPlan = plan?.days.firstWhere(
          (d) => d.date.isSameDay(date),
          orElse: () => DayPlan(date: date, mealSlots: defaultSlots),
        ) ??
        DayPlan(date: date, mealSlots: defaultSlots);

    final dishMap = _buildDishMap(ref.watch(dishesProvider));

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _CopyDayButton(date: date),
        _DayNutritionSummary(dayPlan: dayPlan, dishMap: dishMap),
        ...dayPlan.mealSlots.map((slot) => _SlotSection(
              date: date,
              slot: slot,
              dishMap: dishMap,
            )),
      ],
    );
  }

  Map<String, Dish> _buildDishMap(AsyncValue<List<Dish>> dishesAsync) {
    final dishes = dishesAsync.valueOrNull ?? [];
    return {for (final d in dishes) d.id: d};
  }
}

class _SlotSection extends ConsumerWidget {
  const _SlotSection({
    required this.date,
    required this.slot,
    required this.dishMap,
  });

  final DateTime date;
  final MealSlot slot;
  final Map<String, Dish> dishMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(slot.name, style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: l10n.addDishTooltip,
                  onPressed: () => _pickDish(context, ref),
                ),
              ],
            ),
            if (slot.dishIds.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.emptySlot,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outlineVariant,
                      ),
                ),
              )
            else
              ...slot.dishIds.map(
                (id) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(dishMap[id]?.name ?? id),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: l10n.remove,
                    onPressed: () => ref
                        .read(mealPlanMutationProvider.notifier)
                        .removeDish(date, slot.name, id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDish(BuildContext context, WidgetRef ref) async {
    final dishId = await showDialog<String>(
      context: context,
      builder: (_) => const _DishPickerDialog(),
    );
    if (dishId != null && context.mounted) {
      ref
          .read(mealPlanMutationProvider.notifier)
          .addDish(date, slot.name, dishId);
    }
  }
}

// ============================================================================
// Copy day button
// ============================================================================

class _CopyDayButton extends ConsumerWidget {
  const _CopyDayButton({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        icon: const Icon(Icons.content_copy, size: 16),
        label: Text(context.l10n.copyFromPreviousWeek),
        onPressed: () => _confirmCopyDay(context, ref),
      ),
    );
  }

  Future<void> _confirmCopyDay(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final dayName = context.dayAbbr(date.weekday);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.copyDayDialogTitle),
        content: Text(
          l10n.copyDayDialogContent(dayName, date.toDisplayDate()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.copy),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final hadContent = await ref
          .read(mealPlanMutationProvider.notifier)
          .copyDay(targetDate: date);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hadContent
                ? l10n.dayCopied
                : l10n.noPreviousDayDishes),
          ),
        );
      }
    }
  }
}

// ============================================================================
// Nutrition helpers and widgets
// ============================================================================

({double kcal, double protein, double fat, double carbs}) _calcDayNutrition(
    DayPlan day, Map<String, Dish> dishMap) {
  double kcal = 0, protein = 0, fat = 0, carbs = 0;
  for (final slot in day.mealSlots) {
    for (final id in slot.dishIds) {
      final dish = dishMap[id];
      if (dish == null) continue;
      kcal += dish.totalCalories;
      protein += dish.totalProtein;
      fat += dish.totalFat;
      carbs += dish.totalCarbs;
    }
  }
  return (kcal: kcal, protein: protein, fat: fat, carbs: carbs);
}

class _WeekNutritionSummary extends StatelessWidget {
  const _WeekNutritionSummary(
      {required this.dayPlans, required this.dishMap});

  final List<DayPlan> dayPlans;
  final Map<String, Dish> dishMap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    double kcal = 0, protein = 0, fat = 0, carbs = 0;
    for (final day in dayPlans) {
      final n = _calcDayNutrition(day, dishMap);
      kcal += n.kcal;
      protein += n.protein;
      fat += n.fat;
      carbs += n.carbs;
    }
    if (kcal == 0) return const SizedBox.shrink();

    String fmt(double v) =>
        v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Text(
              l10n.weeklyTotal,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _NutrientChip(
                    label: l10n.kcal,
                    value: kcal.round().toString(),
                    onContainer: colorScheme.onSecondaryContainer),
                _NutrientChip(
                    label: l10n.proteinLabel,
                    value: '${fmt(protein)}g',
                    onContainer: colorScheme.onSecondaryContainer),
                _NutrientChip(
                    label: l10n.fatLabel,
                    value: '${fmt(fat)}g',
                    onContainer: colorScheme.onSecondaryContainer),
                _NutrientChip(
                    label: l10n.carbsLabel,
                    value: '${fmt(carbs)}g',
                    onContainer: colorScheme.onSecondaryContainer),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayNutritionSummary extends StatelessWidget {
  const _DayNutritionSummary({required this.dayPlan, required this.dishMap});

  final DayPlan dayPlan;
  final Map<String, Dish> dishMap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final n = _calcDayNutrition(dayPlan, dishMap);
    if (n.kcal == 0) return const SizedBox.shrink();

    String fmt(double v) =>
        v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            _NutrientChip(label: l10n.kcal, value: n.kcal.round().toString()),
            _NutrientChip(
                label: l10n.proteinLabel, value: '${fmt(n.protein)}g'),
            _NutrientChip(label: l10n.fatLabel, value: '${fmt(n.fat)}g'),
            _NutrientChip(label: l10n.carbsLabel, value: '${fmt(n.carbs)}g'),
          ],
        ),
      ),
    );
  }
}

class _NutrientChip extends StatelessWidget {
  const _NutrientChip(
      {required this.label, required this.value, this.onContainer});

  final String label;
  final String value;
  final Color? onContainer;

  @override
  Widget build(BuildContext context) {
    final color =
        onContainer ?? Theme.of(context).colorScheme.onPrimaryContainer;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Dish picker dialog
// ============================================================================

class _DishPickerDialog extends ConsumerStatefulWidget {
  const _DishPickerDialog();

  @override
  ConsumerState<_DishPickerDialog> createState() => _DishPickerDialogState();
}

class _DishPickerDialogState extends ConsumerState<_DishPickerDialog> {
  String _query = '';
  String _activeTag = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final allDishes = ref.watch(dishesProvider).valueOrNull ?? [];
    final tags = ref.watch(userTagsProvider);
    final filtered = allDishes.where((d) {
      final matchesQuery = _query.isEmpty ||
          d.name.toLowerCase().contains(_query.toLowerCase());
      final matchesTag = _activeTag.isEmpty || d.tags.contains(_activeTag);
      return matchesQuery && matchesTag;
    }).toList();

    return AlertDialog(
      title: Text(l10n.addDishDialogTitle),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.searchDishesHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FilterChip(
                      label: Text(l10n.all),
                      selected: _activeTag.isEmpty,
                      onSelected: (_) => setState(() => _activeTag = ''),
                    ),
                    ...tags.map((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: FilterChip(
                          label: Text(tag),
                          selected: _activeTag == tag,
                          onSelected: (_) => setState(
                              () => _activeTag = _activeTag == tag ? '' : tag),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: allDishes.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.noDishesInLibrary),
                    )
                  : filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(l10n.noMatches),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final dish = filtered[i];
                            return ListTile(
                              title: Text(dish.name),
                              subtitle: Text(
                                  '${dish.totalCalories.round()} ${l10n.kcal}'),
                              onTap: () =>
                                  Navigator.of(context).pop(dish.id),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
