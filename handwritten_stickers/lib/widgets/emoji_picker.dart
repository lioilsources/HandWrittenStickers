import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/emoji_tag.dart';
import 'emoji_sticker.dart';

/// Bottom sheet for tagging the message with one animated emoji: a row of
/// art styles (when the index has more than one), a row of categories (plus
/// "Recent" when [recentIds] has any) and a grid of the chosen one. Opens in
/// the style of [selected], else [style], else the default style. Locked
/// styles ([isLocked]) can be browsed and picked; the editor asks for the
/// pack on export. Resolves to the chosen tag, `null` for "no emoji", or the
/// current [selected] when dismissed.
Future<EmojiTag?> showEmojiPicker(
  BuildContext context, {
  required EmojiIndex index,
  EmojiTag? selected,
  List<String> recentIds = const [],
  String? style,
  bool Function(EmojiStyle style)? isLocked,
}) async {
  final result = await showModalBottomSheet<_Pick>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _EmojiPickerSheet(
      index: index,
      selected: selected,
      recentIds: recentIds,
      style: style,
      isLocked: isLocked ?? (_) => false,
    ),
  );
  if (result == null) return selected; // dismissed
  return result.tag;
}

class _Pick {
  final EmojiTag? tag;
  const _Pick(this.tag);
}

class _EmojiPickerSheet extends StatefulWidget {
  final EmojiIndex index;
  final EmojiTag? selected;
  final List<String> recentIds;
  final String? style;
  final bool Function(EmojiStyle style) isLocked;

  const _EmojiPickerSheet({
    required this.index,
    required this.selected,
    required this.recentIds,
    required this.style,
    required this.isLocked,
  });

  @override
  State<_EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<_EmojiPickerSheet> {
  static const String _recentId = 'recent';

  late String _style = _initialStyle();
  late String _category = _initialCategory();

  String _initialStyle() {
    final index = widget.index;
    for (final id in [widget.selected?.style, widget.style]) {
      if (index.styleById(id) != null) return id!;
    }
    return index.defaultStyle.id;
  }

  String _initialCategory() {
    final sel = widget.selected?.category;
    if (sel != null && _categories.any((c) => c.id == sel)) return sel;
    if (_recent.isNotEmpty) return _recentId;
    return _categories.isEmpty ? '' : _categories.first.id;
  }

  /// Recent emoji, drawn in the current style.
  List<EmojiTag> get _recent => [
    for (final id in widget.recentIds) ?widget.index.byId(id, style: _style),
  ];

  /// Categories that have emoji in the current style.
  List<EmojiCategory> get _categories => [
    for (final c in widget.index.categories)
      if (widget.index.inCategory(c.id, style: _style).isNotEmpty) c,
  ];

  List<EmojiTag> get _tags {
    if (_category == _recentId) return _recent;
    // An index without categories (old format) shows everything.
    if (widget.index.categories.isEmpty) return widget.index.inStyle(_style);
    return widget.index.inCategory(_category, style: _style);
  }

  void _setStyle(String style) => setState(() {
    _style = style;
    // Keep the category when the new style has it.
    if (_category == _recentId ? _recent.isEmpty : _tags.isEmpty) {
      _category = _recent.isNotEmpty
          ? _recentId
          : (_categories.isEmpty ? '' : _categories.first.id);
    }
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final tags = _tags;
    final recent = _recent;
    final categories = _categories;
    final styles = widget.index.styles;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.emojiTag,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (widget.selected != null)
                    TextButton.icon(
                      onPressed: () =>
                          Navigator.pop(context, const _Pick(null)),
                      icon: const Icon(Icons.close),
                      label: Text(l10n.noEmoji),
                    ),
                ],
              ),
            ),
            if (styles.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                child: SegmentedButton<String>(
                  key: const ValueKey('emoji-styles'),
                  showSelectedIcon: false,
                  segments: [
                    for (final s in styles)
                      ButtonSegment(
                        value: s.id,
                        label: Text(
                          s.name,
                          key: ValueKey('emoji-style-${s.id}'),
                        ),
                        icon: widget.isLocked(s)
                            ? const Icon(Icons.lock_outline, size: 16)
                            : null,
                      ),
                  ],
                  selected: {_style},
                  onSelectionChanged: (s) => _setStyle(s.first),
                ),
              ),
            if (categories.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    if (recent.isNotEmpty)
                      _chip(_recentId, l10n.emojiRecent, Icons.history),
                    for (final c in categories) _chip(c.id, c.name),
                  ],
                ),
              ),
            Flexible(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 80,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: tags.length,
                itemBuilder: (context, i) {
                  final tag = tags[i];
                  final isSelected = tag == widget.selected;
                  return Tooltip(
                    message: tag.name,
                    child: InkWell(
                      key: ValueKey('emoji-${tag.id}'),
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.pop(context, _Pick(tag)),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isSelected
                              ? theme.colorScheme.secondaryContainer
                              : null,
                        ),
                        child: Center(
                          // Only the current choice moves; a grid of
                          // moving stickers is restless and costs frames.
                          child: AnimatedEmojiSticker(
                            tag: tag,
                            size: 56,
                            animate: isSelected,
                            cacheWidth: (56 * dpr).ceil(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String id, String label, [IconData? icon]) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      key: ValueKey('emoji-cat-$id'),
      avatar: icon == null ? null : Icon(icon, size: 18),
      label: Text(label),
      selected: _category == id,
      onSelected: (_) => setState(() => _category = id),
    ),
  );
}
