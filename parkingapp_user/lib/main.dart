import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';
import 'package:parkingapp_user/blocs/auth/auth_bloc.dart';
import 'package:parkingapp_user/blocs/person/person_bloc.dart';
import 'package:parkingapp_user/blocs/vehicle/vehicle_bloc.dart';
import 'package:parkingapp_user/blocs/parking/parking_bloc.dart';
import 'package:parkingapp_user/blocs/registration/registration_bloc.dart';
import 'package:parkingapp_user/blocs/parking_space/parking_space_bloc.dart';
import 'package:client_repositories/async_http_repos.dart';

final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

void main() async {
  // runApp(const ParkingApp());
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved theme preference
  final prefs = await SharedPreferences.getInstance();
  isDarkModeNotifier.value = prefs.getBool('isDarkMode') ?? false;
  //clearPrefs();

  //   Initialize repositories
  final personRepository = PersonRepository.instance;
  final parkingSpaceRepository = ParkingSpaceRepository.instance;
  final parkingRepository = ParkingRepository.instance;
  final vehicleRepository = VehicleRepository.instance;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<PersonBloc>(
            create: (context) =>
                PersonBloc(repository: personRepository)..add(LoadPersons())),
        BlocProvider<VehicleBloc>(
            create: (context) =>
                VehicleBloc(vehicleRepository)..add(LoadVehicles())),
        BlocProvider<ParkingBloc>(
            create: (context) => ParkingBloc(
                parkingRepository: parkingRepository, sharedPreferences: prefs)
              ..add(LoadActiveParkings())),
        BlocProvider<ParkingSpaceBloc>(
          create: (context) => ParkingSpaceBloc(
              parkingSpaceRepository: parkingSpaceRepository,
              parkingRepository: parkingRepository,
              personRepository: personRepository,
              vehicleRepository: VehicleRepository.instance)
            ..add(LoadParkingSpaces()),
        ),
        BlocProvider<RegistrationBloc>(
          create: (context) => RegistrationBloc(
              personRepository:
                  personRepository), // Dispatch CheckAuthStatus event here
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(personRepository: personRepository)
            ..add(CheckAuthStatus()), // Dispatch CheckAuthStatus event here
        ),
      ],
      child: const ParkingApp(),
    ),
  );
}

class ParkingApp extends StatelessWidget {
  const ParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ParkeringsApp',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                return const HomeView(); // Show the HomeView if logged in
              } else if (authState is AuthLoggedOut) {
                return LoginView(
                  onLoginSuccess: () {
                    BlocProvider.of<AuthBloc>(context).add(CheckAuthStatus());
                  },
                ); // Show the LoginFormView if logged out
              } else if (authState is AuthLoading) {
                return const Center(
                    child:
                        CircularProgressIndicator()); // Show loading while checking login status
              } else {
                return const Center(child: Text('Unexpected state'));
              }
            },
          ),
        );
      },
    );
  }
}

void clearPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.clear();
}
