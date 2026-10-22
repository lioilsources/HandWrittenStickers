import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/screens/canvas_editor_screen.dart';
import 'package:handwritten_stickers/services/entitlement_service.dart';
import 'package:handwritten_stickers/services/preset_store.dart';
import 'package:handwritten_stickers/services/purchases/purchase_backend.dart';

const _p = 'com.ol1n.handwrittenStickers.pack.';

void main() {
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
  }

  late FakePurchaseBackend backend;
  late EntitlementService entitlements;

  Future<void> open(WidgetTester tester) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(402, 1400) * 3;
    addTearDown(tester.view.reset);
    addTearDown(rootBundle.clear);
    backend = FakePurchaseBackend(prices: EntitlementService.fakePrices);
    entitlements = EntitlementService.fake(backend);
    await tester.pumpWidget(
      MaterialApp(
        home: CanvasEditorScreen(
          presetStore: PresetStore.inMemory(),
          entitlements: entitlements,
        ),
      ),
    );
    for (var i = 0; i < 100 && find.byType(TextField).evaluate().isEmpty; i++) {
      await settle(tester);
    }
    await tester.enterText(find.byType(TextField), 'Ahoj');
    await settle(tester);
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await settle(tester);
    await tester.pumpAndSettle();
  }

  testWidgets('free sheets export without asking', (tester) async {
    await open(tester);
    expect(find.byKey(const ValueKey('locked-badge')), findsNothing);
    await tap(tester, find.byTooltip('Save to Gallery'));
    expect(find.byKey(const ValueKey('paywall-buy')), findsNothing);
  });

  testWidgets('a pack sheet previews for free, export offers the pack', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, find.text('Baloo 2'));
    expect(find.byKey(const ValueKey('locked-badge')), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);

    await tap(tester, find.byTooltip('Save to Gallery'));
    expect(find.text('Pro děti'), findsWidgets);
    expect(find.text('Koupit za 25 Kč'), findsOneWidget);
    expect(find.byKey(const ValueKey('paywall-buy-all')), findsOneWidget);

    await tap(tester, find.byKey(const ValueKey('paywall-buy')));
    expect(backend.bought, ['${_p}kids']);
    expect(find.byKey(const ValueKey('paywall-buy')), findsNothing);
    expect(find.byKey(const ValueKey('locked-badge')), findsNothing);
  });

  testWidgets('cancelling the paywall keeps the pack locked', (tester) async {
    await open(tester);
    await tap(tester, find.byKey(const ValueKey('preset-builtin:kid_note')));
    expect(find.byKey(const ValueKey('locked-badge')), findsOneWidget);
    await tap(tester, find.byTooltip('Share'));
    backend.nextOutcome = PurchaseEventKind.cancelled;
    await tap(tester, find.byKey(const ValueKey('paywall-buy')));
    expect(find.byKey(const ValueKey('paywall-buy')), findsOneWidget);
    expect(entitlements.ownsPack('kids'), isFalse);
  });

  testWidgets('saving a preset needs the presets pack', (tester) async {
    await open(tester);
    await tap(tester, find.byKey(const ValueKey('preset-save')));
    expect(find.text('Vlastní presety'), findsOneWidget);
    expect(find.byKey(const ValueKey('preset-name')), findsNothing);

    await tap(tester, find.byKey(const ValueKey('paywall-buy')));
    expect(backend.bought, ['${_p}presets']);
    // Bought: the name dialog follows right away.
    expect(find.byKey(const ValueKey('preset-name')), findsOneWidget);
  });

  testWidgets('the bundle is not offered after two packs', (tester) async {
    await open(tester);
    entitlements.buy('poster');
    entitlements.buy('materials');
    await tester.pump();
    expect(entitlements.offerAll, isFalse);
    await tap(tester, find.text('Baloo 2'));
    await tap(tester, find.byTooltip('Save to Gallery'));
    expect(find.byKey(const ValueKey('paywall-buy')), findsOneWidget);
    expect(find.byKey(const ValueKey('paywall-buy-all')), findsNothing);
  });

  testWidgets('restore in the pack list unlocks what was bought', (
    tester,
  ) async {
    await open(tester);
    backend.owned.add('${_p}calligraphy');
    await tap(tester, find.byKey(const ValueKey('open-packs')));
    expect(find.byKey(const ValueKey('pack-calligraphy')), findsOneWidget);
    expect(find.text('Vlastníš'), findsNothing);
    await tap(tester, find.byKey(const ValueKey('packs-restore')));
    expect(entitlements.ownsPack('calligraphy'), isTrue);
    expect(find.text('Vlastníš'), findsOneWidget);
  });
}
