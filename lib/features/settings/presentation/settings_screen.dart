import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_provider.dart';
import '../../../l10n/l10n.dart';
import '../../auth/presentation/profile_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  List<String>? _slots;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _slots ??= List<String>.from(ref.read(userSlotsProvider));
  }

  void _saveSlots(List<String> slots) {
    setState(() => _slots = slots);
    ref.read(profileMutationProvider.notifier).updateSlots(slots);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Keep local state in sync when profile updates arrive from Firestore.
    ref.listen(userProfileProvider, (_, next) {
      final incoming = next.valueOrNull?.mealSlots;
      if (incoming != null && mounted) {
        setState(() => _slots = List<String>.from(incoming));
      }
    });

    // Show error snackbar on save failure.
    ref.listen(profileMutationProvider, (_, next) {
      if (next is AsyncError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.saveFailedSnackbar),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    final slots = _slots ?? [];
    final currentLocale = ref.watch(localeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Language ──────────────────────────────────────────────────────
        Text(l10n.languageTitle,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _LanguageTile(
          label: l10n.languageEnglish,
          locale: const Locale('en'),
          selected: currentLocale.languageCode == 'en',
          onTap: () => _setLocale(const Locale('en')),
        ),
        _LanguageTile(
          label: l10n.languageUkrainian,
          locale: const Locale('uk'),
          selected: currentLocale.languageCode == 'uk',
          onTap: () => _setLocale(const Locale('uk')),
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),

        // ── Meal Slots ────────────────────────────────────────────────────
        Text(l10n.mealSlotsTitle,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: slots.length,
          onReorder: (oldIndex, newIndex) {
            final updated = List<String>.from(slots);
            if (newIndex > oldIndex) newIndex--;
            updated.insert(newIndex, updated.removeAt(oldIndex));
            _saveSlots(updated);
          },
          itemBuilder: (context, index) {
            final slotName = slots[index];
            return ListTile(
              key: ValueKey(slotName),
              title: Text(slotName),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: l10n.rename,
                    onPressed: () =>
                        _showRenameDialog(context, index, slotName),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.delete,
                    onPressed: slots.length > 1
                        ? () => _deleteSlot(index)
                        : null,
                  ),
                  const Icon(Icons.drag_handle),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.add),
          label: Text(l10n.addSlot),
          onPressed: () => _showAddDialog(context),
        ),
      ],
    );
  }

  Future<void> _setLocale(Locale locale) async {
    ref.read(localeProvider.notifier).state = locale;
    await saveLocale(locale);
  }

  void _deleteSlot(int index) {
    final updated = List<String>.from(_slots!);
    updated.removeAt(index);
    _saveSlots(updated);
  }

  Future<void> _showRenameDialog(
      BuildContext context, int index, String current) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _SlotNameDialog(
        title: l10n.renameSlotTitle,
        controller: controller,
        existing: _slots!,
        excludeIndex: index,
      ),
    );
    if (result != null) {
      final updated = List<String>.from(_slots!);
      updated[index] = result;
      _saveSlots(updated);
    }
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _SlotNameDialog(
        title: l10n.addSlotTitle,
        controller: controller,
        existing: _slots!,
      ),
    );
    if (result != null) {
      _saveSlots([..._slots!, result]);
    }
  }
}

// ============================================================================
// Language tile
// ============================================================================

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Locale locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check,
              color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

// ============================================================================
// Slot name dialog
// ============================================================================

class _SlotNameDialog extends StatefulWidget {
  const _SlotNameDialog({
    required this.title,
    required this.controller,
    required this.existing,
    this.excludeIndex,
  });

  final String title;
  final TextEditingController controller;
  final List<String> existing;
  final int? excludeIndex;

  @override
  State<_SlotNameDialog> createState() => _SlotNameDialogState();
}

class _SlotNameDialogState extends State<_SlotNameDialog> {
  String? _error;

  String? _validate(String value) {
    final l10n = context.l10n;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return l10n.slotNameEmptyError;
    final others = [
      for (var i = 0; i < widget.existing.length; i++)
        if (i != widget.excludeIndex) widget.existing[i],
    ];
    if (others.any((s) => s.toLowerCase() == trimmed.toLowerCase())) {
      return l10n.slotNameExistsError;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: widget.controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.slotNameLabel,
          errorText: _error,
        ),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        onSubmitted: (_) => _submit(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => _submit(context),
          child: Text(l10n.save),
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    final error = _validate(widget.controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(widget.controller.text.trim());
  }
}
