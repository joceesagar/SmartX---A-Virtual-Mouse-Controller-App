import 'package:flutter/material.dart';
import 'package:frontend/core/services/ble_services/read_characteristics.dart';
import 'package:get/get.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ServiceDiscoveryPage extends StatefulWidget {
  final String deviceId;
  final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();

  ServiceDiscoveryPage({super.key, required this.deviceId});

  @override
  ServiceDiscoveryPageState createState() => ServiceDiscoveryPageState();
}

class ServiceDiscoveryPageState extends State<ServiceDiscoveryPage> {
  late Future<List<Service>> _servicesFuture;
  bool isServicesDiscovered = false; // Track whether services are discovered

  @override
  void initState() {
    super.initState();
    // Initialize the service discovery process
    _servicesFuture = _discoverServices();
  }

  // Function to discover services asynchronously
  Future<List<Service>> _discoverServices() async {
    try {
      // First, discover all services
      await widget.flutterReactiveBle.discoverAllServices(widget.deviceId);
      // Then, get the discovered services
      final services = await widget.flutterReactiveBle
          .getDiscoveredServices(widget.deviceId);
      setState(() {
        isServicesDiscovered = true; // Mark discovery as complete
      });
      return services;
    } catch (e) {
      // Handle error if service discovery fails
      setState(() {
        isServicesDiscovered = false; // Mark discovery as failed
      });
      throw Exception('Failed to discover services: $e');
    }
  }

