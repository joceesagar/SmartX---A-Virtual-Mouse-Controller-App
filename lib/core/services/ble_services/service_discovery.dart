import 'package:flutter/material.dart';
import 'package:frontend/core/services/ble_services/read_characteristics.dart';
import 'package:get/get.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ServiceDiscoveryPage extends StatelessWidget {
  final String deviceId;
  final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();

  ServiceDiscoveryPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Discovery')),
      body: FutureBuilder<List<Service>>(
        future: flutterReactiveBle.getDiscoveredServices(deviceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No services found'));
          }

          final services = snapshot.data!;
          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ListTile(
                title: Text('Service UUID: ${service.id}'),
                onTap: () {
                  // Navigate to the characteristic reading page for the selected service
                  Get.to(() => ReadCharacteristicsPage(
                        deviceId: deviceId,
                        serviceUuid: service.id,
                      ));
                },
              );
            },
          );
        },
      ),
    );
  }
}
