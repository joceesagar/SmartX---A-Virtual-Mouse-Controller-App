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

  /// Removes the authentication token
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('x-auth-token');
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

  /// Stores guest login details (random ID and name)
  Future<void> guestLogin(String guestId, String guestName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('guestId', guestId);
    await prefs.setString('guestName', guestName);
  }

  /// Clears guest login details and logs out
  Future<void> guestLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('guestId');
    await prefs.remove('guestName');
  }

  /// Checks if guest login details exist
  Future<bool> isGuestLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('guestId');
  }
}
