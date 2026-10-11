import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'canvas_editor_screen.dart';
import 'grid_alignment_screen.dart';

/// Home screen with tab navigation between Text Editor and Grid Alignment
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const _screens = <Widget>[CanvasEditorScreen(), GridAlignmentScreen()];

  /// Grid Alignment prepares template scans for the extractor: a desktop
  /// tool, and on a phone its tab bar only takes room from the editor.
  static bool get _hasGridTool => switch (defaultTargetPlatform) {
    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.linux => !kIsWeb,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    if (!_hasGridTool) return const CanvasEditorScreen();
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.edit), label: 'Text Editor'),
          NavigationDestination(
            icon: Icon(Icons.grid_4x4),
            label: 'Grid Alignment',
          ),
        ],
      ),
    );
  }
}
