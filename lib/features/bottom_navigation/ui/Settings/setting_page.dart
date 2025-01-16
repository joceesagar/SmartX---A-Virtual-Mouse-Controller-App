import 'dart:collection';

import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

enum SingingCharacter { Index, Middle, Ring }

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];
typedef MenuEntry = DropdownMenuEntry<String>;

class _SettingsPageState extends State<SettingsPage> {
  double _currentSliderValue = 20;
  SingingCharacter? _character = SingingCharacter.Index;
  bool light = true;

  static final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(
    list.map<MenuEntry>((String name) => MenuEntry(value: name, label: name)),
  );
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Device Settings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                });
              }),
          const SizedBox(
            height: 20,
          ),
          const Text("Primary Click",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
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
                    });
                  }),
              const SizedBox(
                width: 20,
              ),
              const Text(
                "Mouse Acceleration",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Scroll Direction",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          DropdownMenu<String>(
              textStyle: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
              initialSelection: list.first,
              onSelected: (String? value) {
                setState(() {
                  // This is called when the user selects an item.
                  dropdownValue = value!;
                });
              },
              dropdownMenuEntries: menuEntries)
        ]),
      ),
    );
  }
}
