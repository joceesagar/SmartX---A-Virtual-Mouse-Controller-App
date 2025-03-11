import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/cubit/ble_cubit.dart';
import 'package:frontend/features/auth/pages/login_page.dart';
import 'package:frontend/features/auth/pages/signup_page.dart';
import 'package:frontend/features/bottom_navigation/ui/Data/data_page.dart';
import 'package:frontend/features/bottom_navigation/ui/Info/info_page.dart';
import 'package:frontend/features/bottom_navigation/ui/Settings/setting_page.dart';
import 'package:frontend/features/bottom_navigation/ui/UserGuide/user_guide.dart';
import 'package:frontend/features/widgets/scanned_devices.dart';

class HomePage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const HomePage(),
      );
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late BleCubit _bleCubit;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bleCubit = context.read<BleCubit>();
      _bleCubit.monitorConnection();
    });
  }

  @override
  void dispose() {
    // Stop monitoring connection when the HomePage is disposed
    _bleCubit.stopMonitoringConnection(); // Use the stored instance
    super.dispose();
  }

  int _selectedIndex = 0; // Tracks the selected index

  // Data for tabs: icons, labels, and corresponding pages
  final List<Map<String, dynamic>> _tabs = [
    {
      'icon': Icons.settings,
      'label': 'Settings',
      'page': const SettingsPage(),
    },
    {
      'icon': Icons.lightbulb_outline,
      'label': 'Gesture Manual',
      // 'page': const CustomizationPage(),
      'page': GestureManualWidget(),
    },
    {
      'icon': Icons.tv,
      'label': 'Visualization',
      'page': const VirtualHandScreen(),
    },
    {
      'icon': Icons.info_outline,
      'label': 'Info',
      'page': InfoPage(),
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
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, authState) {
      print("[AUTHDEBUG] Auth state: ${authState.runtimeType}");

      // If the user is not logged in, show the LoginPage
      if (authState is AuthInitial) {
        return const SignupPage();
      }

      // If the user is logged in, show the HomePage with bottom navigation
      return BlocBuilder<BleCubit, BleState>(builder: (context, bleState) {
        print("[BLEDEBUG] BLE state: ${bleState.runtimeType}");

        // If BLE is disconnected, show the ScannedDevices page
        if (bleState is BleConnected) {
          return Scaffold(
            body: _tabs[_selectedIndex]
                ['page'], // Display corresponding page based on index
            bottomNavigationBar: BottomNavigationBar(
              items: _tabs
                  .map(
                    (tab) => BottomNavigationBarItem(
                        icon: Icon(tab['icon']),
                        label: tab['label'],
                        backgroundColor: Colors.grey[850]),
                  )
                  .toList(), // Generate items dynamically based on the tabs data
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.amber[800],
              unselectedItemColor: Colors.white,
              onTap: _onItemTapped, // Update selected tab on tap
            ),
          );
        } else if (bleState is BleWriting) {
          return Scaffold(
              appBar: AppBar(
                title: const Text(
                  "General Settings",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.grey[850],
                surfaceTintColor: Colors.grey[850],
                elevation: 20,
              ),
              backgroundColor: Colors.grey[900],
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 70,
                    ),
                    Center(
                        child: CircularProgressIndicator(
                      color: Colors.white,
                    )),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Writing updates. Please wait......",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
              ));
        }
        return const ScannedDevices();
      });
    });
  }
}
