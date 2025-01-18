import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:frontend/core/services/ble_services/service_discovery.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/home/pages/options_page.dart';
import 'package:frontend/features/home/pages/scan_page.dart';
import 'package:frontend/features/widgets/scanned_devices.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

part 'ble_state.dart';

class BleCubit extends Cubit<BleState> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  /// Observable list to store scanned BLE devices
  RxList<DiscoveredDevice> devices = <DiscoveredDevice>[].obs;

  /// To store the currently connected device ID
  String? _connectedDeviceId;

  BleCubit() : super(BleInitial()) {
    _checkForPreviousConnection();
  }

  /// Check for a previously connected device on app start
  Future<void> _checkForPreviousConnection() async {
    final prefs = SpService();
    _connectedDeviceId = await prefs.getConnectedDeviceId();
    if (await _requestPermissions() && await _isBluetoothOn()) {
      if (_connectedDeviceId != null) {
        await _reconnectToDevice(_connectedDeviceId!);
      }
    } else {
      emit(PermissionNotGranted());
    }
  }

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

        // Check if any devices were found
        if (devices.isNotEmpty) {
          emit(BleScanSuccess(devices)); // Emit success with the device list
        } else {
          emit(BleNoDevicesFound()); // Emit "No Devices Found" state
          _ble.deinitialize();
        }

        print('Devices: $devices');
      } catch (error) {
        emit(
            BleScanningError('Scan error: $error')); // Handle unexpected errors
        _ble.deinitialize();
      }
    } else {
      emit(PermissionNotGranted());
    }
  }

  /// Connect to a device
  Future<void> connectToDevice(String deviceId) async {
    try {
      emit(BleConnecting());
      bool isNavigated = false;

      final connectionStream = _ble.connectToDevice(
        id: deviceId,
        connectionTimeout: const Duration(seconds: 5), // Adjusted timeout
      );

      connectionStream.listen(
        (connectionState) {
          if (connectionState.connectionState ==
                  DeviceConnectionState.connected &&
              !isNavigated) {
            isNavigated = true;
            final prefs = SpService();
            prefs.setConnectedDeviceId(deviceId); // Save connection
            emit(BleConnected(deviceId));
            Get.snackbar('Connected', 'Bluetooth Connected Successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green);
            Get.off(() => const OptionsPage());
          } else if (connectionState.connectionState ==
                  DeviceConnectionState.disconnected &&
              !isNavigated) {
            isNavigated = true;
            emit(BleDisconnected());
            Get.snackbar('Failed', 'Failed to Connect to the device');
            Get.to(() => const ScannedDevices());
          }
        },
        onError: (error) {
          emit(BleError('Connection error: $error'));
          Get.off(() => const ScannedDevices());
          print('Error details: $error'); // Debugging details
        },
      );
    } catch (e) {
      emit(BleError('Failed to connect: $e'));
      Get.off(() => const ScannedDevices());
    }
  }

  /// Reconnect to a device
  Future<void> _reconnectToDevice(String deviceId) async {
    try {
      emit(BleConnecting());
      if (state is BleConnecting) {
        Get.snackbar('Reconnecting', 'Please wait for some time',
            margin: const EdgeInsets.only(bottom: 10),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.amber[100]);
      }

      final connectionStream = _ble.connectToDevice(
        id: deviceId,
        connectionTimeout: const Duration(seconds: 5),
      );

      connectionStream.listen(
        (connectionState) {
          if (connectionState.connectionState ==
              DeviceConnectionState.connected) {
            final prefs = SpService();
            prefs.setConnectedDeviceId(deviceId);
            emit(BleConnected(deviceId));
            Get.snackbar('Reconnected', 'Bluetooth Reconnected to $deviceId',
                margin: const EdgeInsets.only(bottom: 10),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green);
            Get.off(() => const OptionsPage());
          } else if (connectionState.connectionState ==
              DeviceConnectionState.disconnected) {
            emit(BleDisconnected());
            Get.snackbar('Failed', 'Failed to Connect to the device',
                margin: const EdgeInsets.only(bottom: 10),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white); // Reconnect failed
          }
        },
        onError: (error) {
          emit(BleError('Reconnection error: $error'));
          emit(BleDisconnected());
          Get.off(() => const ScanPage());
        },
      );
    } catch (e) {
      emit(BleError('Failed to reconnect: $e'));
      emit(BleDisconnected());
      Get.off(() => const ScanPage());
    }
  }

  /// Disconnect from the device
  Future<void> disconnectDevice() async {
    try {
      _connectedDeviceId = null;
      final prefs = SpService();
      prefs.clearConnectedDeviceId(); // Remove connection state
      _ble.deinitialize();

      emit(BleDisconnected());
      Get.snackbar('Disconnected', 'Bluetooth Disconnected Successfully');
      Get.off(() => const ScanPage());
    } catch (e) {
      emit(BleError('Failed to disconnect: $e'));
    }
  }

  @override
  Future<void> close() {
    _ble.deinitialize(); // Clean up resources when the cubit is disposed
    return super.close();
  }
}
