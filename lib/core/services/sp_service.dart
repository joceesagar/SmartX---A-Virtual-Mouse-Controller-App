import 'dart:async';
import 'dart:convert';

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

  /// Stores guest login details (random ID and name)
  Future<String?> getGuestId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('guestId');
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

// StreamController to broadcast key-value updates to multiple listeners.
  final _controller = StreamController<MapEntry<String, String>>.broadcast();

  // Default values to use if a key doesn't exist in SharedPreferences.
  final Map<String, String> defaultValues = {
    //General Settings Page
    'gestureSensitivity':
        '20.0', // Gesture Sensitivity = Affects how movement is interpreted.
    'vibrationFeedback': 'true', // Default mouse acceleration
    'trackingMode':
        'smooth', //  Select between different tracking styles, such as smooth tracking vs. raw tracking (instant response).
    'invertCursorMovement': 'false',
    'pointerSpeed':
        '20.0', //Pointer Speed = Affects how fast the cursor moves based on that interpretation.
    'primaryClick': 'Index', // Default primary click,
    'device_name': 'Default Device', // Default name for the device
  };

  /// Initialize default values in SharedPreferences if not already set.
  Future<void> initializeDefaults() async {
    final prefs = await SharedPreferences.getInstance();

    for (var entry in defaultValues.entries) {
      final key = entry.key;
      final defaultValue = entry.value;

      if (prefs.getString(key) == null) {
        await prefs.setString(key, defaultValue);
        print('Initialized key "$key" with default value "$defaultValue".');
      } else {
        print('Key "$key" already exists in SharedPreferences.');
      }
    }
  }

  /// Retrieve a value from SharedPreferences or return a default value if not found.
  Future<String> getValue(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(key);

      if (value == null) {
        // Key not found, use the default value
        final defaultValue = defaultValues[key] ?? '';
        print('Key "$key" not found. Using default value: "$defaultValue".');
        return defaultValue;
      }

      print('Retrieved key "$key" with value: "$value".');
      return value;
    } catch (e) {
      print('Error retrieving value for "$key": $e');
      return defaultValues[key] ?? '';
    }
  }

  /// Update a key-value pair in SharedPreferences and notify listeners about the change.
  Future<void> updateKeyValue(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Encode `Map` or `List` values to JSON strings; store other types as strings
      String encodedValue =
          value is Map || value is List ? jsonEncode(value) : value.toString();

      await prefs.setString(key, encodedValue);

      print('Updated key "$key" with value: "$encodedValue".');

      // Notify listeners about the updated key-value pair
      _controller.add(MapEntry(key, encodedValue));
    } catch (e) {
      print('Error updating value for "$key": $e');
    }
  }

  /// A stream of key-value updates that listeners can subscribe to.
  Stream<MapEntry<String, String>> get onKeyChanged => _controller.stream;

  /// A filtered stream to listen for changes to a specific key.
  Stream<MapEntry<String, String>> onKeyChangedFor(String key) {
    return _controller.stream.where((entry) => entry.key == key);
  }

  /// Decode JSON strings back into their original `Map` or `List` forms.
  dynamic decodeValue(String value) {
    try {
      return jsonDecode(value);
    } catch (e) {
      print('Error decoding value "$value": $e');
      return value; // Return the original string if decoding fails
    }
  }

  /// Dispose the StreamController to prevent memory leaks.
  void dispose() {
    _controller.close();
  }
}
