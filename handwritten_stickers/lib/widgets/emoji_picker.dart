import 'package:flutter/material.dart';

import '../models/emoji_tag.dart';
import 'emoji_sticker.dart';

/// Bottom sheet for tagging the message with one animated emoji. Resolves
/// to the chosen tag, `null` for "no emoji", or the current [selected] when
/// dismissed.
Future<EmojiTag?> showEmojiPicker(
  BuildContext context, {
  required EmojiIndex index,
  EmojiTag? selected,
}) async {
  final result = await showModalBottomSheet<_Pick>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _EmojiPickerSheet(index: index, selected: selected),
  );
  if (result == null) return selected; // dismissed
  return result.tag;
}

class _Pick {
  final EmojiTag? tag;
  const _Pick(this.tag);
}

class _EmojiPickerSheet extends StatelessWidget {
  final EmojiIndex index;
  final EmojiTag? selected;

  const _EmojiPickerSheet({required this.index, required this.selected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Emoji ke zprávě',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (selected != null)
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context, const _Pick(null)),
                      icon: const Icon(Icons.close),
                      label: const Text('Bez emoji'),
                    ),
                ],
              ),
            ),
            Flexible(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 80,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: index.tags.length,
                itemBuilder: (context, i) {
                  final tag = index.tags[i];
                  final isSelected = tag == selected;
                  return Tooltip(
                    message: tag.name,
                    child: InkWell(
                      key: ValueKey('emoji-${tag.emoji}'),
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
                          // Only the current choice moves; a grid of 40
                          // breathing stickers is restless and costs frames.
                          child: AnimatedEmojiSticker(
                            tag: tag,
                            size: 56,
                            animate: isSelected,
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
}
