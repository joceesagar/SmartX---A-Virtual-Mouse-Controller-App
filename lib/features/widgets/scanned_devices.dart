import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:frontend/features/auth/cubit/ble_cubit.dart';

class ScannedDevices extends StatelessWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const ScannedDevices(),
      );
  const ScannedDevices({super.key});

  @override
  Widget build(BuildContext context) {
    final bleCubit = context.read<BleCubit>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        elevation: 20,
        title: Column(
          children: [
            const Text(
              'Scanned BLE Devices',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Status: ",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                BlocBuilder<BleCubit, BleState>(
                  builder: (context, state) {
                    if (state is BleConnected) {
                      return const Text("Connected",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold));
                    } else if (state is BleConnecting) {
                      return const Text("Connecting...",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold));
                    } else {
                      return const Text("Disconnected",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: BlocBuilder<BleCubit, BleState>(
        builder: (context, state) {
          // Directly accessing devices from BleScanSuccess state
          final devices = context.read<BleCubit>().devices;
          if (state is BleScanning) {
            return const Expanded(
                child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: CircularProgressIndicator()),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Scanning...",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ));
          }

          return Column(
            children: [
              SizedBox(
                height: 590,
                width: double.infinity,
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shadowColor: Colors.black,
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.name.isNotEmpty
                                        ? device.name
                                        : 'Unnamed Device',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ID: ${device.id}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('RSSI: ${device.rssi}'),
                                  (device.connectable == Connectable.available)
                                      ? const Text(
                                          'Connectable',
                                          style: TextStyle(color: Colors.green),
                                        )
                                      : const Text(
                                          'Not Connectable',
                                          style: TextStyle(color: Colors.red),
                                        )
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Trigger device connection
                                  bleCubit.connectToDevice(device.id);
                                },
                                style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        Colors.grey[200]),
                                    shadowColor: const WidgetStatePropertyAll(
                                        Colors.black),
                                    elevation:
                                        const WidgetStatePropertyAll(10)),
                                child: const Text(
                                  "Connect",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  width: 150,
                  height: 60,
                  child: ElevatedButton(
                      key: const Key("Refresh"),
                      onPressed: () async {
                        // Trigger the scanning process
                        context.read<BleCubit>().startScan();
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.grey[200]),
                          shadowColor:
                              const WidgetStatePropertyAll(Colors.black),
                          elevation: const WidgetStatePropertyAll(10)),
                      child: const Row(
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Refresh",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      )),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
