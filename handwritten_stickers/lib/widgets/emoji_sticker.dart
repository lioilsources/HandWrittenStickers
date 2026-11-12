import 'package:flutter/material.dart';

import '../models/emoji_tag.dart';

/// An emoji sticker that plays its loop ([EmojiMotion]) and pops in when
/// the tag changes. Stands still when the platform asks to reduce motion.
class AnimatedEmojiSticker extends StatefulWidget {
  final EmojiTag tag;
  final double size;
  final bool animate;

  /// Decode width in physical pixels (picker grids); null decodes at the
  /// image's own size, which the zoomed preview needs.
  final int? cacheWidth;

  const AnimatedEmojiSticker({
    super.key,
    required this.tag,
    required this.size,
    this.animate = true,
    this.cacheWidth,
  });

  @override
  State<AnimatedEmojiSticker> createState() => _AnimatedEmojiStickerState();
}

class _AnimatedEmojiStickerState extends State<AnimatedEmojiSticker>
    with TickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: EmojiMotion.period,
  );
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
    value: 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant AnimatedEmojiSticker old) {
    super.didUpdateWidget(old);
    if (old.tag != widget.tag && !MediaQuery.of(context).disableAnimations) {
      _pop.forward(from: 0);
    }
    _sync();
  }

  void _sync() {
    final run = widget.animate && !MediaQuery.of(context).disableAnimations;
    if (run && !_loop.isAnimating) {
      _loop.repeat();
    } else if (!run && _loop.isAnimating) {
      _loop.stop();
      _loop.value = 0;
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return AnimatedBuilder(
      animation: Listenable.merge([_loop, _pop]),
      builder: (context, child) {
        final pose = EmojiMotion.pose(widget.tag.motion, _loop.value);
        final pop = 0.6 + 0.4 * Curves.elasticOut.transform(_pop.value);
        // Same matrix as the GIF export (ImageExporter.renderFrame).
        return Transform(
          alignment: Alignment.center,
          transform: pose.matrix(size)
            ..multiply(Matrix4.diagonal3Values(pop, pop, 1)),
          child: child,
        );
      },
      child: Image.asset(
        widget.tag.asset,
        width: size,
        height: size,
        cacheWidth: widget.cacheWidth,
        filterQuality: FilterQuality.medium,
        semanticLabel: widget.tag.name,
        errorBuilder: (_, _, _) =>
            Text(widget.tag.emoji, style: TextStyle(fontSize: size * 0.8)),
      ),
    );
  }
}
