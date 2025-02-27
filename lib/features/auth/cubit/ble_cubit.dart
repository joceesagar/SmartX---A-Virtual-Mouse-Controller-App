import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
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
            Get.to(() => const OptionsPage());
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

  final characteristic = QualifiedCharacteristic(
      serviceId: Uuid.parse("785e99cc-e61f-41b0-899e-f59fa295441a"),
      characteristicId: Uuid.parse("7fb99d10-d067-42f2-99f4-b515e595c91c"),
      deviceId: "48:27:E2:D3:14:01");

  /// Subscribe to SharedPreferences changes and write updates to BLE
  // Future<void> subscribeAndWrite(List<String> keys) async {
  //   if (state is BleConnected) {
  //     try {
  //       // Step 1: Write default value initially
  //       for (final key in keys) {
  //         final initialValue = await SpService().getValue(key);
  //         emit(BleWriting());
  //         print('Initial values: $initialValue');
  //         await _writeToBle(characteristic, initialValue, key);
  //       }
  //       emit(BleConnected("48:27:E2:D3:13:DD"));
  //       // Step 2: Listen to SharedPreferences changes
  //       SpService().onKeyChanged.listen((event) async {
  //         final updatedKey = event.key;
  //         final updatedValue = event.value;
  //         print('Value Updated Successfully $updatedValue');

  //         if (keys.contains(updatedKey)) {
  //           await _writeToBle(characteristic, updatedValue, updatedKey);
  //         }
  //       });
  //     } catch (e) {
  //       emit(BleConnected("48:27:E2:D3:13:DD"));
  //     }
  //   } else {
  //     Get.snackbar("NotConnected", "Bluetooth is not connected");
  //   }
  // }

  // /// Write value to BLE characteristic
  // Future<void> _writeToBle(
  //     QualifiedCharacteristic characteristic, String value, String key) async {
  //   print(ascii.encode(value));
  //   try {
  //     await _ble.writeCharacteristicWithResponse(
  //       characteristic,
  //       value: ascii.encode('$key: $value'),
  //     );
  //     print("WRITTEN SUCCESSFULLY");

  //     emit(BleConnected("48:27:E2:D3:13:DD"));
  //     Get.snackbar("Success", "Value Written successfully",
  //         backgroundColor: Colors.green,
  //         snackPosition: SnackPosition.BOTTOM,
  //         margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10));
  //   } catch (e) {
  //     emit(BleConnected("48:27:E2:D3:13:DD"));
  //     print(e);
  //     Get.snackbar("Error", "Error writing value");
  //   }
  // }

  Future<void> subscribeAndWrite(List<String> keys) async {
    if (state is BleConnected) {
      try {
        // Step 1: Retrieve all key-value pairs and send them as JSON
        final Map<String, String> keyValueMap = {};

        for (final key in keys) {
          final value = await SpService().getValue(key);
          keyValueMap[key] = value;
        }

        final jsonPayload = jsonEncode(keyValueMap);
        emit(BleWriting());
        print('Initial JSON Payload: $jsonPayload');

        await _writeToBle(characteristic, jsonPayload);

        emit(BleConnected("48:27:E2:D3:14:01"));

        // Step 2: Listen to SharedPreferences changes
        SpService().onKeyChanged.listen((event) async {
          final updatedKey = event.key;
          final updatedValue = event.value;

          print('Value Updated Successfully: $updatedValue');

          if (keys.contains(updatedKey)) {
            keyValueMap[updatedKey] = updatedValue;
            final updatedJsonPayload = jsonEncode(keyValueMap);
            await _writeToBle(characteristic, updatedJsonPayload);
            emit(BleConnected("48:27:E2:D3:14:01"));
          }
        });
      } catch (e) {
        emit(BleConnected("48:27:E2:D3:14:01"));
      }
    } else {
      Get.snackbar("NotConnected", "Bluetooth is not connected");
    }
  }

  /// Write JSON data to BLE characteristic
  Future<void> _writeToBle(
      QualifiedCharacteristic characteristic, String jsonPayload) async {
    print(ascii.encode(jsonPayload));
    try {
      await _ble.writeCharacteristicWithResponse(
        characteristic,
        value: ascii.encode(jsonPayload),
      );
      print("WRITTEN SUCCESSFULLY");

      emit(BleConnected("48:27:E2:D3:14:01"));
      Get.snackbar("Success", "Value Written successfully",
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10));
    } catch (e) {
      emit(BleConnected("48:27:E2:D3:14:01"));
      print(e);
      Get.snackbar("Error", "Error writing value");
    }
  }

  // Stream<String> readFromBle(QualifiedCharacteristic characteristic) {
  //   try {
  //     return _ble.subscribeToCharacteristic(characteristic).map((data) {
  //       final response = ascii.decode(data);
  //       print("RECEIVED DATA: $response");

  //       emit(BleConnected("48:27:E2:D3:13:DD"));
  //       Get.snackbar("Success", "Data Received: $response",
  //           backgroundColor: Colors.blue,
  //           snackPosition: SnackPosition.BOTTOM,
  //           margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10));

  //       return response; // Now correctly returning data from the stream
  //     });
  //   } catch (e) {
  //     print("Reading Error: $e");
  //     emit(BleConnected("48:27:E2:D3:13:DD"));
  //     return const Stream.empty();
  //   }
  // }

  void readFromBle() async {
    print("BLE IS LISTENING.......");
    await _ble.subscribeToCharacteristic(characteristic).listen(
      (data) {
        print("Received Data: $data"); // Raw data in list format
        print(
            "Received Decoded Data: ${String.fromCharCodes(data)}"); // Convert to ASCII string
      },
      onError: (dynamic error) {
        print("Error: $error"); // Debugging: Print error if any
      },
    );
  }

  @override
  Future<void> close() {
    _ble.deinitialize(); // Clean up resources when the cubit is disposed
    return super.close();
  }
}
