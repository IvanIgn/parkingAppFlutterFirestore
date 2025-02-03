import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/home_view.dart';
import 'package:parkingapp_admin/blocs/person/person_bloc.dart';
import 'package:parkingapp_admin/blocs/vehicle/vehicle_bloc.dart';
import 'package:parkingapp_admin/blocs/parking/parking_bloc.dart';
import 'package:parkingapp_admin/blocs/parking_space/parking_space_bloc.dart';
import 'package:client_repositories/async_http_repos.dart'; // Add this line
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Define the repositories as final constants
final vehicleRepository = VehicleRepository.instance;
final parkingSpaceRepository = ParkingSpaceRepository.instance;
final parkingRepository = ParkingRepository.instance;
final personRepository = PersonRepository.instance;

// Global ValueNotifier for dark mode
final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await ParkingSpaceRepository.instance;

  await _initializeAppSettings();
  runApp(const ParkingAdminApp());
}

// Helper function to initialize app settings
Future<void> _initializeAppSettings() async {
  final prefs = await SharedPreferences.getInstance();
  isDarkModeNotifier.value = prefs.getBool('isDarkMode') ?? false;
}

class ParkingAdminApp extends StatelessWidget {
  const ParkingAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, _) {
        return MultiProvider(
          providers: _getProviders(context),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Parking Admin App',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          ),
        );
      },
    );
  }

  // Extracted method to provide a list of all necessary providers
  List<SingleChildWidget> _getProviders(BuildContext context) {
    return [
      BlocProvider<PersonBloc>(
        create: (_) =>
            PersonBloc(repository: personRepository)..add(const FetchPersonsEvent()),
      ),
      // BlocProvider<PersonBloc>(
      //   create: (_) => PersonBloc()..add(FetchPersonsEvent()),
      // ),
      BlocProvider<VehicleBloc>(
        create: (_) => VehicleBloc(vehicleRepository)..add(const LoadVehicles()),
      ),
      BlocProvider<ParkingsBloc>(
        create: (_) => ParkingsBloc(parkingRepository: parkingRepository)
          ..add(LoadParkingsEvent()),
      ),
      BlocProvider<ParkingSpaceBloc>(
        create: (_) =>
            ParkingSpaceBloc(parkingSpaceRepository)..add(const LoadParkingSpaces()),
      ),
      Provider<ParkingSpaceRepository>(
        create: (_) => parkingSpaceRepository,
      ),
    ];
  }
}
