import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:frontend/core/services/ble_services/service_discovery.dart';
import 'package:frontend/features/home/pages/scan_page.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

part 'ble_state.dart';

class BleCubit extends Cubit<BleState> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  /// Observable list to store scanned BLE devices
  RxList<DiscoveredDevice> devices = <DiscoveredDevice>[].obs;

  BleCubit() : super(BleInitial());

  /// Requests necessary Bluetooth permissions
  Future<bool> _requestPermissions() async {
    print("Requesting Bluetooth Scan Permission...");
    bool scanGranted = await Permission.bluetoothScan.request().isGranted;
    print('Bluetooth Scan Permission granted: $scanGranted');

    print("Requesting Bluetooth Connect Permission...");
    bool connectGranted = await Permission.bluetoothConnect.request().isGranted;
    print('Bluetooth Connect Permission granted: $connectGranted');

    return scanGranted && connectGranted;
  }

  /// Checks if Bluetooth is enabled
  Future<bool> _isBluetoothOn() async {
    final statusStream = _ble.statusStream;

    // Listen to the status stream until Bluetooth is ready or an error state is encountered
    await for (final status in statusStream) {
      print('Bluetooth state: $status');

      // If Bluetooth is off or in an unauthorized state, emit an error and return false
      if (status == BleStatus.poweredOff ||
          status == BleStatus.unauthorized ||
          status == BleStatus.locationServicesDisabled) {
        emit(PermissionNotGranted()); // Emit a state for permission not granted
        return false; // Bluetooth is not on, return false and stop the loop
      }

      // Proceed only if the Bluetooth is ready
      if (status == BleStatus.ready) {
        return true; // Bluetooth is on, ready to proceed
      }
    }

    return false; // In case the loop ends without finding 'ready'
  }

  /// Scans for BLE devices
  Future<void> startScan() async {
    if (await _requestPermissions() && await _isBluetoothOn()) {
      emit(BleScanning()); // Show "Connecting" or "Scanning" status

      try {
        // Start scanning and store the subscription
        final subscription = _ble.scanForDevices(
            withServices: [], scanMode: ScanMode.lowLatency).listen(
          (device) {
            print('Devices Found $device');
            // Check if the device is already in the list
            if (!devices.any((d) => d.id == device.id)) {
              devices.add(device); // Add the new device to the list
            }
          },
          onError: (error) {
            emit(BleScanningError('Scan error: $error')); // Handle errors
          },
        );

        // Wait for the scan duration
        await Future.delayed(const Duration(seconds: 10));

        // Stop scanning after the timeout
        await subscription.cancel();
        _ble.deinitialize();

        // Check if any devices were found
        if (devices.isNotEmpty) {
          emit(BleScanSuccess(devices)); // Emit success with the device list
        } else {
          emit(BleNoDevicesFound()); // Emit "No Devices Found" state
        }

        print('Devices: $devices');
      } catch (error) {
        emit(
            BleScanningError('Scan error: $error')); // Handle unexpected errors
      }
    } else {
      emit(PermissionNotGranted());
    }
  }

  /// Connect to a device
  Future<void> connectToDevice(String deviceId) async {
    try {
      emit(BleConnecting());
      final connectionStream = _ble.connectToDevice(
        id: deviceId,
        connectionTimeout: const Duration(seconds: 2),
      );

      connectionStream.listen(
        (connectionState) {
          if (connectionState.connectionState ==
              DeviceConnectionState.connected) {
            emit(BleConnected(deviceId));
            Get.snackbar('Connected', 'Bluetooth Connected Successfully');
            Get.off(() => ServiceDiscoveryPage(deviceId: deviceId));
          } else if (connectionState.connectionState ==
              DeviceConnectionState.disconnected) {
            emit(BleDisconnected());
            Get.snackbar('Disconnected', 'Bluetooth Disconnected');
            Get.to(() => const ScanPage());
          }
        },
        onError: (error) {
          emit(BleError('Connection error: $error'));
        },
      );
    } catch (e) {
      emit(BleError('Failed to connect: $e'));
    }
  }

  @override
  Future<void> close() {
    _ble.deinitialize(); // Clean up resources when the cubit is disposed
    return super.close();
  }
}
