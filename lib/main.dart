import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/cubit/ble_cubit.dart';
import 'package:frontend/features/auth/pages/signup_page.dart';
import 'package:frontend/features/auth/repository/data_remote_repository.dart';
import 'package:frontend/features/home/pages/home_page.dart';
import 'package:frontend/features/home/pages/scan_page.dart';
import 'package:get/get.dart';

void main() {
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => AuthCubit()),
      BlocProvider(create: (_) => BleCubit())
    ],
    child: const GetMaterialApp(home: MyApp()),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialsLoaded = false;
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().getUserData();
  }

  void loadInitials() async {
    final dataRepo = DataRemoteRepository();
    final state = context.read<AuthCubit>().state;

    if (state is AuthLoggedIn && !_initialsLoaded) {
      _initialsLoaded = true; // Prevent multiple calls
      final response = await dataRepo.createDefaults();
      print("RESPONSE: $response");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Task App',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: const EdgeInsets.all(27),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(60, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          useMaterial3: true,
        ),
        home: const HomePage()
        // BlocBuilder<AuthCubit, AuthState>(
        //   builder: (context, state) {
        //     if (state is AuthLoggedIn) {
        //       WidgetsBinding.instance.addPostFrameCallback((_) {
        //         loadInitials();
        //       });
        //       print("IsAuthGuest: ${SpService().isGuestLoggedIn()}");
        //       print(state);
        //       return const ScanPage();
        //     } else if (state is AuthGuest) {
        //       print("AuthGuest: ${SpService().getGuestId()}");
        //       print(state);
        //       return const ScanPage();
        //     } else {
        //       return const SignupPage();
        //     }
        //   },
        // ),
        );
  }
}
