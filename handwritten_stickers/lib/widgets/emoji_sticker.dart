import 'package:flutter/material.dart';

import '../models/emoji_tag.dart';

/// An emoji sticker that breathes and rocks ([EmojiMotion]) and pops in when
/// the tag changes. Stands still when the platform asks to reduce motion.
class AnimatedEmojiSticker extends StatefulWidget {
  final EmojiTag tag;
  final double size;
  final bool animate;

  const AnimatedEmojiSticker({
    super.key,
    required this.tag,
    required this.size,
    this.animate = true,
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
        final m = EmojiMotion.at(_loop.value);
        final pop = Curves.elasticOut.transform(_pop.value);
        return Transform.translate(
          offset: Offset(0, size * m.lift),
          child: Transform.rotate(
            angle: m.angle,
            child: Transform.scale(
              scale: m.scale * (0.6 + 0.4 * pop),
              child: child,
            ),
          ),
        );
      },
      child: Image.asset(
        widget.tag.asset,
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
        semanticLabel: widget.tag.name,
        errorBuilder: (_, _, _) =>
            Text(widget.tag.emoji, style: TextStyle(fontSize: size * 0.8)),
      ),
    );
  }
}
