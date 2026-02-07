import 'package:flutter/material.dart';

import '../models/style_params.dart';

/// Horizontal selector for style presets
class PresetSelector extends StatelessWidget {
  final StylePreset selected;
  final ValueChanged<StylePreset> onSelected;

  const PresetSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: StylePreset.values
            .where((p) => p != StylePreset.custom)
            .map((preset) => _buildPresetChip(context, preset))
            .toList(),
      ),
    );
  }

  Widget _buildPresetChip(BuildContext context, StylePreset preset) {
    final isSelected = selected == preset;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(preset.label),
        selected: isSelected,
        onSelected: (_) => onSelected(preset),
        selectedColor: theme.colorScheme.primaryContainer,
        labelStyle: TextStyle(
          color: isSelected
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
