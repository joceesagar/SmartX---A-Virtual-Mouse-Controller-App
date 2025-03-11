import 'dart:async';
import 'dart:convert';

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
  late Object hand;
  double x = 0, y = 0, z = 0;
  double rotationX = 0, rotationY = 0, rotationZ = 0;

  // Stream subscription for BLE position updates
  StreamSubscription<Map<String, double>>? _positionStreamSubscription;
  StreamSubscription? _bleCharacteristicSubscription;
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  @override
  void initState() {
    super.initState();
    hand = Object(fileName: 'assets/hand.obj'); // 3D hand model
    hand.scale.setValues(
        4.0, 4.0, 4.0); // Increase the size of the hand by scaling it

    // Start listening to BLE
    startListeningToBle();
  }

  void startListeningToBle() {
    print("Function has been called. Waiting for data...");
    final bleCubit = context.read<BleCubit>();
    final characteristic = bleCubit.characteristic; // Get the characteristic

    _bleCharacteristicSubscription =
        _ble.subscribeToCharacteristic(characteristic).listen((data) {
      print("Received Data: $data");
      String decodedData = String.fromCharCodes(data);
      print("Received Decoded Data: $decodedData");

      try {
        Map<String, dynamic> jsonData = jsonDecode(decodedData);
        double xr = (jsonData['XR'] as num).toDouble();
        double yr = (jsonData['YR'] as num).toDouble();
        double zr = (jsonData['ZR'] as num).toDouble();
        if (mounted) {
          setState(() {
            rotationX = xr;
            rotationY = yr;
            rotationZ = zr;
            hand.rotation.setValues(rotationX, rotationY, rotationZ);
            hand.updateTransform();
          });
        }
      } catch (e) {
        print("Error parsing JSON: $e");
      }
    }, onError: (dynamic error) {
      print("Error: $error");
    });
  }

  // void startListeningToBle() {
  //   print("Function has been called. Waiting for data...");
  //   context.read<BleCubit>().readFromBle();

  //   // Listen to the BLE position stream
  //   _positionStreamSubscription =
  //       context.read<BleCubit>().positionStream.listen((position) {
  //     if (mounted) {
  //       updateHandRotation(position['XR']!, position['YR']!, position['ZR']!);
  //     }
  //   });
  // }

  void updateHandPosition(double newX, double newY, double newZ) {
    if (mounted) {
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
  }

  void updateHandRotation(
      double newRotationX, double newRotationY, double newRotationZ) {
    if (mounted) {
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
  }

  @override
  void dispose() {
    // Cancel the stream subscription when the widget is disposed
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null; // Prevent potential memory leaks
    _bleCharacteristicSubscription!.cancel();
    super.dispose();
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
          // Expanded(
          //   child: SingleChildScrollView(
          //     child: Padding(
          //       padding: const EdgeInsets.only(top: 10),
          //       child: Column(
          //         children: [
          //           buildSlider("X Position", x, -5, 5, (value) {
          //             updateHandPosition(value, y, z);
          //           }),
          //           buildSlider("Y Position", y, -5, 5, (value) {
          //             updateHandPosition(x, value, z);
          //           }),
          //           buildSlider("Z Position", z, -5, 5, (value) {
          //             updateHandPosition(x, y, value);
          //           }),
          //           buildSlider("Rotation X", rotationX, -180, 180, (value) {
          //             updateHandRotation(value, rotationY, rotationZ);
          //           }),
          //           buildSlider("Rotation Y", rotationY, -180, 180, (value) {
          //             updateHandRotation(rotationX, value, rotationZ);
          //           }),
          //           buildSlider("Rotation Z", rotationZ, -180, 180, (value) {
          //             updateHandRotation(rotationX, rotationY, value);
          //           }),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
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
          divisions: 100,
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
