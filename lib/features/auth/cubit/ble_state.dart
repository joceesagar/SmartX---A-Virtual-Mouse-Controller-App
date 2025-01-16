part of 'ble_cubit.dart';

sealed class BleState {}

final class BleInitial extends BleState {}

final class BleScanning extends BleState {}

final class PermissionNotGranted extends BleState {}

final class BleScanningError extends BleState {
  final String message;
  BleScanningError(this.message);
}

final class BleScanSuccess extends BleState {
  final RxList<DiscoveredDevice> devices;
  BleScanSuccess(this.devices);
}

final class BleNoDevicesFound extends BleState {}

final class BleConnecting extends BleState {}

final class BleConnected extends BleState {
  final String deviceId;
  BleConnected(this.deviceId);
}

final class BleDisconnected extends BleState {}

final class BleError extends BleState {
  final String message;
  BleError(this.message);
}