  // Map of known services and their names
  final Map<String, String> serviceNames = {
    '00001800-0000-1000-8000-00805f9b34fb': 'GAP Service',
    '00001801-0000-1000-8000-00805f9b34fb': 'GATT Service',
    '00001802-0000-1000-8000-00805f9b34fb': 'Immediate Alert Service',
    '00001803-0000-1000-8000-00805f9b34fb': 'Link Loss Service',
    '00001804-0000-1000-8000-00805f9b34fb': 'Tx Power Service',
    '00001805-0000-1000-8000-00805f9b34fb': 'Current Time Service',
    '00001806-0000-1000-8000-00805f9b34fb': 'Reference Time Update Service',
    '00001807-0000-1000-8000-00805f9b34fb': 'Next DST Change Service',
    '00001808-0000-1000-8000-00805f9b34fb': 'Glucose Service',
    '00001809-0000-1000-8000-00805f9b34fb': 'Health Thermometer Service',
    '0000180A-0000-1000-8000-00805f9b34fb': 'Device Information Service',
    '0000180D-0000-1000-8000-00805f9b34fb': 'Heart Rate Service',
    '0000180E-0000-1000-8000-00805f9b34fb': 'Phone Alert Status Service',
    '0000180F-0000-1000-8000-00805f9b34fb': 'Battery Service',
    '00001810-0000-1000-8000-00805f9b34fb': 'Blood Pressure Service',
    '00001811-0000-1000-8000-00805f9b34fb': 'Alert Notification Service',
    '00001812-0000-1000-8000-00805f9b34fb': 'Human Interface Device Service',
    '00001813-0000-1000-8000-00805f9b34fb': 'Scan Parameters Service',
    '00001814-0000-1000-8000-00805f9b34fb': 'Running Speed and Cadence Service',
    '00001815-0000-1000-8000-00805f9b34fb': 'Automation IO Service',
    '00001816-0000-1000-8000-00805f9b34fb': 'Cycling Speed and Cadence Service',
    '00001818-0000-1000-8000-00805f9b34fb': 'Cycling Power Service',
    '00001819-0000-1000-8000-00805f9b34fb': 'Location and Navigation Service',
    '0000181A-0000-1000-8000-00805f9b34fb': 'Environmental Sensing Service',
    '0000181B-0000-1000-8000-00805f9b34fb': 'Body Composition Service',
    '0000181C-0000-1000-8000-00805f9b34fb': 'User Data Service',
    '0000181D-0000-1000-8000-00805f9b34fb': 'Weight Scale Service',
    '0000181E-0000-1000-8000-00805f9b34fb': 'Bond Management Service',
    '0000181F-0000-1000-8000-00805f9b34fb':
        'Continuous Glucose Monitoring Service',
    '00001820-0000-1000-8000-00805f9b34fb': 'Internet Protocol Support Service',
    '00001821-0000-1000-8000-00805f9b34fb': 'Indoor Positioning Service',
    '00001822-0000-1000-8000-00805f9b34fb': 'Pulse Oximeter Service',
    '00001823-0000-1000-8000-00805f9b34fb': 'HTTP Proxy Service',
    '00001824-0000-1000-8000-00805f9b34fb': 'Transport Discovery Service',
    '00001825-0000-1000-8000-00805f9b34fb': 'Object Transfer Service',
    '00001826-0000-1000-8000-00805f9b34fb': 'Fitness Machine Service',
    '00001827-0000-1000-8000-00805f9b34fb': 'Mesh Provisioning Service',
    '00001828-0000-1000-8000-00805f9b34fb': 'Mesh Proxy Service',
    '00001829-0000-1000-8000-00805f9b34fb':
        'Reconnection Configuration Service',
    '0000183A-0000-1000-8000-00805f9b34fb': 'Insulin Delivery Service',
    '0000183B-0000-1000-8000-00805f9b34fb': 'Binary Sensor Service',
    '0000183C-0000-1000-8000-00805f9b34fb': 'Emergency Configuration Service',
    '0000183D-0000-1000-8000-00805f9b34fb': 'Authorization Control Service',
    '0000183E-0000-1000-8000-00805f9b34fb': 'Physical Activity Monitor Service',
    '0000183F-0000-1000-8000-00805f9b34fb': 'Elapsed Time Service',
    '00001840-0000-1000-8000-00805f9b34fb': 'Generic Health Sensor Service',
    '00001843-0000-1000-8000-00805f9b34fb': 'Audio Input Control Service',
    '00001844-0000-1000-8000-00805f9b34fb': 'Volume Control Service',
    '00001845-0000-1000-8000-00805f9b34fb': 'Volume Offset Control Service',
    '00001846-0000-1000-8000-00805f9b34fb':
        'Coordinated Set Identification Service',
    '00001847-0000-1000-8000-00805f9b34fb': 'Device Time Service',
    '00001848-0000-1000-8000-00805f9b34fb': 'Media Control Service',
    '00001849-0000-1000-8000-00805f9b34fb': 'Generic Media Control Service',
    '0000184A-0000-1000-8000-00805f9b34fb': 'Constant Tone Extension Service',
    '0000184B-0000-1000-8000-00805f9b34fb': 'Telephone Bearer Service',
    '0000184C-0000-1000-8000-00805f9b34fb': 'Generic Telephone Bearer Service',
    '0000184D-0000-1000-8000-00805f9b34fb': 'Microphone Control Service',
    '0000184E-0000-1000-8000-00805f9b34fb': 'Audio Stream Control Service',
    '0000184F-0000-1000-8000-00805f9b34fb': 'Broadcast Audio Scan Service',
    '00001850-0000-1000-8000-00805f9b34fb':
        'Published Audio Capabilities Service',
    '00001851-0000-1000-8000-00805f9b34fb': 'Basic Audio Announcement Service',
    '00001852-0000-1000-8000-00805f9b34fb':
        'Broadcast Audio Announcement Service',
    '00001853-0000-1000-8000-00805f9b34fb': 'Common Audio Service',
    '00001854-0000-1000-8000-00805f9b34fb': 'Hearing Access Service',
    '00001855-0000-1000-8000-00805f9b34fb': 'Telephony and Media Audio Service',
    '00001856-0000-1000-8000-00805f9b34fb':
        'Public Broadcast Announcement Service',
    '00001857-0000-1000-8000-00805f9b34fb': 'Electronic Shelf Label Service',
    '00001858-0000-1000-8000-00805f9b34fb': 'Gaming Audio Service',
    '00001859-0000-1000-8000-00805f9b34fb': 'Mesh Proxy Solicitation Service',
    '0000185A-0000-1000-8000-00805f9b34fb':
        'Industrial Measurement Device Service',
    '0000185B-0000-1000-8000-00805f9b34fb': 'Ranging Service',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Service Discovery',
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
      body: isServicesDiscovered
          ? FutureBuilder<List<Service>>(
              future: _servicesFuture, // Future is now assigned properly
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
                    final serviceName =
                        serviceNames[service.id.toString()] ?? 'Custom Service';
                    print(service.characteristics);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      elevation: 5,
                      child: ListTile(
                        title: Text(serviceName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('UUID: ${service.id}'),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to the characteristic reading page for the selected service
                                Get.to(() => ReadCharacteristicsPage(
                                      deviceId: widget.deviceId,
                                      serviceUuid: service.id,
                                      characteristics: service.characteristics,
                                    ));
                              },
                              child: const Text('View Characteristics'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : const Center(
              child:
                  CircularProgressIndicator(), // Loading spinner when waiting
            ),
    );
  }
}
