import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/l10n/app_localizations.dart';
import 'package:handwritten_stickers/models/emoji_tag.dart';
import 'package:handwritten_stickers/models/glyph.dart';
import 'package:handwritten_stickers/models/style_params.dart';
import 'package:handwritten_stickers/services/image_exporter.dart';
import 'package:handwritten_stickers/widgets/emoji_picker.dart';
import 'package:image/image.dart' as img;

Future<ui.Image> _block(int w, int h) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
    Paint()..color = Colors.black,
  );
  return recorder.endRecording().toImage(w, h);
}

Future<List<PositionedGlyph>> _glyphs(int count, {int h = 60}) async {
  final glyph = Glyph(
    char: 'A',
    image: await _block(40, h),
    width: 40,
    height: h,
  );
  return [
    for (var i = 0; i < count; i++)
      PositionedGlyph(
        glyph: glyph,
        params: const GlyphParams(),
        x: i * 50.0,
        y: 0,
      ),
  ];
}

/// Corners of the sticker's subject (masters keep ~6 % margin, so the
/// subject is ~88 % of the badge) after [pose], in layout units.
List<Offset> _subjectCorners(StickerLayout layout, EmojiPose pose) {
  final b = layout.badge;
  final centre = layout.badgeOrigin + Offset(b / 2, b / 2);
  final m = pose.matrix(b);
  final h = b * 0.44;
  return [
    for (final c in [
      Offset(-h, -h),
      Offset(h, -h),
      Offset(-h, h),
      Offset(h, h),
    ])
      centre + MatrixUtils.transformPoint(m, c),
  ];
}

