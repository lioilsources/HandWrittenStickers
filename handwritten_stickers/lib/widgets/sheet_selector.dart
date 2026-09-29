import 'package:flutter/material.dart';

import '../models/glyph_sheet.dart';

/// Chip rows for choosing which glyph sheet ("handwriting") to use, grouped
/// by [SheetCategory].
class SheetSelector extends StatelessWidget {
  final List<GlyphSheet> sheets;
  final GlyphSheet selected;
  final ValueChanged<GlyphSheet> onSelected;

  const SheetSelector({
    super.key,
    required this.sheets,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = <SheetCategory, List<GlyphSheet>>{};
    for (final sheet in sheets) {
      groups.putIfAbsent(sheet.category, () => []).add(sheet);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final category in SheetCategory.values)
          if (groups.containsKey(category))
            _buildRow(theme, category, groups[category]!),
      ],
    );
  }

  Widget _buildRow(
    ThemeData theme,
    SheetCategory category,
    List<GlyphSheet> rowSheets,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              category.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final sheet in rowSheets)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(
                  sheet.isHandwriting ? Icons.draw : Icons.text_fields,
                  size: 16,
                ),
                label: Text(sheet.name),
                selected: sheet == selected,
                onSelected: (_) => onSelected(sheet),
                selectedColor: theme.colorScheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: sheet == selected
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurface,
                  fontWeight: sheet == selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
