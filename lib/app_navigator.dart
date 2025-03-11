import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/cubit/ble_cubit.dart';
import 'package:frontend/features/auth/pages/signup_page.dart';
import 'package:frontend/features/home/pages/home_page.dart';
import 'package:frontend/features/home/pages/scan_page.dart';

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, authState) {
            print("[AUTHDEBUG] ${authState.runtimeType}");
          },
        ),
        BlocListener<BleCubit, BleState>(
          listener: (context, bleState) {
            print("[BLEDEBUG] ${bleState.runtimeType}");
          },
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is AuthLoggedIn || authState is AuthGuest) {
            return BlocBuilder<BleCubit, BleState>(
              builder: (context, bleState) {
                if (bleState is BleConnected) {
                  return const HomePage();
                } else {
                  return const ScanPage();
                }
              },
            );
          } else {
            return const SignupPage();
          }
        },
      ),
    );
  }
}
