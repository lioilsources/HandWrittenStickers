// The checks of ol1n_telemetry's test kit (dictionary ↔ doc, no free text,
// version constant ↔ pubspec, no key → no network, off → nothing, literal
// event names), plus the app's catalogues ↔ its assets.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:handwritten_stickers/telemetry/telemetry_dictionary.dart';
import 'package:ol1n_telemetry/ol1n_telemetry.dart';
import 'package:ol1n_telemetry/testing.dart';

Map<String, dynamic> _json(String path) =>
    json.decode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('docs/telemetry.md lists exactly the dictionary', () {
    expect(
      telemetryDocProblems(
        appDictionary,
        File('../docs/telemetry.md').readAsStringSync(),
      ),
      isEmpty,
    );
  });

  test('no property is free text', () {
    expect(telemetryDictionaryProblems(appDictionary), isEmpty);
  });

  test('app version matches pubspec.yaml', () {
    expect(
      telemetryVersionProblems(
        kAppVersion,
        File('pubspec.yaml').readAsStringSync(),
      ),
      isEmpty,
    );
  });

  test('the code sends only dictionary events, and every one of them', () {
    expect(telemetryTrackCallProblems(appDictionary), isEmpty);
  });

  test('no key, no network', () async {
    expect(await telemetryNoKeyProblems(appDictionary), isEmpty);
  }, skip: const bool.fromEnvironment('TELEMETRY_DEBUG'));

  test('off means nothing', () async {
    expect(await telemetryOffProblems(appDictionary), isEmpty);
  });

  group('catalogues match the assets', () {
    test('sheet ids = assets/glyphs/sheets.json', () {
      final ids = {
        for (final s in _json('assets/glyphs/sheets.json')['sheets'] as List)
          (s as Map)['id'] as String,
      };
      expect(kSheetIds, ids);
    });

    test('pack ids = assets/packs/packs.json', () {
      final ids = {
        for (final p in _json('assets/packs/packs.json')['packs'] as List)
          (p as Map)['id'] as String,
      };
      expect(kPackIds, ids);
    });

    test('built-in preset ids = assets/presets/presets.json', () {
      final ids = {
        for (final p in _json('assets/presets/presets.json')['presets'] as List)
          ((p as Map)['id'] as String).replaceFirst('builtin:', ''),
      };
      expect(kBuiltInPresetIds, ids);
    });
  });

  group('value mapping', () {
    test('unknown ids become other, never the raw value', () {
      expect(telemetrySheet('caveat'), 'caveat');
      expect(telemetrySheet('my own sheet'), 'other');
      expect(telemetrySheet(null), 'other');
      expect(telemetryPack(null), 'free');
      expect(telemetryPack('kids'), 'kids');
      expect(telemetryPack('future_pack'), 'other');
      expect(telemetryPreset(id: null, builtIn: false), 'none');
      expect(telemetryPreset(id: 'builtin:neat', builtIn: true), 'neat');
      // The user's own presets carry a name the user typed: never sent.
      expect(telemetryPreset(id: 'user:abc', builtIn: false), 'user');
    });
  });

  group('app events validate', () {
    late FakeSink sink;

    setUp(() async {
      Telemetry.resetForTest();
      sink = FakeSink();
      await Telemetry.init(
        app: kTelemetryApp,
        appVersion: kAppVersion,
        dictionary: appDictionary,
        store: MemoryTelemetryStore(),
        lang: () => 'cs',
        sink: sink,
        startTimer: false,
        observeLifecycle: false,
      );
    });

    tearDown(Telemetry.resetForTest);

    test('an export, a paywall and a purchase are recorded', () async {
      final export = Telemetry.flow('export', {
        'target': 'gallery',
        'animated': true,
        'sheet': telemetrySheet('kid_bubble_mint'),
        'category': 'kids',
        'pack': telemetryPack('kids'),
        'preset': telemetryPreset(id: 'builtin:kid_note', builtIn: true),
        'modified': false,
        'chars': 12,
      });
      export.end('ok', {'target': 'gallery', 'animated': true});
      Telemetry.activation();
      final paywall = Telemetry.flow('paywall', {
        'pack': 'kids',
        'source': 'export',
      });
      final purchase = Telemetry.flow('purchase', {'pack': 'kids'});
      purchase.end('pending', {'pack': 'kids'});
      paywall.end('cancel', {'pack': 'kids', 'source': 'export'});
      Telemetry.track('purchases_restore', {'from': 'packs', 'owned': 1});
      Telemetry.lockedTap('kids');
      Telemetry.screen('grid');

      final names = Telemetry.debugQueue.map((e) => e.name).toList();
      expect(
        names,
        containsAll([
          'export_start',
          'export_end',
          'activation',
          'paywall_start',
          'purchase_start',
          'purchase_end',
          'paywall_end',
          'purchases_restore',
          'locked_tap',
        ]),
      );
    });
  });
}
