import 'package:flutter/material.dart';

class GestureManualWidget extends StatelessWidget {
  GestureManualWidget({super.key});
  final List<GestureInfo> gestures = [
    GestureInfo(
      gifPath: 'assets/gifs/left_swipe.gif',
      title: 'Left Swipe',
      description: 'Swipe left to go back or dismiss an item.',
    ),
    GestureInfo(
      gifPath: 'assets/gifs/right_swipe.gif',
      title: 'Right Swipe',
      description: 'Swipe right to mark an item as done.',
    ),
    GestureInfo(
      gifPath: 'assets/gifs/left_click.gif',
      title: 'Left Click',
      description: 'Tap with index finger to select or interact with an item.',
    ),
    GestureInfo(
      gifPath: 'assets/gifs/scroll.gif',
      title: 'Scroll',
      description: 'Swipe up or down to navigate through the content.',
    ),
    GestureInfo(
      gifPath: 'assets/gifs/right_click.gif',
      title: 'Right Click',
      description: 'Tap with middle finger to select or interact with an item.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Gesture Guide',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[850],
        surfaceTintColor: Colors.grey[850],
        elevation: 20,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: gestures.length,
        itemBuilder: (context, index) {
          final gesture = gestures[index];
          return GestureCard(gesture: gesture);
        },
      ),
    );
  }
}

class GestureCard extends StatelessWidget {
  final GestureInfo gesture;

  const GestureCard({super.key, required this.gesture});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 20,
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 150,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  gesture.gifPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    gesture.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    gesture.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GestureInfo {
  final String gifPath;
  final String title;
  final String description;

  GestureInfo({
    required this.gifPath,
    required this.title,
    required this.description,
  });
}
