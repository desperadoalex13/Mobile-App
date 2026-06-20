import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/utils/date_utils.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../meal_plan/presentation/meal_plan_providers.dart';
import '../domain/shopping_list_model.dart';
import 'shopping_list_providers.dart';

String _fmtAmount(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(1);

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  Future<void> _copyToClipboard(
      BuildContext context, ShoppingList list, AppLocalizations l10n) async {
    final grouped = list.groupedByCategory;
    final categories = grouped.keys.toList()..sort();
    final buffer = StringBuffer();
    for (final category in categories) {
      buffer.writeln('$category:');
      for (final item in grouped[category]!) {
        buffer
            .writeln('- ${_fmtAmount(item.totalAmount)} ${item.unit} ${item.name}');
      }
      buffer.writeln();
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString().trim()));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.shoppingListCopied)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final week = ref.watch(selectedWeekProvider);
    final listAsync = ref.watch(shoppingListProvider);

    ref.listen(shoppingListMutationProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.operationFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    final currentList = listAsync.valueOrNull;
    final canCopy = currentList != null && currentList.items.isNotEmpty;

    return Column(
      children: [
        _WeekHeader(
          week: week,
          onCopy: canCopy
              ? () => _copyToClipboard(context, currentList, l10n)
              : null,
        ),
        Expanded(
          child: listAsync.when(
            loading: () => const LoadingIndicator(),
            error: (e, _) => ErrorView(
              message: l10n.loadShoppingListError,
              onRetry: () => ref.invalidate(shoppingListProvider),
            ),
            data: (list) {
              if (list.items.isEmpty) {
                return _EmptyState(message: l10n.shoppingListEmpty);
              }
              final grouped = list.groupedByCategory;
              final categories = grouped.keys.toList()..sort();
              return ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  for (final category in categories)
                    _CategorySection(
                      category: category,
                      items: grouped[category]!,
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeekHeader extends ConsumerWidget {
  const _WeekHeader({required this.week, required this.onCopy});

  final DateTime week;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          IconButton(
            icon: const Icon(Icons.copy_all_outlined),
            tooltip: l10n.copyShoppingList,
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends ConsumerWidget {
  const _CategorySection({required this.category, required this.items});

  final String category;
  final List<ShoppingItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = [...items]
      ..sort((a, b) {
        if (a.isPurchased != b.isPurchased) return a.isPurchased ? 1 : -1;
        return a.name.compareTo(b.name);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            category,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        for (final item in sorted)
          CheckboxListTile(
            value: item.isPurchased,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (_) => ref
                .read(shoppingListMutationProvider.notifier)
                .togglePurchased(item),
            title: Text(
              item.name,
              style: item.isPurchased
                  ? const TextStyle(decoration: TextDecoration.lineThrough)
                  : null,
            ),
            subtitle: Text('${_fmtAmount(item.totalAmount)} ${item.unit}'),
          ),
      ],
    );
  }
}
