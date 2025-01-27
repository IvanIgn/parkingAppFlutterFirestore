import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parkingapp_user/blocs/vehicle/vehicle_bloc.dart';
import 'package:shared/shared.dart';

// Mocka de externa beroendena
class MockVehicleRepository extends Mock implements VehicleRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockVehicleRepository mockVehicleRepository;
  late MockSharedPreferences mockSharedPreferences;
  late VehicleBloc vehicleBloc;

  setUp(() {
    mockVehicleRepository = MockVehicleRepository();
    mockSharedPreferences = MockSharedPreferences();
    vehicleBloc = VehicleBloc();

    // Ställ in mockar för SharedPreferences
    when(() => mockSharedPreferences.getString('selectedVehicle'))
        .thenReturn(null);
    when(() => mockSharedPreferences.setString(any(), any()))
        .thenAnswer((_) async => true);
    when(() => mockSharedPreferences.remove(any()))
        .thenAnswer((_) async => true);
  });

  group('VehicleBloc', () {
    // Testa LoadVehicles event
    blocTest<VehicleBloc, VehicleState>(
      'emits [VehiclesLoading, VehiclesLoaded] when vehicles are loaded successfully',
      setUp: () {
        // Mocka framgångsrikt API-anrop för att hämta alla vehicles
        when(() => mockVehicleRepository.getAllVehicles()).thenAnswer(
          (_) async => [
            Vehicle(id: 1, regNumber: 'ABC123', vehicleType: 'Bil'),
            Vehicle(id: 2, regNumber: 'XYZ789', vehicleType: 'Lastbil')
          ],
        );
      },
      build: () => VehicleBloc(),
      act: (bloc) => bloc.add(LoadVehicles()),
      expect: () => [
        VehiclesLoading(),
        VehiclesLoaded(vehicles: [
          Vehicle(id: 1, regNumber: 'ABC123', vehicleType: 'Bil'),
          Vehicle(id: 2, regNumber: 'XYZ789', vehicleType: 'Lastbil'),
        ]),
      ],
    );

    // Testa LoadVehiclesByPerson event
    blocTest<VehicleBloc, VehicleState>(
      'emits [VehiclesLoading, VehiclesLoaded] when vehicles are loaded for a specific person',
      setUp: () {
        // Mocka framgångsrikt API-anrop för att hämta alla vehicles
        when(() => mockVehicleRepository.getAllVehicles()).thenAnswer(
          (_) async =>
              [Vehicle(id: 1, regNumber: 'ABC123', vehicleType: 'Bil')],
        );
      },
      build: () => VehicleBloc(),
      act: (bloc) => bloc.add(LoadVehiclesByPerson(
          person: Person(
        name: 'John Doe',
        personNumber: '199301050010',
      ))),
      expect: () => [
        VehiclesLoading(),
        VehiclesLoaded(vehicles: [
          Vehicle(id: 1, regNumber: 'ABC123', vehicleType: 'Bil')
        ]),
      ],
    );

    // Testa CreateVehicle event
    blocTest<VehicleBloc, VehicleState>(
      'emits [VehiclesError] when vehicle creation fails',
      setUp: () {
        // Mocka ett fel när vi försöker skapa ett fordon
        when(() => mockVehicleRepository.createVehicle(any()))
            .thenThrow(Exception('Failed to create vehicle'));
      },
      build: () => VehicleBloc(),
      act: (bloc) => bloc.add(
        CreateVehicle(
            vehicle: Vehicle(id: 2, regNumber: 'ABC123', vehicleType: 'Bil')),
      ),
      expect: () =>
          [VehiclesError(message: 'Exception: Failed to create vehicle')],
    );

    // Testa UpdateVehicles event
    blocTest<VehicleBloc, VehicleState>(
      'emits [VehiclesError] when vehicle update fails',
      setUp: () {
        // Mocka ett fel när vi försöker uppdatera ett fordon
        when(() => mockVehicleRepository.updateVehicle(any(), any()))
            .thenThrow(Exception('Failed to update vehicle'));
      },
      build: () => VehicleBloc(),
      act: (bloc) => bloc.add(UpdateVehicles(
          vehicle: Vehicle(id: 2, regNumber: 'ABC123', vehicleType: 'Bil'))),
      expect: () =>
          [VehiclesError(message: 'Exception: Failed to update vehicle')],
    );

    // Testa DeleteVehicles event
    blocTest<VehicleBloc, VehicleState>(
      'emits [VehiclesError] when vehicle deletion fails',
      setUp: () {
        // Mocka ett fel när vi försöker ta bort ett fordon
        when(() => mockVehicleRepository.deleteVehicle(any()))
            .thenThrow(Exception('Failed to delete vehicle'));
      },
      build: () => VehicleBloc(),
      act: (bloc) => bloc.add(DeleteVehicles(
          vehicle: Vehicle(id: 1, regNumber: 'ABC123', vehicleType: 'Bil'))),
      expect: () =>
          [VehiclesError(message: 'Exception: Failed to delete vehicle')],
    );

    // Testa SelectVehicle event
    blocTest<VehicleBloc, VehicleState>(
      'emits [VehiclesLoaded] with selected vehicle when selecting a vehicle',
      setUp: () {
        // Mocka framgångsrikt API-anrop för att hämta alla vehicles
        when(() => mockVehicleRepository.getAllVehicles()).thenAnswer(
          (_) async =>
              [Vehicle(id: 1, regNumber: 'ABC123', vehicleType: 'Bil')],
        );
      },
      build: () => VehicleBloc(),
      act: (bloc) => bloc.add(SelectVehicle(
          vehicle: Vehicle(id: 1, regNumber: 'ABC123', vehicleType: 'Bil'))),
      expect: () => [
        VehiclesLoaded(
            vehicles: [Vehicle(id: 1, regNumber: 'ABC123', vehicleType: 'Bil')],
            selectedVehicle:
                Vehicle(id: 1, regNumber: 'ABC123', vehicleType: 'Bil')),
      ],
    );
  });
}
