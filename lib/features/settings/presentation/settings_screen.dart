import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/profile_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  List<String>? _slots;

  @override
  void initState() {
    super.initState();
    // Listen to profile changes and sync local state.
    // Initial value is populated via ref.listen below (first callback fires on
    // next frame), so we also seed synchronously in didChangeDependencies.
  }

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
            content: const Text('Failed to save. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    final slots = _slots ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Meal Slots', style: Theme.of(context).textTheme.titleMedium),
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
                    tooltip: 'Rename',
                    onPressed: () => _showRenameDialog(context, index, slotName),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete',
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
          label: const Text('Add Slot'),
          onPressed: () => _showAddDialog(context),
        ),
      ],
    );
  }

  void _deleteSlot(int index) {
    final updated = List<String>.from(_slots!);
    updated.removeAt(index);
    _saveSlots(updated);
  }

  Future<void> _showRenameDialog(
      BuildContext context, int index, String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _SlotNameDialog(
        title: 'Rename Slot',
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
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _SlotNameDialog(
        title: 'Add Slot',
        controller: controller,
        existing: _slots!,
      ),
    );
    if (result != null) {
      _saveSlots([..._slots!, result]);
    }
  }
}

// ---------------------------------------------------------------------------

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
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Name cannot be empty';
    final others = [
      for (var i = 0; i < widget.existing.length; i++)
        if (i != widget.excludeIndex) widget.existing[i],
    ];
    if (others.any((s) => s.toLowerCase() == trimmed.toLowerCase())) {
      return 'A slot with this name already exists';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: widget.controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Slot name',
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _submit(context),
          child: const Text('Save'),
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
