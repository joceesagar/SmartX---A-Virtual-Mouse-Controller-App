import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/auth/pages/signup_page.dart';
import 'package:frontend/features/auth/repository/auth_remote_repository.dart';
import 'package:frontend/models/user_models.dart';
import 'package:get/get.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final authRemoteRepository = AuthRemoteRepository();
  final spService = SpService();
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  void getUserData() async {
    try {
      emit(AuthLoading());

      // Check if the user is logged in as a guest
      if (await spService.isGuestLoggedIn()) {
        emit(AuthGuest());
        return;
      }
      // Check if user is logged in with id and password
      final userModel = await authRemoteRepository.getUserData();
      if (userModel != null) {
        emit(AuthLoggedIn(userModel));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthInitial());
    }
  }

  void signUp(
      {required String username,
      required String email,
      required String password}) async {
    try {
      emit(AuthLoading());
      await authRemoteRepository.signUp(
        username: username,
        email: email,
        password: password,
      );

      emit(AuthSignUp());
    } catch (e) {
      print("Error occurred");
      emit(AuthError(e.toString()));
    }
  }

  void login({required String email, required String password}) async {
    try {
      emit(AuthLoading());
      final userModel = await authRemoteRepository.login(
        email: email,
        password: password,
      );
      if (userModel.token.isNotEmpty) {
        await spService.setToken(userModel.token);
      }
      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Handles guest login or restores guest state if already logged in
  Future<void> handleGuestLogin() async {
    try {
      emit(AuthLoading());

      // Generate random guest ID and guest name
      final guestId = _generateRandomId();
      final guestName = _generateRandomGuestName();

      // Save guest details in SharedPreferences
      await spService.guestLogin(guestId, guestName);
      print(guestId);
      print(guestName);

      // Emit guest state
      emit(AuthGuest());
    } catch (e) {
      emit(AuthError('Failed to handle guest login: ${e.toString()}'));
      emit(AuthInitial());
    }
  }

  /// Handles logout
  Future<void> logout() async {
    try {
      emit(AuthLoading()); // Emit loading state

      // Handle AuthLoggedIn or AuthGuest-specific logic
      if (state is AuthLoggedIn) {
        await spService.removeToken();
      } else if (state is AuthGuest) {
        await spService.guestLogout();
      }

      // Clear connected device and deinitialize BLE
      final prefs = SpService();
      prefs.clearConnectedDeviceId(); // Remove connection state
      _ble.deinitialize(); // Deinitialize BLE service

      Get.off(() => const SignupPage()); // Navigate to signup page
    } catch (e) {
      emit(AuthError('Failed to log out: ${e.toString()}'));
    }
  }

  ///Function to generate randomId
  String _generateRandomId() {
    return Random()
        .nextInt(1000000)
        .toString(); // Generates a random 6-digit ID
  }

  ///Function to generate random guest name
  String _generateRandomGuestName() {
    return 'Guest_${Random().nextInt(1000)}'; // Generates a random guest name
  }
}
