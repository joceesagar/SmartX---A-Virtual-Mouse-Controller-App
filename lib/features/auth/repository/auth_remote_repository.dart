//auth_remote_repository - so that we can talk to the external backend apis that we have created
//local repository - that will help us in buidling offline first app

import 'dart:convert';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/models/user_models.dart';
import 'package:http/http.dart' as http;

class AuthRemoteRepository {
  final spService = SpService();
  Future<UserModels> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      // Handle non-201 status codes
      if (res.statusCode != 201) {
        final errorMsg = jsonDecode(res.body)['message'];
        throw errorMsg;
      }

      // Ensure that the response body can be properly parsed into UserModels
      final user = UserModels.fromJson(res.body);
      return user;
    } catch (e) {
      print("Error:$e");
      throw e.toString();
    }
  }

  Future<UserModels> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Handle non-201 status codes
      if (res.statusCode != 200) {
        final errorMsg = jsonDecode(res.body)['message'];
        throw errorMsg;
      }

      // Ensure that the response body can be properly parsed into UserModels
      final user = UserModels.fromJson(res.body);
      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModels?> getUserData() async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        return null;
      }

      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/tokenIsValid'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      // Handle non-200 status codes
      if (res.statusCode != 200 || jsonDecode(res.body) == false) {
        return null;
      }

      final userResponse = await http.get(
        Uri.parse(
          '${Constants.backendUri}/auth',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (userResponse.statusCode != 200) {
        throw jsonDecode(userResponse.body)['message'];
      }

      // Ensure that the response body can be properly parsed into UserModels
      final user = UserModels.fromJson(userResponse.body);
      return user;
    } catch (e) {
      return null;
    }
  }
}
