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
  deviceId: "48:27:E2:D3:14:01",
  serviceId: Uuid.parse("785e99cc-e61f-41b0-899e-f59fa295441a"),
  characteristicId: Uuid.parse("7fb99b10-d067-42f2-99f4-b515e595c91c"),
);

final List<String> keyList = ['Type', 'SN', 'HO', 'HM'];
void writeToBle(BuildContext context) async {
  context.read<BleCubit>().subscribeAndWrite(keyList);
}

enum SingingCharacter {
  Normal,
  Strong,
}

class _SettingsPageState extends State<SettingsPage> {
  final spService = SpService();

  late int _gestureSensitivityValue;
  late SingingCharacter? _character;
  late bool value1;
  bool isLoading = true;

  Future<void> initializeDefaults() async {
    await spService.initializeDefaults();
  }

  @override
  void initState() {
    super.initState();
    initializeDefaults();
    _loadInitialValues();
  }

  Future<void> _loadInitialValues() async {
    try {
      final sliderValue1 = await spService.getValue('SN');
      final hapticFeedback = await spService.getValue('HO');
      final mode = await spService.getValue('HM');
      final type = await spService.getValue('Type');
      if (type == 'G') {
        spService.updateKeyValue('Type', 'N');
      }

      if (mounted) {
        setState(() {
          _gestureSensitivityValue = int.parse(sliderValue1);
          value1 = (hapticFeedback.toLowerCase() ==
              "true"); //returns true if default value is true otherwise false

          switch (mode) {
            case '0':
              _character = SingingCharacter.Normal;
              break;
            default:
              _character = SingingCharacter.Strong;
          }

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
            "General Settings",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.grey[850],
          surfaceTintColor: Colors.grey[850],
          elevation: 20,
        ),
        backgroundColor: Colors.grey[900], // Lighter black background
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : ListView(
                  children: [
                    _buildCard(
                      title:
                          "Sensitivity: ${_gestureSensitivityValue.round()}Hz",
                      child: Slider(
                        value: _gestureSensitivityValue.toDouble(),
                        max: 100,
                        min: 30,
                        divisions: 8,
                        label: _gestureSensitivityValue.round().toString(),
                        inactiveColor: Colors.grey.shade700,
                        activeColor: Colors.blueAccent,
                        thumbColor: Colors.blue,
                        onChanged: (double value) {
                          setState(() {
                            _gestureSensitivityValue = value.toInt();
                            spService.updateKeyValue(
                                'SN', _gestureSensitivityValue.toString());
                          });
                        },
                      ),
                    ),
                    _buildCard(
                      title: "Haptic Feedback",
                      child: SwitchListTile(
                        title: const Text("Enable Vibration",
                            style: TextStyle(color: Colors.white)),
                        value: value1,
                        activeColor: Colors.blueAccent,
                        inactiveThumbColor: Colors.grey.shade600,
                        onChanged: (bool value) {
                          setState(() {
                            value1 = value;
                            spService.updateKeyValue('HO', value1.toString());
                          });
                        },
                      ),
                    ),
                    _buildCard(
                      title: "Haptic Feedback Mode",
                      child: IgnorePointer(
                        ignoring: !value1,
                        child: Opacity(
                          opacity: value1 ? 1.0 : 0.5,
                          child: Column(
                            children: SingingCharacter.values
                                .map(
                                  (character) =>
                                      RadioListTile<SingingCharacter>(
                                    title: Text(character.name,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    value: character,
                                    groupValue: _character,
                                    activeColor: Colors.blueAccent,
                                    onChanged: (SingingCharacter? value) {
                                      setState(() {
                                        _character = value;
                                        spService.updateKeyValue(
                                            'HM',
                                            _character
                                                        .toString()
                                                        .split('.')
                                                        .last ==
                                                    "Normal"
                                                ? 0
                                                : 1);
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () => writeToBle(context),
                        style: ElevatedButton.styleFrom(
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          backgroundColor: Colors.grey[850],
                        ),
                        child: const Text(
                          "Apply Changes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ));
  }
}

Widget _buildCard({required String title, required Widget child}) {
  return Card(
    elevation: 20, // Strong elevation
    shadowColor: Colors.black, // Shadow
    color: Colors.grey[850], // Black card
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    ),
  );
}
