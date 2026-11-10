import 'package:flutter/material.dart';

import 'l10n/l10n.dart';
import 'screens/home_screen.dart';
import 'services/font_licenses.dart';

void main() {
  FontLicenses.register();
  runApp(const HandwrittenStickersApp());
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
      home: const HomeScreen(),
    );
  }
}
