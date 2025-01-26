import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/auth/cubit/ble_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

Future<String?> connectedDeviceId() async {
  final deviceID = await SpService().getConnectedDeviceId();
  return deviceID;
}

final characteristic = QualifiedCharacteristic(
  deviceId: "48:27:E2:D3:13:DD",
  serviceId:
      Uuid.parse("785e99cc-e61f-41b0-899e-f59fa295441a"), // Dynamic service ID
  characteristicId: Uuid.parse(
      "7fb99b10-d067-42f2-99f4-b515e595c91c"), // Dynamic characteristic ID
);

final List<String> keyList = [
  'sliderValue',
  'mouseAcceleration',
  'scrollDirection',
  'primaryClick'
];

void writeToBle(BuildContext context) {
  context.read<BleCubit>().subscribeAndWrite(keyList);
}

enum SingingCharacter { Index, Middle, Ring }

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];
typedef MenuEntry = DropdownMenuEntry<String>;

class _SettingsPageState extends State<SettingsPage> {
  final spService = SpService();

  // Variables defined with late keyword without initial values
  late double _currentSliderValue;
  late SingingCharacter? _character;
  late bool light;
  late String dropdownValue;
  bool isLoading = true; // Track loading state

  static final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(
    list.map<MenuEntry>((String name) => MenuEntry(value: name, label: name)),
  );

  Future<void> initializeDefaults() async {
    await spService.initializeDefaults();
  }

  @override
  void initState() {
    super.initState();
    initializeDefaults();
    _loadInitialValues();
  }

  // Load values from SharedPreferences

// Load values from SharedPreferences
  Future<void> _loadInitialValues() async {
    try {
      // Retrieving values using SpService
      final sliderValue = await spService.getValue('sliderValue');
      final mouseAcceleration = await spService.getValue('mouseAcceleration');
      final scrollDirection = await spService.getValue('scrollDirection');
      final primaryClick = await spService.getValue('primaryClick');

      // Use `setState` once values are fetched and ready
      if (mounted) {
        setState(() {
          _currentSliderValue = double.parse(sliderValue);
          light = (mouseAcceleration.toLowerCase() == "true");
          dropdownValue = scrollDirection;

          switch (primaryClick) {
            case 'Middle':
              _character = SingingCharacter.Middle;
              break;
            case 'Ring':
              _character = SingingCharacter.Ring;
              break;
            default:
              _character = SingingCharacter.Index;
          }

          // After the values are set, turn off the loading indicator
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading initial values: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Device Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Show loading indicator while fetching data
          if (isLoading) const Center(child: CircularProgressIndicator()),

          // Once data is loaded, show the settings UI
          if (!isLoading) ...[
            Text("Update Rate: ${_currentSliderValue}Hz",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
            Slider(
                value: _currentSliderValue,
                max: 100,
                divisions: 5,
                label: _currentSliderValue.round().toString(),
                inactiveColor: Colors.grey,
                onChanged: (double value) {
                  setState(() {
                    _currentSliderValue = value;
                    spService.updateKeyValue(
                        'sliderValue', _currentSliderValue.toString());
                  });
                }),
            const SizedBox(
              height: 20,
            ),
            const Text("Primary Click",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
            ListTile(
              title: const Text(
                'Index',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              leading: Radio<SingingCharacter>(
                value: SingingCharacter.Index,
                groupValue: _character,
                onChanged: (SingingCharacter? value) {
                  setState(() {
                    _character = value;
                    spService.updateKeyValue(
                        'primaryClick', _character.toString().split('.').last);
                  });
                },
              ),
            ),
            ListTile(
              title: const Text(
                'Middle',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              leading: Radio<SingingCharacter>(
                value: SingingCharacter.Middle,
                groupValue: _character,
                onChanged: (SingingCharacter? value) {
                  setState(() {
                    _character = value;
                    spService.updateKeyValue(
                        'primaryClick', _character.toString().split('.').last);
                  });
                },
              ),
            ),
            ListTile(
              title: const Text(
                'Ring',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              leading: Radio<SingingCharacter>(
                value: SingingCharacter.Ring,
                groupValue: _character,
                onChanged: (SingingCharacter? value) {
                  setState(() {
                    _character = value;
                    spService.updateKeyValue(
                        'primaryClick', _character.toString().split('.').last);
                  });
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Switch(
                    // This bool value toggles the switch.
                    value: light,
                    activeTrackColor: Colors.grey,
                    inactiveTrackColor: Colors.white,
                    onChanged: (bool value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        light = value;
                        spService.updateKeyValue(
                            'mouseAcceleration', light.toString());
                      });
                    }),
                const SizedBox(
                  width: 20,
                ),
                const Text(
                  "Mouse Acceleration",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Scroll Direction",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            DropdownMenu<String>(
                textStyle: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
                initialSelection: list.first,
                onSelected: (String? value) {
                  setState(() {
                    // This is called when the user selects an item.
                    dropdownValue = value!;
                    spService.updateKeyValue('scrollDirection', dropdownValue);
                  });
                },
                dropdownMenuEntries: menuEntries),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  writeToBle(context);
                },
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.grey[200]),
                    shadowColor: const WidgetStatePropertyAll(Colors.black),
                    elevation: const WidgetStatePropertyAll(10)),
                child: const Text(
                  "Apply Changes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ),
            )
          ]
        ]),
      ),
    );
  }
}
