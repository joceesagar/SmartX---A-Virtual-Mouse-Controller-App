import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:convert'; // For UTF-8 decoding

class ReadCharacteristicsPage extends StatefulWidget {
  final String deviceId;
  final Uuid serviceUuid;
  final List<Characteristic> characteristics;
  final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();

  ReadCharacteristicsPage({
    super.key,
    required this.deviceId,
    required this.serviceUuid,
    required this.characteristics,
  });

  @override
  ReadCharacteristicsPageState createState() => ReadCharacteristicsPageState();
}

class ReadCharacteristicsPageState extends State<ReadCharacteristicsPage> {
  // Map of known characteristic UUIDs and their names
  final Map<String, String> characteristicNames = {
    '00002a00-0000-1000-8000-00805f9b34fb': 'Device Name',
    '00002a01-0000-1000-8000-00805f9b34fb': 'Appearance',
    '00002a02-0000-1000-8000-00805f9b34fb':
        'Peripheral Preferred Connection Parameters',
    '00002a03-0000-1000-8000-00805f9b34fb': 'Service Changed',
    '00002a04-0000-1000-8000-00805f9b34fb': 'Client Supported Features',
    '00002a05-0000-1000-8000-00805f9b34fb': 'Server Supported Features',
    '00002a06-0000-1000-8000-00805f9b34fb': 'Date Time',
    '00002a07-0000-1000-8000-00805f9b34fb': 'Day of Week',
    '00002a08-0000-1000-8000-00805f9b34fb': 'Day Date Time',
    '00002a09-0000-1000-8000-00805f9b34fb': 'Time Zone',
    '00002a0a-0000-1000-8000-00805f9b34fb': 'Local Time Information',
    '00002a0c-0000-1000-8000-00805f9b34fb': 'Time Accuracy',
    '00002a0d-0000-1000-8000-00805f9b34fb': 'Time Source',
    '00002a0e-0000-1000-8000-00805f9b34fb': 'Reference Time Information',
    '00002a11-0000-1000-8000-00805f9b34fb': 'Alert Status',
    '00002a12-0000-1000-8000-00805f9b34fb': 'Ringer Control Point',
    '00002a13-0000-1000-8000-00805f9b34fb': 'Ringer Setting',
    '00002a14-0000-1000-8000-00805f9b34fb': 'Notification Control Point',
    '00002a15-0000-1000-8000-00805f9b34fb': 'Alert Category ID',
    '00002a16-0000-1000-8000-00805f9b34fb': 'Alert Category ID Bitmask',
    '00002a17-0000-1000-8000-00805f9b34fb': 'Alert Notification Control Point',
    '00002a18-0000-1000-8000-00805f9b34fb': 'Alert Notification Setting',
    '00002a19-0000-1000-8000-00805f9b34fb': 'Battery Level',
    '00002a1c-0000-1000-8000-00805f9b34fb': 'Blood Pressure Measurement',
    '00002a1d-0000-1000-8000-00805f9b34fb':
        'Blood Pressure Measurement Context',
    '00002a1e-0000-1000-8000-00805f9b34fb': 'Intermediate Cuff Pressure',
    '00002a21-0000-1000-8000-00805f9b34fb': 'Temperature Measurement',
    '00002a22-0000-1000-8000-00805f9b34fb': 'Temperature Measurement Context',
    '00002a23-0000-1000-8000-00805f9b34fb': 'Measurement Interval',
    '00002a24-0000-1000-8000-00805f9b34fb': 'Boot Keyboard Input Report',
    '00002a25-0000-1000-8000-00805f9b34fb': 'Boot Keyboard Output Report',
    '00002a26-0000-1000-8000-00805f9b34fb': 'Boot Mouse Input Report',
    '00002a27-0000-1000-8000-00805f9b34fb': 'Glucose Measurement',
    '00002a28-0000-1000-8000-00805f9b34fb': 'Glucose Measurement Context',
    '00002a29-0000-1000-8000-00805f9b34fb': 'Blood Oxygen Saturation',
    '00002a2a-0000-1000-8000-00805f9b34fb': 'Body Temperature Measurement',
    '00002a2b-0000-1000-8000-00805f9b34fb':
        'Body Temperature Measurement Context',
    '00002a2c-0000-1000-8000-00805f9b34fb': 'Heart Rate Measurement',
    '00002a2d-0000-1000-8000-00805f9b34fb': 'Heart Rate Measurement Context',
    '00002a2e-0000-1000-8000-00805f9b34fb': 'Measurement Interval',
    '00002a2f-0000-1000-8000-00805f9b34fb': 'Fitness Machine Feature',
    '00002a30-0000-1000-8000-00805f9b34fb': 'Fitness Machine Status',
    '00002a31-0000-1000-8000-00805f9b34fb': 'Oxygen Saturation',
    '00002a32-0000-1000-8000-00805f9b34fb': 'Respiratory Rate Measurement',
    '00002a33-0000-1000-8000-00805f9b34fb':
        'Respiratory Rate Measurement Context',
    '00002a34-0000-1000-8000-00805f9b34fb': 'Heart Rate Control Point',
    '00002a35-0000-1000-8000-00805f9b34fb': 'Body Composition Measurement',
    '00002a36-0000-1000-8000-00805f9b34fb':
        'Body Composition Measurement Context',
    '00002a37-0000-1000-8000-00805f9b34fb': 'Weight Measurement',
    '00002a38-0000-1000-8000-00805f9b34fb': 'Weight Measurement Context',
    '00002a39-0000-1000-8000-00805f9b34fb': 'Pressure Measurement',
    '00002a3a-0000-1000-8000-00805f9b34fb': 'Pressure Measurement Context',
    '00002a3b-0000-1000-8000-00805f9b34fb': 'Heart Rate Variability',
    '00002a3c-0000-1000-8000-00805f9b34fb':
        'Body Composition Measurement Feature',
    '00002a3d-0000-1000-8000-00805f9b34fb': 'User Data',
    '00002a3e-0000-1000-8000-00805f9b34fb': 'System ID',
    '00002a3f-0000-1000-8000-00805f9b34fb': 'Model Number String',
    '00002a40-0000-1000-8000-00805f9b34fb': 'Serial Number String',
    '00002a41-0000-1000-8000-00805f9b34fb': 'Firmware Revision String',
    '00002a42-0000-1000-8000-00805f9b34fb': 'Hardware Revision String',
    '00002a43-0000-1000-8000-00805f9b34fb': 'Software Revision String',
    '00002a44-0000-1000-8000-00805f9b34fb': 'Manufacturer Name String',
    '00002a45-0000-1000-8000-00805f9b34fb':
        'IEEE 11073-20601 Regulatory Certification Data List',
    '00002a46-0000-1000-8000-00805f9b34fb': 'Current Time',
    '00002a47-0000-1000-8000-00805f9b34fb': 'Magnetic Flux Density',
    '00002a48-0000-1000-8000-00805f9b34fb': 'Ambient Temperature',
    '00002a49-0000-1000-8000-00805f9b34fb': 'Location and Speed',
    '00002a4a-0000-1000-8000-00805f9b34fb': 'Pressure',
  };

