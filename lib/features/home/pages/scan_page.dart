import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubit/ble_cubit.dart';
import 'package:frontend/features/widgets/scanned_devices.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "MotionX",
          style: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.grey[850],
        surfaceTintColor: Colors.grey[850],
        elevation: 20,
        toolbarHeight: 65,
      ),
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Status: ",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
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
            ),
          ),
          BlocConsumer<BleCubit, BleState>(
            listener: (context, state) {
              if (state is BleError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is BleNoDevicesFound) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("No Devices Found. Try Again"),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is PermissionNotGranted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Bluetooth is not enabled. Please turn on your bluetooth"),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is BleScanSuccess) {
                Navigator.pushAndRemoveUntil(
                    context, ScannedDevices.route(), (_) => false);
              }
            },
            builder: (context, state) {
              if (state is BleScanning) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 250,
                      ),
                      Center(
                          child: CircularProgressIndicator(
                        color: Colors.white,
                      )),
                      SizedBox(
                        height: 10,
                      ),
                      Text("Scanning...",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                );
              }
              return Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: 350,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    Colors.grey[850],
                                  ),
                                  elevation: const WidgetStatePropertyAll(30),
                                  shadowColor: const WidgetStatePropertyAll(
                                      Colors.black)),
                              onPressed: () async {
                                // Trigger the scanning process
                                context.read<BleCubit>().startScan();
                              },
                              child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 35, vertical: 10),
                                  child: Text(
                                    'Scan',
                                    style: TextStyle(
                                        fontSize: 28,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ))),
                        ),
                        const SizedBox(
                            height:
                                10), // Add spacing between the image and the text
                        const Text(
                          "Please click here to scan for devices",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14, // Optional: adjust the font size
                              color: Colors.white),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
