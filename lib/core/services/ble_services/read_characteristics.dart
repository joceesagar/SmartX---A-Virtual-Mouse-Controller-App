import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ReadCharacteristicsPage extends StatelessWidget {
  final String deviceId;
  final Uuid serviceUuid;
  final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();

  ReadCharacteristicsPage(
      {super.key, required this.deviceId, required this.serviceUuid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Read Characteristics')),
      body: FutureBuilder<List<int>>(
        future: flutterReactiveBle.readCharacteristic(
          QualifiedCharacteristic(
            serviceId: serviceUuid,
            characteristicId:
                Uuid.parse(serviceUuid.toString()), // Replace with actual UUID
            deviceId: deviceId,
          ),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No characteristics found'));
          }

          // Extract the characteristic data
          final characteristic = snapshot
              .data!.first; // Assuming one characteristic for simplicity

          return Center(
            child: Text('Characteristic Value: $characteristic'),
          );
        },
      ),
    );
  }
}
