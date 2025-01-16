import 'package:flutter/material.dart';
import 'package:frontend/features/home/pages/scan_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      // Check if the widget is still mounted
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ScanPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(
        // Center the children vertically and horizontally
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the content vertically
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center the content horizontally
          children: [
            Image(
              image: AssetImage('assets/icons/Splash_Logo.png'),
            ),
            SizedBox(height: 20), // Add spacing between the image and the text
            Text(
              "A touchless virtual mouse",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20, // Optional: adjust the font size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
