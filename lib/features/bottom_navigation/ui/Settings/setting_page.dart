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
  serviceId: Uuid.parse("785e99cc-e61f-41b0-899e-f59fa295441a"),
  characteristicId: Uuid.parse("7fb99b10-d067-42f2-99f4-b515e595c91c"),
);

final List<String> keyList = [
  'gestureSensitivity',
  'mouseAcceleration',
  'scrollDirection',
  'primaryClick',
  'pointerSpeed'
];

void writeToBle(BuildContext context) {
  context.read<BleCubit>().subscribeAndWrite(keyList);
}

enum SingingCharacter {
  Smooth,
  Raw,
}

class _SettingsPageState extends State<SettingsPage> {
  final spService = SpService();

  late double _gestureSensitivityValue;
  late double _pointerSpeedValue;
  late SingingCharacter? _character;
  late bool value1;
  late bool value2;
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
      final sliderValue1 = await spService.getValue('gestureSensitivity');
      final sliderValue2 = await spService.getValue('pointerSpeed');
      final vibrationFeedback = await spService.getValue('vibrationFeedback');
      final invertCursorMovement =
          await spService.getValue('invertCursorMovement');
      final mode = await spService.getValue('trackingMode');
      // final primaryClick = await spService.getValue('primaryClick');

      if (mounted) {
        setState(() {
          _gestureSensitivityValue = double.parse(sliderValue1);
          _pointerSpeedValue = double.parse(sliderValue2);
          value1 = (vibrationFeedback.toLowerCase() ==
              "true"); //returns true if default value is true otherwise false
          value2 = (invertCursorMovement.toLowerCase() == "true");

          switch (mode) {
            case 'smooth':
              _character = SingingCharacter.Smooth;
              break;
            default:
              _character = SingingCharacter.Raw;
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
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  _buildCard(
                    title: "Sensitivity: ${_gestureSensitivityValue.round()}Hz",
                    child: Slider(
                      value: _gestureSensitivityValue,
                      max: 100,
                      divisions: 5,
                      label: _gestureSensitivityValue.round().toString(),
                      inactiveColor: Colors.grey.shade300,
                      activeColor: Colors.blueAccent,
                      thumbColor: Colors.blue,
                      onChanged: (double value) {
                        setState(() {
                          _gestureSensitivityValue = value;
                          spService.updateKeyValue('gestureSensitivity',
                              _gestureSensitivityValue.toString());
                        });
                      },
                    ),
                  ),
                  _buildCard(
                    title: "Tracking Mode",
                    child: Column(
                      children: SingingCharacter.values
                          .map(
                            (character) => RadioListTile<SingingCharacter>(
                              title: Text(character.name),
                              value: character,
                              groupValue: _character,
                              activeColor: Colors.blueAccent,
                              onChanged: (SingingCharacter? value) {
                                setState(() {
                                  _character = value;
                                  spService.updateKeyValue('trackingMode',
                                      _character.toString().split('.').last);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _buildCard(
                    title: "Pointer Speed: ${_pointerSpeedValue.round()}Hz",
                    child: Slider(
                      value: _pointerSpeedValue,
                      max: 100,
                      divisions: 5,
                      label: _pointerSpeedValue.round().toString(),
                      inactiveColor: Colors.grey.shade300,
                      activeColor: Colors.blueAccent,
                      thumbColor: Colors.blue,
                      onChanged: (double value) {
                        setState(() {
                          _pointerSpeedValue = value;
                          spService.updateKeyValue(
                              'pointerSpeed', _pointerSpeedValue.toString());
                        });
                      },
                    ),
                  ),
                  _buildCard(
                    title: "Vibration Feedback",
                    child: SwitchListTile(
                      title: const Text("Enable Vibration"),
                      value: value1,
                      activeColor: Colors.blueAccent,
                      inactiveThumbColor: Colors.grey.shade400,
                      onChanged: (bool value) {
                        setState(() {
                          value1 = value;
                          spService.updateKeyValue(
                              'vibrationFeedback', value1.toString());
                        });
                      },
                    ),
                  ),
                  _buildCard(
                    title: "Invert CursorMovement",
                    child: SwitchListTile(
                      title: const Text("Invert Movement"),
                      value: value2,
                      activeColor: Colors.blueAccent,
                      inactiveThumbColor: Colors.grey.shade400,
                      onChanged: (bool value) {
                        setState(() {
                          value2 = value;
                          spService.updateKeyValue(
                              'invertCursorMovement', value2.toString());
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => writeToBle(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        backgroundColor: Colors.green,
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
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
