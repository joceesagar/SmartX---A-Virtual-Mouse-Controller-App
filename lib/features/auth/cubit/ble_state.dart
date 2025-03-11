part of 'ble_cubit.dart';

sealed class BleState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class BleInitial extends BleState {}

final class BleScanning extends BleState {}

final class PermissionNotGranted extends BleState {}

final class BleScanningError extends BleState {
  final String message;
  BleScanningError(this.message);

  @override
  List<Object?> get props => [message];
}

final class BleScanSuccess extends BleState {
  final RxList<DiscoveredDevice> devices;
  BleScanSuccess(this.devices);

  @override
  List<Object?> get props => [devices];
}

final class BleNoDevicesFound extends BleState {}

final class BleConnecting extends BleState {}

final class BleConnected extends BleState {
  final String deviceId;
  BleConnected(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

final class BleDisconnected extends BleState {}

final class BleError extends BleState {
  final String message;
  BleError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when writing process is going on
final class BleWriting extends BleState {}

/// State when a write operation to a characteristic is successful
final class BleWriteSuccess extends BleState {}

/// State when a write operation to a characteristic fails
final class BleWriteError extends BleState {
  final String message;
  BleWriteError(this.message);

  @override
  List<Object?> get props => [message];
}
