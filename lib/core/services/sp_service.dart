import 'package:shared_preferences/shared_preferences.dart';

class SpService {
  /// Stores the authentication token
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('x-auth-token', token);
  }

  /// Retrieves the authentication token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('x-auth-token');
  }

  /// Stores the connected BLE device ID
  Future<void> setConnectedDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('connectedDeviceId', deviceId);
  }

  /// Retrieves the connected BLE device ID
  Future<String?> getConnectedDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('connectedDeviceId');
  }

  /// Clears the stored BLE device ID
  Future<void> clearConnectedDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('connectedDeviceId');
  }

  /// Checks if a BLE device ID exists
  Future<bool> hasConnectedDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('connectedDeviceId');
  }
}
