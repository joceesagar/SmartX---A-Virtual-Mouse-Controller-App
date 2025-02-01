import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/auth/cubit/ble_cubit.dart';

class CustomizationPage extends StatefulWidget {
  const CustomizationPage({super.key});

  @override
  State<CustomizationPage> createState() => _CustomizationPage();
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

enum SingingCharacter { Index, Middle, Ring }

enum ScrollGesture { IndexMiddle, MiddleRing, IndexRing }

class _CustomizationPage extends State<CustomizationPage> {
  final spService = SpService();

  late double _scrollSpeedValue;
  late SingingCharacter? _character1;
  late SingingCharacter? _character2;
  late SingingCharacter? _character3;
  late ScrollGesture? _character4;

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
      final sliderValue = await spService.getValue('scrollSpeed');
      final leftClickMode = await spService.getValue('leftClick');
      final rightClickMode = await spService.getValue('rightClick');
      final doubleClickMode = await spService.getValue('doubleClick');
      final scrollGestureMode = await spService.getValue('scrollGesture');
      // final primaryClick = await spService.getValue('primaryClick');

      if (mounted) {
        setState(() {
          _scrollSpeedValue = double.parse(sliderValue);

          switch (leftClickMode) {
            case 'Index':
              _character1 = SingingCharacter.Index;
              break;
            case 'Ring':
              _character1 = SingingCharacter.Ring;
              break;
            default:
              _character1 = SingingCharacter.Middle;
          }

          switch (rightClickMode) {
            case 'Index':
              _character2 = SingingCharacter.Index;
              break;
            case 'Ring':
              _character2 = SingingCharacter.Ring;
              break;
            default:
              _character2 = SingingCharacter.Middle;
          }

          switch (doubleClickMode) {
            case 'Index':
              _character3 = SingingCharacter.Index;
              break;
            case 'Ring':
              _character3 = SingingCharacter.Ring;
              break;
            default:
              _character3 = SingingCharacter.Middle;
          }

          switch (scrollGestureMode) {
            case 'IndexMiddle':
              _character4 = ScrollGesture.IndexMiddle;
              break;
            case 'MiddleRing':
              _character4 = ScrollGesture.MiddleRing;
              break;
            default:
              _character4 = ScrollGesture.IndexRing;
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
          "Button & Finger Customization",
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
                    title: "Left Click",
                    child: Column(
                      children: SingingCharacter.values
                          .map(
                            (character) => RadioListTile<SingingCharacter>(
                              title: Text(character.name),
                              value: character,
                              groupValue: _character1,
                              activeColor: Colors.blueAccent,
                              onChanged: (SingingCharacter? value) {
                                setState(() {
                                  _character1 = value;
                                  spService.updateKeyValue('leftClick',
                                      _character1.toString().split('.').last);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _buildCard(
                    title: "Right Click",
                    child: Column(
                      children: SingingCharacter.values
                          .map(
                            (character) => RadioListTile<SingingCharacter>(
                              title: Text(character.name),
                              value: character,
                              groupValue: _character2,
                              activeColor: Colors.blueAccent,
                              onChanged: (SingingCharacter? value) {
                                setState(() {
                                  _character2 = value;
                                  spService.updateKeyValue('rightClick',
                                      _character2.toString().split('.').last);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _buildCard(
                    title: "Double Click",
                    child: Column(
                      children: SingingCharacter.values
                          .map(
                            (character) => RadioListTile<SingingCharacter>(
                              title: Text(character.name),
                              value: character,
                              groupValue: _character3,
                              activeColor: Colors.blueAccent,
                              onChanged: (SingingCharacter? value) {
                                setState(() {
                                  _character3 = value;
                                  spService.updateKeyValue('doubleClick',
                                      _character3.toString().split('.').last);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _buildCard(
                    title: "Scroll Gesture",
                    child: Column(
                      children: ScrollGesture.values
                          .map(
                            (character) => RadioListTile<ScrollGesture>(
                              title: Text(character.name),
                              value: character,
                              groupValue: _character4,
                              activeColor: Colors.blueAccent,
                              onChanged: (ScrollGesture? value) {
                                setState(() {
                                  _character4 = value;
                                  spService.updateKeyValue('scrollGesture',
                                      _character4.toString().split('.').last);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _buildCard(
                    title: "Scroll Speed: ${_scrollSpeedValue.round()}Hz",
                    child: Slider(
                      value: _scrollSpeedValue,
                      max: 100,
                      divisions: 5,
                      label: _scrollSpeedValue.round().toString(),
                      inactiveColor: Colors.grey.shade300,
                      activeColor: Colors.blueAccent,
                      thumbColor: Colors.blue,
                      onChanged: (double value) {
                        setState(() {
                          _scrollSpeedValue = value;
                          spService.updateKeyValue(
                              'scrollSpeed', _scrollSpeedValue.toString());
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