/// The bundled index with a second, paid style that reuses the paper art
/// (real asset paths, so images still load).
class _TwoStyleBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) => rootBundle.load(key);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final text = await rootBundle.loadString(key);
    if (key != EmojiIndex.assetPath) return text;
    final data = json.decode(text) as Map<String, dynamic>;
    final first = (data['styles'] as List).first['id'] as String;
    (data['styles'] as List).add({
      'id': 'marker',
      'name': {'cs': 'Fix', 'en': 'Marker'},
      'pack': 'emoji_marker',
    });
    // Marker has every other emoji, so categories differ between styles.
    var i = 0;
    for (final e in data['emoji'] as List) {
      final files = e['files'] as Map;
      if ((i++).isEven) files['marker'] = files[first];
    }
    return json.encode(data);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('emoji index: unique ids, every category used, images decode', () async {
    final index = await EmojiIndex.load(language: 'en');
    expect(index.tags.length, greaterThanOrEqualTo(20));
    expect(index.tags.map((t) => t.id).toSet().length, index.tags.length);
    expect(index.categories, isNotEmpty);
    for (final c in index.categories) {
      expect(index.inCategory(c.id), isNotEmpty, reason: c.id);
      expect(c.name, isNotEmpty);
    }
    final cats = index.categories.map((c) => c.id).toSet();
    for (final tag in index.tags) {
      expect(cats, contains(tag.category), reason: tag.id);
      expect(tag.name, isNotEmpty);
      expect(tag.emoji, isNotEmpty);
      final data = await rootBundle.load(tag.asset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThan(64), reason: tag.asset);
    }
    // Names follow the content language.
    final cs = await EmojiIndex.load(language: 'cs');
    expect(cs.byId('love_heart')?.name, 'Srdce');
    expect(index.byId('love_heart')?.name, 'Heart');
  });

  group('emoji motions', () {
    for (final kind in EmojiMotionKind.values) {
      test(
        '${kind.name} rests at 0, loops, moves and stays on the canvas',
        () async {
          final rest = EmojiMotion.pose(kind, 0).matrix(100);
          expect(rest.isIdentity(), isTrue);
          final end = EmojiMotion.pose(kind, 1).matrix(100);
          expect(end.isIdentity(), isTrue);

          var moved = 0.0;
          for (var i = 0; i < EmojiMotion.gifFrames; i++) {
            final m = EmojiMotion.pose(
              kind,
              i / EmojiMotion.gifFrames,
            ).matrix(100);
            final p = MatrixUtils.transformPoint(m, const Offset(50, -50));
            moved = math.max(moved, (p - const Offset(50, -50)).distance);
          }
          expect(moved, greaterThan(2), reason: 'barely moves');

          // Smallest badge (short text) and biggest (tall text).
          for (final h in [20, 400]) {
            final layout = StickerLayout.of(
              await _glyphs(2, h: h),
              withEmoji: true,
            );
            for (var i = 0; i < 96; i++) {
              for (final c in _subjectCorners(
                layout,
                EmojiMotion.pose(kind, i / 96),
              )) {
                expect(
                  c.dx,
                  inInclusiveRange(0, layout.width),
                  reason: 'x at $i',
                );
                expect(
                  c.dy,
                  inInclusiveRange(0, layout.height),
                  reason: 'y at $i',
                );
              }
            }
          }
        },
      );
    }

    test('unknown motion names fall back to breathe', () {
      expect(EmojiMotionKind.parse('moonwalk'), EmojiMotionKind.breathe);
      expect(EmojiMotionKind.parse('wave'), EmojiMotionKind.wave);
    });
  });

  test('a tagged message exports as a looping GIF with the badge', () async {
    final index = await EmojiIndex.load();
    final glyphs = await _glyphs(2);
    final layout = StickerLayout.of(glyphs, withEmoji: true);
    expect(layout.badge, greaterThanOrEqualTo(44));
    expect(layout.width, greaterThan(90 + layout.badge));

    final gif = await ImageExporter.exportToGif(
      glyphs: glyphs,
      emoji: index.tags.first,
    );
    expect(gif, isNotNull);
    final decoded = img.decodeGif(gif!)!;
    expect(decoded.numFrames, EmojiMotion.gifFrames);
    final gifScale = ImageExporter.scaleFor(layout, ImageExporter.gifMaxSide);
    expect(decoded.width, closeTo(layout.width * gifScale, 2));
    // Messengers convert GIFs to video, which needs even dimensions.
    expect(decoded.width.isEven, isTrue);
    expect(decoded.height.isEven, isTrue);
    // One global colour table, no per-frame ones, frames left in place.
    expect(gif[10], 0xf7);
    expect(decoded.frames.last.getPixel(1, 1).r, greaterThan(250));
    // A short text is scaled up to a size messengers show at full width.
    expect(decoded.width, greaterThanOrEqualTo(900));

    // Untagged export stays a single PNG without the badge column.
    final png = await ImageExporter.exportToPng(
      glyphs: glyphs,
      style: const StyleParams(),
      backgroundColor: Colors.white,
    );
    final still = img.decodePng(png!)!;
    expect(
      still.width,
      ((90 + StickerLayout.padding * 2) * ImageExporter.maxScale).ceil(),
    );
  });

  test('the GIF plays the emoji\'s own motion', () async {
    final index = await EmojiIndex.load();
    final glyphs = await _glyphs(2);
    for (final kind in [EmojiMotionKind.pulse, EmojiMotionKind.wave]) {
      final base = index.tags.first;
      final tag = EmojiTag(
        id: base.id,
        style: base.style,
        emoji: base.emoji,
        name: base.name,
        asset: base.asset,
        motion: kind,
      );
      final gif = await ImageExporter.exportToGif(glyphs: glyphs, emoji: tag);
      final frames = img.decodeGif(gif!)!.frames;
      expect(frames, hasLength(EmojiMotion.gifFrames));
      // Frame 0 is at rest, a frame early in the loop is not.
      final a = frames[0], b = frames[3];
      var differ = 0;
      for (var y = 0; y < a.height; y += 4) {
        for (var x = a.width ~/ 2; x < a.width; x += 4) {
          if (a.getPixel(x, y) != b.getPixel(x, y)) differ++;
        }
      }
      expect(differ, greaterThan(20), reason: kind.name);
    }
  });

  testWidgets('the picker switches categories and offers recent emoji', (
    tester,
  ) async {
    late EmojiIndex index;
    await tester.runAsync(() async => index = await EmojiIndex.load());
    addTearDown(rootBundle.clear);
    final recent = [index.tags.last];
    final recentIds = [for (final t in recent) t.id];
    EmojiTag? picked;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('cs'),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => picked = await showEmojiPicker(
              context,
              index: index,
              recentIds: recentIds,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Opens on "Recent" when there is something recent.
    expect(find.byKey(const ValueKey('emoji-cat-recent')), findsOneWidget);
    expect(find.byKey(ValueKey('emoji-${recent.first.id}')), findsOneWidget);

    final cat = index.categories.first;
    final first = index.inCategory(cat.id).first;
    await tester.tap(find.byKey(ValueKey('emoji-cat-${cat.id}')));
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('emoji-${first.id}')), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('emoji-${first.id}')));
    await tester.pumpAndSettle();
    expect(picked, first);
  });

  test('styles: the first is free, each emoji knows its style', () async {
    final index = await EmojiIndex.load(bundle: _TwoStyleBundle());
    expect(index.styles.map((s) => s.id), ['paper', 'marker']);
    expect(index.defaultStyle.pack, isNull);
    expect(index.styleById('marker')?.pack, 'emoji_marker');
    final paper = index.inStyle('paper'), marker = index.inStyle('marker');
    expect(marker.length, (paper.length + 1) ~/ 2);
    expect(index.tags, paper);
    final id = marker.first.id;
    expect(index.byId(id)?.style, 'paper');
    expect(index.byId(id, style: 'marker')?.style, 'marker');
    // Same emoji, other style: a different tag.
    expect(index.byId(id), isNot(index.byId(id, style: 'marker')));
    expect(index.byId(paper[1].id, style: 'marker'), isNull);
  });

  testWidgets('the picker switches styles and marks locked ones', (
    tester,
  ) async {
    late EmojiIndex index;
    await tester.runAsync(
      () async => index = await EmojiIndex.load(bundle: _TwoStyleBundle()),
    );
    addTearDown(rootBundle.clear);
    final paper = index.tags;
    EmojiTag? picked;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('cs'),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => picked = await showEmojiPicker(
              context,
              index: index,
              // An odd one: not drawn in marker, so Recent empties there.
              recentIds: [paper[1].id],
              style: 'paper',
              isLocked: (s) => s.pack != null,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('emoji-styles')), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byKey(ValueKey('emoji-${paper[1].id}')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('emoji-style-marker')));
    await tester.pumpAndSettle();
    // Recent has nothing in marker: the first marker category opens.
    expect(find.byKey(const ValueKey('emoji-cat-recent')), findsNothing);
    final first = index.inStyle('marker').first;
    await tester.tap(find.byKey(ValueKey('emoji-${first.id}')));
    await tester.pumpAndSettle();
    expect(picked, first);
    expect(picked?.style, 'marker');
  });
}
