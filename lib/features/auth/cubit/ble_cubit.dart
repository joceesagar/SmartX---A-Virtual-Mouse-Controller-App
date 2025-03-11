import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/home/pages/home_page.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

part 'ble_state.dart';

const deviceID = "48:27:E2:D3:14:01";

class BleCubit extends Cubit<BleState> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription? _connectionSubscription; // Store the subscription

  /// Observable list to store scanned BLE devices
  RxList<DiscoveredDevice> devices = <DiscoveredDevice>[].obs;

  /// To store the currently connected device ID
  String? _connectedDeviceId;

  BleCubit() : super(BleInitial()) {
    _checkForPreviousConnection();
  }

//check for connection state continuously
  void monitorConnection() {
    print("MONITORING CONNECTION");
    _connectionSubscription = _ble.connectedDeviceStream.listen(
      (connectionState) {
        print(connectionState);
        if (connectionState.connectionState ==
            DeviceConnectionState.disconnected) {
          emit(BleDisconnected());
        }
      },
      onError: (error) {
        emit(BleError('Connection monitoring error: $error'));
      },
    );
  }

  void stopMonitoringConnection() {
    _connectionSubscription?.cancel(); // Cancel the subscription
    _connectionSubscription = null; // Clear the subscription
    print("STOPPED MONITORING CONNECTION");
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
        await Future.delayed(const Duration(seconds: 2));

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
                margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
                colorText: Colors.white);
            Get.off(() => const HomePage());
          } else if (connectionState.connectionState ==
                  DeviceConnectionState.disconnected &&
              !isNavigated) {
            isNavigated = true;
            emit(BleDisconnected());
            Get.snackbar('Failed', 'Failed to Connect to the device',
                margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 1),
                colorText: Colors.white);
          }
        },
        onError: (error) {
          emit(BleError('Connection error: $error'));
          print('Error details: $error'); // Debugging details
        },
      );
    } catch (e) {
      emit(BleError('Failed to connect: $e'));
    }
  }

  /// Reconnect to a device
  Future<void> _reconnectToDevice(String deviceId) async {
    try {
      emit(BleConnecting());
      if (state is BleConnecting) {
        Get.snackbar('Reconnecting', 'Please wait for some time',
            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            duration: const Duration(seconds: 1),
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
            // Get.to(() => const HomePage());
            Get.snackbar('Reconnected', 'Bluetooth Reconnected to $deviceId',
                margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                duration: const Duration(seconds: 1),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white);
          } else if (connectionState.connectionState ==
              DeviceConnectionState.disconnected) {
            Get.snackbar('Failed', 'Failed to Connect to the device',
                margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                duration: const Duration(seconds: 1),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white); // Reconnect failed
            emit(BleDisconnected());
          }
        },
        onError: (error) {
          emit(BleError('Reconnection error: $error'));
        },
      );
    } catch (e) {
      emit(BleError('Failed to reconnect: $e'));
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
      print("DEBUG: BleDisconnected emitted!");
      Get.snackbar(
        'Disconnected',
        'Bluetooth Disconnected Successfully',
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      emit(BleError('Failed to disconnect: $e'));
    }
  }

  final characteristic = QualifiedCharacteristic(
      serviceId: Uuid.parse("785e99cc-e61f-41b0-899e-f59fa295441a"),
      characteristicId: Uuid.parse("7fb99d10-d067-42f2-99f4-b515e595c91c"),
      deviceId: deviceID);

  Future<void> subscribeAndWrite(List<String> keys) async {
    if (state is BleConnected) {
      try {
        print("STEP 1");
        // Step 1: Retrieve all key-value pairs and send them as JSON
        final Map<String, dynamic> keyValueMap = {};

        for (final key in keys) {
          final value = await SpService().getValue(key);
          keyValueMap[key] = await _getValueWithCorrectType(key, value);
        }

        print("STEP 2");
        final jsonPayload = jsonEncode(keyValueMap);
        emit(BleWriting());
        print('Initial JSON Payload: $jsonPayload');

        print("STEP 2: Delaying before writing...");
        await Future.delayed(
            const Duration(seconds: 1)); // Give time for BLE device
        await _writeToBle(characteristic, jsonPayload);

        emit(BleConnected(deviceID));

        // Step 2: Listen to SharedPreferences changes
        SpService().onKeyChanged.listen((event) async {
          final updatedKey = event.key;
          final updatedValue = event.value;

          print('Value Updated Successfully: $updatedValue');

          if (keys.contains(updatedKey)) {
            keyValueMap[updatedKey] = updatedValue;
            final updatedJsonPayload = jsonEncode(keyValueMap);
            await _writeToBle(characteristic, updatedJsonPayload);
            emit(BleConnected(deviceID));
          }
        });
      } catch (e) {
        if (_isDisconnectionError(e)) {
          emit(BleDisconnected());
        } else {}
        print("Error writing to BLE: $e");
        emit(BleConnected(deviceID));
        Get.snackbar("Error", "Failed to write value",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10));
      }
    } else {
      Get.snackbar("NotConnected", "Bluetooth is not connected");
      return;
    }
  }

  // Change type of data
  Future<dynamic> _getValueWithCorrectType(String key, String value) async {
    try {
      if (key == 'SN' || key == 'HM') {
        return int.parse(value);
      } else if (key == 'HO') {
        return bool.parse(value);
      } else {
        return value;
      }
    } catch (e) {
      print('Error parsing value for $key: $e');
      return value;
    }
  }

  /// Write JSON data to BLE characteristic
  Future<void> _writeToBle(
      QualifiedCharacteristic characteristic, String jsonPayload) async {
    print("Checking connection before writing...");

    print(_ble.readCharacteristic(characteristic));

    int retryCount = 5; // Maximum retries
    while (retryCount > 0) {
      final connectionState = await _ble.statusStream.first;
      if (connectionState == BleStatus.ready) {
        break; // Exit loop if BLE is ready
      }
      print("BLE is not ready. Retrying connection...");
      await Future.delayed(const Duration(seconds: 2));
      retryCount--;
    }

    try {
      print("Device is connected. Attempting to write...");
      await _ble.writeCharacteristicWithoutResponse(
        characteristic,
        value: ascii.encode(jsonPayload),
      );
      print("WRITTEN SUCCESSFULLY");

      Get.snackbar("Success", "Value Written successfully",
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10));
    } catch (e) {
      rethrow; // Rethrow the error so `subscribeAndWrite` can catch it.
    }
  }

  bool _isDisconnectionError(dynamic error) {
    if (error is PlatformException) {
      // List of known BLE disconnection-related error messages and codes
      const List<String> disconnectionMessages = [
        'Disconnected',
        'Connection closed',
        'GATT_CONN_TERMINATE_PEER_USER',
        'GATT_CONN_TERMINATE_LOCAL_HOST',
        'GATT_CONN_TIMEOUT',
        'GATT_CONN_L2C_FAILURE',
        'GATT_CONN_FAIL_ESTABLISH',
      ];

      return disconnectionMessages
          .any((msg) => error.message?.contains(msg) == true);
    }
    return false;
  }

  final _positionController =
      StreamController<Map<String, double>>.broadcast(); // StreamController

  Stream<Map<String, double>> get positionStream =>
      _positionController.stream; // Expose the stream

  void readFromBle() async {
    print("BLE IS LISTENING.......");
    // await _ble.subscribeToCharacteristic(characteristic).listen(
    // (data) {
    // print("Received Data: $data"); // Raw data in list format
    // String decodedData = String.fromCharCodes(data);
    // print("Received Decoded Data: $decodedData"); // Convert to ASCII string

    print("Simulating BLE data (-5 to 5)...");
    Timer.periodic(const Duration(seconds: 1), (timer) {
      // Generate random x and y values between -5 and 5
      double x = Random().nextDouble() * 10 - 5;
      double y = Random().nextDouble() * 10 - 5;

      // Simulate receiving data by creating a comma separated string
      String decodedData = "${x.toStringAsFixed(2)},${y.toStringAsFixed(2)}";

      try {
        List<String> values = decodedData.split(',');
        if (values.length == 2) {
          double x = double.parse(values[0]);
          double y = double.parse(values[1]);
          _positionController
              .add({'x': x, 'y': y}); // Add parsed values to the stream
        } else {
          print("Invalid data format");
        }
      } catch (e) {
        print("Error parsing data: $e");
      }
      // },
      // onError: (dynamic error) {
      //   print("Error: $error"); // Debugging: Print error if any
      // },
      // );
    });
  }

  @override
  Future<void> close() {
    _ble.deinitialize(); // Clean up resources when the cubit is disposed
    stopMonitoringConnection(); // Cancel the subscription when the cubit is closed
    return super.close();
  }
}
