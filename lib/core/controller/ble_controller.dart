import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:frontend/core/services/ble_services/service_discovery.dart';
import 'package:frontend/features/home/pages/scan_page.dart';
import 'package:frontend/features/widgets/scanned_devices.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

/// Controller to manage Bluetooth Low Energy (BLE) operations
class BleController extends GetxController {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  /// Observable to track scanning state
  RxBool isScanning = false.obs;

  /// Observable list to store scanned BLE devices
  RxList<DiscoveredDevice> scannedDevices = <DiscoveredDevice>[].obs;

  /// Observable to track connection state
  RxBool isConnected = false.obs;

  /// Observable to track connected device id
  RxString connectedDeviceId = ''.obs;

  /// Observable to track connecting state
  RxBool isConnecting = false.obs;

  /// Requests necessary Bluetooth permissions
  Future<bool> _requestPermissions() async {
    bool scanGranted = await Permission.bluetoothScan.request().isGranted;
    bool connectGranted = await Permission.bluetoothConnect.request().isGranted;
    print('Bluetooth Scan Permission granted: $scanGranted');
    print('Bluetooth Connect Permission granted: $connectGranted');
    return scanGranted && connectGranted;
  }

  /// Checks if Bluetooth is enabled
  Future<bool> _isBluetoothOn() async {
    final status = await _ble.statusStream.first;
    print('Bluetooth state: $status');
    if (status == BleStatus.ready) {
      return true;
    } else {
      return false;
    }
  }

  /// Scans for BLE devices
  Future<void> scanDevices() async {
    if (await _requestPermissions() && await _isBluetoothOn()) {
      isScanning.value = true; // Set scanning state to true

      // Start scanning
      _ble.scanForDevices(
          withServices: [], scanMode: ScanMode.lowLatency).listen(
        (device) {
          // Check if the device is already in the list
          if (!scannedDevices.any((d) => d.id == device.id)) {
            scannedDevices.add(device); // Add the new device to the list
          }
        },
        onError: (error) {
          print('Scan error: $error');
        },
      );

      // Stop scanning manually after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        if (isScanning.value) {
          _ble.deinitialize();

          if (scannedDevices.isNotEmpty) {
            // Navigate to ScannedDevices page if
            Get.to(() => ScannedDevices());
          } else {
            // Show SnackBar if no devices are found
            ScaffoldMessenger.of(Get.context!).showSnackBar(
              const SnackBar(
                content: Text("No Devices Found. Please Try Again"),
              ),
            );
          }

          isScanning.value = false; // Reset scanning state
        }
      });
    } else {
      isScanning.value = false;
      Get.snackbar("Bluetooth Off", "Please turn on your bluetooth",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  ///Connect to a device
  Future<void> connectToDevice(String deviceId) async {
    try {
      /// Observable to track connecting state

      isConnecting.value = true; // Show connecting progress
      final connectionStream = _ble.connectToDevice(
        id: deviceId,
        connectionTimeout: const Duration(seconds: 2),
      );

      /// Update connection state when connection state changes
      connectionStream.listen(
        (connectionState) {
          if (connectionState.connectionState ==
              DeviceConnectionState.connected) {
            isConnecting.value = false;
            isConnected.value = true;
            connectedDeviceId.value = deviceId;
            Get.snackbar('Connected', 'Bluetooth Connected Successfully');
            Get.off(
                () => ServiceDiscoveryPage(deviceId: connectedDeviceId.value));
          } else if (connectionState.connectionState ==
              DeviceConnectionState.disconnected) {
            isConnecting.value = false;
            isConnected.value = false;
            connectedDeviceId.value = '';
            Get.snackbar('Disconnected', 'Bluetooth Disconnected',
                snackPosition: SnackPosition.BOTTOM);
            Get.to(() => const ScanPage());
          }
        },
        onError: (error) {
          isConnecting.value = false;
          isConnected.value = false;
          Get.snackbar('Error', 'Connection failed: $error',
              snackPosition: SnackPosition.BOTTOM);
        },
      );
    } catch (e) {
      isConnected.value = false;
      isConnecting.value = false;
      Get.snackbar('Error', 'Failed to connect: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    _ble.deinitialize(); // Ensure BLE resources are released when the controller is disposed
    super.onClose();
  }
}
