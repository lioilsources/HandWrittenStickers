import 'package:flutter/material.dart';

import '../models/glyph_sheet.dart';
import '../models/preset.dart';

/// Horizontal row of presets: built-in ones, then the user's own, then a
/// chip that saves the current look.
///
/// Tapping a chip applies the preset; a long press opens its actions
/// ([showPresetActions]). The applied preset shows a dot once the look has
/// been changed since.
class PresetSelector extends StatelessWidget {
  final List<Preset> builtIns;
  final List<Preset> userPresets;
  final Preset? applied;

  /// The look differs from [applied].
  final bool modified;

  /// Looks up the sheet a preset uses, for its icon.
  final GlyphSheet? Function(String sheetId) sheetById;

  /// Presets the user cannot use yet (content pack not owned).
  final bool Function(Preset preset) isLocked;

  final ValueChanged<Preset> onApply;
  final ValueChanged<Preset> onLongPress;
  final VoidCallback onSave;

  const PresetSelector({
    super.key,
    required this.builtIns,
    required this.userPresets,
    required this.applied,
    required this.modified,
    required this.sheetById,
    required this.onApply,
    required this.onLongPress,
    required this.onSave,
    this.isLocked = _never,
  });

  static bool _never(Preset _) => false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (final p in builtIns) _chip(context, p),
          if (userPresets.isNotEmpty)
            const SizedBox(height: 24, child: VerticalDivider(width: 16)),
          for (final p in userPresets) _chip(context, p),
          ActionChip(
            key: const ValueKey('preset-save'),
            avatar: const Icon(Icons.bookmark_add_outlined, size: 18),
            label: const Text('Uložit'),
            tooltip: 'Uložit aktuální písmo a styl jako preset',
            onPressed: onSave,
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, Preset preset) {
    final theme = Theme.of(context);
    final isSelected = applied == preset;
    final sheet = sheetById(preset.sheetId);
    final locked = isLocked(preset);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onLongPress: () => onLongPress(preset),
        child: ChoiceChip(
          key: ValueKey('preset-${preset.id}'),
          avatar: Icon(
            locked
                ? Icons.lock_outline
                : sheet == null
                ? Icons.help_outline
                : sheet.isHandwriting
                ? Icons.draw
                : sheet.isMaterial
                ? Icons.palette
                : Icons.text_fields,
            size: 16,
          ),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(preset.name),
              if (isSelected && modified)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.circle,
                    key: const ValueKey('preset-modified'),
                    size: 7,
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => onApply(preset),
          selectedColor: theme.colorScheme.primaryContainer,
          labelStyle: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// What the user picked in [showPresetActions].
enum PresetAction { saveAsNew, overwrite, rename, delete }

/// Bottom sheet with the actions of [preset]. Built-in presets can only be
/// copied into a new preset.
Future<PresetAction?> showPresetActions(
  BuildContext context, {
  required Preset preset,
  required bool modified,
}) {
  return showModalBottomSheet<PresetAction>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              preset.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_add_outlined),
            title: const Text('Uložit aktuální jako nový preset'),
            onTap: () => Navigator.pop(context, PresetAction.saveAsNew),
          ),
          if (!preset.builtIn) ...[
            ListTile(
              leading: const Icon(Icons.save_outlined),
              title: const Text('Přepsat aktuálním nastavením'),
              enabled: modified,
              onTap: () => Navigator.pop(context, PresetAction.overwrite),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Přejmenovat'),
              onTap: () => Navigator.pop(context, PresetAction.rename),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Smazat'),
              onTap: () => Navigator.pop(context, PresetAction.delete),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Asks for a preset name; null when cancelled. Empty names cannot be
/// confirmed.
Future<String?> showPresetNameDialog(
  BuildContext context, {
  required String title,
  required String initial,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _PresetNameDialog(title: title, initial: initial),
  );
}

class _PresetNameDialog extends StatefulWidget {
  final String title;
  final String initial;

  const _PresetNameDialog({required this.title, required this.initial});

  @override
  State<_PresetNameDialog> createState() => _PresetNameDialogState();
}

class _PresetNameDialogState extends State<_PresetNameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial)
        ..selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget.initial.length,
        );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const ValueKey('preset-name'),
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        decoration: const InputDecoration(labelText: 'Název'),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Zrušit'),
        ),
        FilledButton(
          key: const ValueKey('preset-name-ok'),
          onPressed: _controller.text.trim().isEmpty ? null : _submit,
          child: const Text('Uložit'),
        ),
      ],
    );
  }
}

/// Asks before deleting [preset].
Future<bool> confirmPresetDelete(BuildContext context, Preset preset) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Smazat preset?'),
      content: Text('„${preset.name}“ se smaže. Text v editoru zůstane.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Zrušit'),
        ),
        FilledButton(
          key: const ValueKey('preset-delete-ok'),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Smazat'),
        ),
      ],
    ),
  );
  return ok ?? false;
}
