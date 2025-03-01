import 'dart:convert';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/models/data_models.dart';
import 'package:http/http.dart' as http;

class DataRemoteRepository {
  final spService = SpService();

  Future<DataModels> updateData(Map<String, dynamic> updateData) async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw "Unauthorized: No token found";
      }

      final res = await http.patch(
        Uri.parse('${Constants.backendUri}/data/update'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(updateData),
      );

      if (res.statusCode != 200) {
        final errorMsg = jsonDecode(res.body)['error'];
        throw errorMsg;
      }

      return DataModels.fromJson(jsonDecode(res.body)['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<DataModels?> getData(List<String> requestedKeys) async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        return null;
      }

      final res = await http.get(
        Uri.parse('${Constants.backendUri}/data/get'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }

      return DataModels.fromJson(jsonDecode(res.body)['data']);
    } catch (e) {
      return null;
    }
  }

  Future<DataModels?> createDefaults() async {
    try {
      final token = await spService.getToken();
      if (token == null) return null;

      final res = await http.post(
        Uri.parse('${Constants.backendUri}/data/create-defaults'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }

      return DataModels.fromJson(jsonDecode(res.body)['data']);
    } catch (e) {
      print("Error creating defaults: $e");
      return null;
    }
  }
}