  String? _characteristicValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Read Characteristics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.characteristics.length,
        itemBuilder: (context, index) {
          final characteristic = widget.characteristics[index];
          final characteristicName =
              characteristicNames[characteristic.id.toString()] ??
                  'Custom Characteristic';

          return Card(
            color: Colors.grey[50],
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            elevation: 5,
            child: ListTile(
              title: Text(
                characteristicName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('UUID: ${characteristic.id}'),
                  characteristic.isReadable
                      ? const Text(
                          'Readable: True',
                          style: TextStyle(color: Colors.green),
                        )
                      : const Text(
                          'Readable: False',
                          style: TextStyle(color: Colors.red),
                        ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Read the selected characteristic
                        try {
                          final characteristicData = await widget
                              .flutterReactiveBle
                              .readCharacteristic(
                            QualifiedCharacteristic(
                              serviceId: widget.serviceUuid,
                              characteristicId: characteristic.id,
                              deviceId: widget.deviceId,
                            ),
                          );

                          // Decode the byte data to string (UTF-8)
                          print('Characyeristics: $characteristicData');
                          String valueString = utf8.decode(characteristicData);

                          // Update the characteristic value in state
                          setState(() {
                            _characteristicValue = valueString;
                          });

                          // Show the characteristic value in a dialog
                          _showCharacteristicDialog();
                        } catch (e) {
                          // Handle the error
                          print('Error reading characteristic: $e');
                        }
                      },
                      child: const Text('Read Characteristics'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Show the dialog after reading the characteristic
  void _showCharacteristicDialog() {
    if (_characteristicValue != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Characteristic Value'),
          content: Text('Value: $_characteristicValue'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
