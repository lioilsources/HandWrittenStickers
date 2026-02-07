import 'package:flutter/material.dart';

import 'screens/canvas_editor_screen.dart';

void main() {
  runApp(const HandwrittenStickersApp());
}

class HandwrittenStickersApp extends StatelessWidget {
  const HandwrittenStickersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handwritten Stickers',
      debugShowCheckedModeBanner: false,
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
      home: const CanvasEditorScreen(),
    );
  }
}
