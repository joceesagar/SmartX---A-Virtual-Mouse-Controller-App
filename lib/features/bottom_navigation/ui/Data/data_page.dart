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
  // void startListeningToBle(QualifiedCharacteristic characteristic) {
  //   context.read<BleCubit>().readFromBle(characteristic).listen((data) {
  //     print("Received BLE Data: $data");

  //     // Check if the data is in the expected format: "x:1.2 y:2.3 z:3.4"
  //     List<String> parts = data.split(' '); // Split by space
  //     if (parts.length == 3) {
  //       // Attempt to parse x, y, and z values
  //       double newX = double.tryParse(parts[0].split(':')[1]) ?? 0.0;
  //       double newY = double.tryParse(parts[1].split(':')[1]) ?? 0.0;
  //       double newZ = double.tryParse(parts[2].split(':')[1]) ?? 0.0;
  //       print("NewX: $newX");
  //       print("NewY: $newY");
  //       print("NewZ: $newZ");

  //       // Update the hand's rotation with parsed values
  //       updateHandPosition(newX, newY, newZ);
  //     } else {
  //       // Handle invalid format or data
  //       print("Invalid data format received: $data");
  //     }
  //   }, onError: (error) {
  //     print("BLE Read Error: $error");
  //   });
  // }

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
      appBar: AppBar(
        title: const Text(
          "Virtual Hand Tracker",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.blueGrey, // Set the background color for the scene
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
        ],
      ),
    );
  }

  Widget buildSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Column(
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 20,
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
