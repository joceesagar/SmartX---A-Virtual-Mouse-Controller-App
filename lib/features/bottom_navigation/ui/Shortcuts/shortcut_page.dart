import 'package:flutter/material.dart';

class ShortcutPage extends StatefulWidget {
  const ShortcutPage({super.key});

  @override
  State<ShortcutPage> createState() => _ShortcutPageState();
}

class _ShortcutPageState extends State<ShortcutPage> {
  // Map of shortcuts with their controllers and default values
  final Map<String, Map<String, dynamic>> _shortcuts = {
    "swipeUp": {
      "primaryIcon": Icons.arrow_upward_rounded,
      "primaryIconLabel": "Swipe Up",
      "controller": TextEditingController(),
      "shortcutValue": "",
    },
    "swipeDown": {
      "primaryIcon": Icons.arrow_downward_rounded,
      "primaryIconLabel": "Swipe Down",
      "controller": TextEditingController(),
      "shortcutValue": "",
    },
    "swipeLeft": {
      "primaryIcon": Icons.arrow_back,
      "primaryIconLabel": "Swipe Left",
      "controller": TextEditingController(),
      "shortcutValue": "",
    },
    "swipeRight": {
      "primaryIcon": Icons.arrow_forward,
      "primaryIconLabel": "Swipe Right",
      "controller": TextEditingController(),
      "shortcutValue": "",
    },
    "tap": {
      "primaryIcon": Icons.touch_app_rounded,
      "primaryIconLabel": "Tap",
      "controller": TextEditingController(),
      "shortcutValue": "",
    },
  };

  @override
  void dispose() {
    // Dispose all controllers when the page is disposed
    _shortcuts.forEach((key, value) {
      value['controller'].dispose();
      print(value['shortcutValue']);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Keyboard Shortcuts",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black38, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.back_hand_outlined,
                        color: Colors.black,
                        size: 26,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Gesture Shortcuts",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  const Text(
                    "Configure keyboard shortcuts for gestures",
                    style: TextStyle(
                        color: Colors.black38, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _shortcuts.length,
                      itemBuilder: (context, index) {
                        String key = _shortcuts.keys.elementAt(index);
                        var shortcut = _shortcuts[key]!;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    shortcut['primaryIcon'],
                                    color: Colors.black38,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    shortcut['primaryIconLabel'],
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.keyboard,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: TextField(
                                      controller: shortcut['controller'],
                                      decoration: InputDecoration(
                                        hintText: shortcut['shortcutValue']
                                                .toString()
                                                .isEmpty
                                            ? 'Enter a key'
                                            : shortcut['shortcutValue']
                                                .toString(),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                        border: const OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          shortcut['shortcutValue'] = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
