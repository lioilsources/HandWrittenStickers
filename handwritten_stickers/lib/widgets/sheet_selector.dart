import 'package:flutter/material.dart';

import '../models/glyph_sheet.dart';

/// Horizontal chip row for choosing which glyph sheet ("handwriting") to use.
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          for (final sheet in sheets)
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
