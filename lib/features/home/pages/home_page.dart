import 'package:flutter/material.dart';
import 'package:frontend/features/bottom_navigation/ui/Data/data_page.dart';
import 'package:frontend/features/bottom_navigation/ui/Info/info_page.dart';
import 'package:frontend/features/bottom_navigation/ui/Settings/setting_page.dart';
import 'package:frontend/features/bottom_navigation/ui/Shortcuts/shortcut_page.dart';

class HomePage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const HomePage(),
      );
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Tracks the selected index

  // Data for tabs: icons, labels, and corresponding pages
  final List<Map<String, dynamic>> _tabs = [
    {
      'icon': Icons.settings,
      'label': 'Settings',
      'page': const SettingsPage(),
    },
    {
      'icon': Icons.keyboard,
      'label': 'Shortcuts',
      'page': const ShortcutPage(),
    },
    {
      'icon': Icons.eco_rounded,
      'label': 'Data',
      'page': const DataPage(),
    },
    {
      'icon': Icons.info_outline,
      'label': 'Info',
      'page': const InfoPage(),
    },
  ];

  // Function to handle bottom navigation tab changes
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex]
          ['page'], // Display corresponding page based on index
      bottomNavigationBar: BottomNavigationBar(
        items: _tabs
            .map(
              (tab) => BottomNavigationBarItem(
                icon: Icon(tab['icon']),
                label: tab['label'],
              ),
            )
            .toList(), // Generate items dynamically based on the tabs data
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped, // Update selected tab on tap
      ),
    );
  }
}