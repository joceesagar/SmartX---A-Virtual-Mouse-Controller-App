import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/cubit/ble_cubit.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final service = SpService();
  String? guestName;
  String? guestId;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    guestName = await service.getGuestName();
    guestId = await service.getGuestId();
    setState(() {}); // Update the UI after fetching data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          "Device Info",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[850],
        surfaceTintColor: Colors.grey[850],
        elevation: 20,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection("Device Name", "MotionX"),
            _buildInfoSection("Device ID", "48:27:E2:D3:13:DD"),
            _buildInfoSection("MAC Address", "00:1A:7D:DA:71:13"),
            _buildInfoSection("User Name", guestName.toString()),
            _buildInfoSection("User ID", guestId.toString()),
            const SizedBox(height: 20),
            _buildActionButton("Disconnect", Colors.red, () {
              // Add Disconnect functionality here
              context.read<BleCubit>().disconnectDevice();
            }),
            const SizedBox(height: 5),
            _buildActionButton("Logout", Colors.red, () {
              // Add Logout functionality here
              context.read<AuthCubit>().logout(context.read<BleCubit>());
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String value) {
    return SingleChildScrollView(
      child: Card(
        color: Colors.grey[850],
        elevation: 20,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white60, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
