import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    ref.listen(mealPlanMutationProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Operation failed. Please try again.'),
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
          tabs: const [
            Tab(text: 'Week'),
            Tab(text: 'Mon'),
            Tab(text: 'Tue'),
            Tab(text: 'Wed'),
            Tab(text: 'Thu'),
            Tab(text: 'Fri'),
            Tab(text: 'Sat'),
            Tab(text: 'Sun'),
          ],
        ),
        Expanded(
          child: planAsync.when(
            loading: () => const LoadingIndicator(),
            error: (e, _) => ErrorView(
              message: 'Could not load meal plan.',
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
            tooltip: 'Previous week',
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
              child: const Text('Today'),
            ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next week',
            onPressed: () => ref.read(selectedWeekProvider.notifier).state =
                week.add(const Duration(days: 7)),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
            onSelected: (value) async {
              if (value == 'copy_week') {
                await _confirmCopyWeek(context, ref, week);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'copy_week',
                child: ListTile(
                  leading: Icon(Icons.content_copy),
                  title: Text('Copy from previous week'),
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
    final prevWeek = week.subtract(const Duration(days: 7));
    final prevEnd = prevWeek.add(const Duration(days: 6));
    final thisEnd = week.add(const Duration(days: 6));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Copy previous week?'),
        content: Text(
          'Replace dishes in ${week.toDisplayDate()} – ${thisEnd.toDisplayDate()} '
          'with dishes from ${prevWeek.toDisplayDate()} – ${prevEnd.toDisplayDate()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Copy'),
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
            content: Text(
                hadContent ? 'Week copied!' : 'Previous week has no dishes.'),
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

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 7,
      itemBuilder: (context, i) {
        final date = week.add(Duration(days: i));
        final dayPlan = plan?.days.firstWhere(
              (d) => d.date.isSameDay(date),
              orElse: () => DayPlan(date: date, mealSlots: defaultSlots),
            ) ??
            DayPlan(date: date, mealSlots: defaultSlots);
        return _DayCard(
          date: date,
          dayPlan: dayPlan,
          dishMap: dishMap,
          onTap: () => onDayTap(i),
        );
      },
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
    final colorScheme = Theme.of(context).colorScheme;
    final isToday = date.isSameDay(DateTime.now());
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final label = '${weekdays[date.weekday - 1]} ${date.toDisplayDate()}';

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
                        'Today',
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                      ),
                    ),
                  ],
                  const Spacer(),
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
                  tooltip: 'Add dish',
                  onPressed: () => _pickDish(context, ref),
                ),
              ],
            ),
            if (slot.dishIds.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Tap + to add a dish',
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
                    tooltip: 'Remove',
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
        label: const Text('Copy from previous week'),
        onPressed: () => _confirmCopyDay(context, ref),
      ),
    );
  }

  Future<void> _confirmCopyDay(BuildContext context, WidgetRef ref) async {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = weekdays[date.weekday - 1];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Copy from previous week?'),
        content: Text(
          "Replace $dayName ${date.toDisplayDate()}'s dishes "
          'with last $dayName\'s dishes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Copy'),
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
                ? 'Day copied!'
                : 'Previous week has no dishes for this day.'),
          ),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final allDishes = ref.watch(dishesProvider).valueOrNull ?? [];
    final filtered = _query.isEmpty
        ? allDishes
        : allDishes
            .where(
                (d) => d.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return AlertDialog(
      title: const Text('Add dish'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search dishes…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: allDishes.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No dishes in library yet.'),
                    )
                  : filtered.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No matches.'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final dish = filtered[i];
                            return ListTile(
                              title: Text(dish.name),
                              subtitle:
                                  Text('${dish.totalCalories.round()} kcal'),
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
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
