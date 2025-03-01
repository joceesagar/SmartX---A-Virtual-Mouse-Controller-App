import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:frontend/features/auth/cubit/ble_cubit.dart';

class VirtualHandScreen extends StatefulWidget {
  const VirtualHandScreen({super.key});

  @override
  VirtualHandScreenState createState() => VirtualHandScreenState();
}

class VirtualHandScreenState extends State<VirtualHandScreen> {
  void startListeningToBle() {
    print("Funtion has been Called waiting for data.....");
    context.read<BleCubit>().readFromBle();
  }

  late Object hand;
  double x = 0, y = 0, z = 0;
  double rotationX = 0, rotationY = 0, rotationZ = 0;

  @override
  void initState() {
    super.initState();
    hand = Object(fileName: 'assets/hand.obj'); // 3D hand model
    hand.scale.setValues(
        4.0, 4.0, 4.0); // Increase the size of the hand by scaling it

    // Start listening to BLE

    startListeningToBle();
  }

  void updateHandPosition(double newX, double newY, double newZ) {
    setState(() {
      x = newX;
      y = newY;
      z = newZ;
      print("X: $x");
      print("Y: $y");
      print("Z: $z");
      hand.position.setValues(x, y, z);
      hand.updateTransform();
    });
  }

  void updateHandRotation(
      double newRotationX, double newRotationY, double newRotationZ) {
    setState(() {
      rotationX = newRotationX;
      rotationY = newRotationY;
      rotationZ = newRotationZ;
      print("Rotation X: $rotationX");
      print("Rotation Y: $rotationY");
      print("Rotation Z: $rotationZ");
      hand.rotation.setValues(rotationX, rotationY, rotationZ);
      hand.updateTransform();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: const Text(
          "Virtual Hand Tracker",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[850],
        surfaceTintColor: Colors.grey[850],
        elevation: 20,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[900], // Set the background color for the scene
              child: Cube(
                onSceneCreated: (Scene scene) {
                  scene.world.add(hand);
                  scene.update(); // Refresh the scene
                },
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    buildSlider("X Position", x, -5, 5, (value) {
                      updateHandPosition(value, y, z);
                    }),
                    buildSlider("Y Position", y, -5, 5, (value) {
                      updateHandPosition(x, value, z);
                    }),
                    buildSlider("Z Position", z, -5, 5, (value) {
                      updateHandPosition(x, y, value);
                    }),
                    buildSlider("Rotation X", rotationX, -180, 180, (value) {
                      updateHandRotation(value, rotationY, rotationZ);
                    }),
                    buildSlider("Rotation Y", rotationY, -180, 180, (value) {
                      updateHandRotation(rotationX, value, rotationZ);
                    }),
                    buildSlider("Rotation Z", rotationZ, -180, 180, (value) {
                      updateHandRotation(rotationX, rotationY, value);
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 20,
          label: value.toStringAsFixed(2),
          inactiveColor: Colors.grey.shade700,
          activeColor: Colors.blueAccent,
          thumbColor: Colors.blue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
