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

  static const _screens = <Widget>[
    CanvasEditorScreen(),
    GridAlignmentScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit),
            label: 'Text Editor',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_4x4),
            label: 'Grid Alignment',
          ),
        ],
      ),
    );
  }
}
