import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ol1n_telemetry/ol1n_telemetry.dart';
import 'package:path_provider/path_provider.dart';

import 'l10n/l10n.dart';
import 'screens/home_screen.dart';
import 'services/entitlement_service.dart';
import 'services/font_licenses.dart';
import 'services/preset_store.dart';
import 'telemetry/telemetry_dictionary.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FontLicenses.register();
  unawaited(_startTelemetry());
  runApp(const HandwrittenStickersApp());
}

/// Anonymous usage statistics (`docs/telemetry.md`). Without
/// `TELEMETRY_KEY` and `TELEMETRY_HOST` this records and sends nothing.
Future<void> _startTelemetry() async {
  if (kIsWeb) return;
  final Directory dir;
  try {
    dir = await getApplicationSupportDirectory();
  } catch (e) {
    debugPrint('Telemetry: no support directory ($e), off');
    return;
  }
  await Telemetry.init(
    app: kTelemetryApp,
    appVersion: kAppVersion,
    dictionary: appDictionary,
    store: FileTelemetryStore('${dir.path}${Platform.pathSeparator}telemetry'),
    lang: () => resolveAppLocale(
      PlatformDispatcher.instance.locale,
      AppLocalizations.supportedLocales,
    ).languageCode,
    // Builds with a fake store (`HWS_PACKS`) are for trying things out.
    tester: EntitlementService.debugPacks.isNotEmpty,
    // Presets, the last editor state or purchases from before measuring.
    hadDataBefore: () => [
      PresetStore.presetsFile,
      PresetStore.editorStateFile,
      EntitlementService.cacheFile,
    ].any((f) => File('${dir.path}${Platform.pathSeparator}$f').existsSync()),
  );
}

class HandwrittenStickersApp extends StatelessWidget {
  const HandwrittenStickersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handwritten Stickers',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: resolveAppLocale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      navigatorObservers: [TelemetryNavigatorObserver(kScreenRoutes)],
      home: const HomeScreen(),
    );
  }
}
