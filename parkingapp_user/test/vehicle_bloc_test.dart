import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkingapp_user/blocs/vehicle/vehicle_bloc.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mocks
class MockVehicleRepository extends Mock implements VehicleRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class FakeVehicle extends Fake implements Vehicle {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late VehicleBloc vehicleBloc;
  late MockVehicleRepository mockRepository;
  late MockSharedPreferences mockSharedPreferences;

  setUpAll(() {
    // Register the fallback value for Vehicle
    registerFallbackValue(FakeVehicle());
  });

  setUp(() {
    mockRepository = MockVehicleRepository();
    vehicleBloc = VehicleBloc(mockRepository);
    mockSharedPreferences = MockSharedPreferences();

    // Mock SharedPreferences' getInstance and methods
    when(() => mockSharedPreferences.getString(any()))
        .thenReturn(null); // Initially no selected vehicle
    when(() => mockSharedPreferences.setString(any(), any()))
        .thenAnswer((_) async => true);
    when(() => mockSharedPreferences.remove(any()))
        .thenAnswer((_) async => true);

    when(() => mockRepository.getAllVehicles()).thenAnswer((_) async => [
          Vehicle(
              id: 1,
              regNumber: 'ABC123',
              vehicleType: 'Bil',
              owner:
                  Person(id: 1, name: 'John Doe', personNumber: '1234567890')),
          Vehicle(
              id: 2,
              regNumber: 'XYZ789',
              vehicleType: 'Bil',
              owner:
                  Person(id: 2, name: 'Jane Doe', personNumber: '9876543210')),
        ]);
  });

  tearDown(() {
    vehicleBloc.close();
  });

  group('LoadVehicles', () {
    blocTest<VehicleBloc, VehicleState>(
      'emits [VehiclesLoading, VehiclesLoaded] when loading vehicles is successful',
      build: () {
        when(() => mockRepository.getAllVehicles()).thenAnswer((_) async => [
              Vehicle(id: 1, regNumber: 'ABC123', vehicleType: 'Bil'),
              Vehicle(id: 2, regNumber: 'XYZ789', vehicleType: 'Lastbil'),
            ]);
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(LoadVehicles()), // Add the LoadVehicles event
      expect: () => [
        VehiclesLoading(), // Expect VehiclesLoading to be emitted first
        VehiclesLoaded(vehicles: [
          Vehicle(id: 1, regNumber: 'ABC123', vehicleType: 'Bil'),
          Vehicle(id: 2, regNumber: 'XYZ789', vehicleType: 'Lastbil'),
        ]), // Then expect VehiclesLoaded with the vehicles
      ],
      verify: (_) {
        verify(() => mockRepository.getAllVehicles())
            .called(1); // Ensure getAllVehicles is called once
      },
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehiclesLoading, VehiclesError] when loading vehicles fails',
      build: () {
        when(() => mockRepository.getAllVehicles())
            .thenThrow(Exception('Failed to load vehicles'));
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(LoadVehicles()),
      expect: () => [
        VehiclesLoading(),
        const VehiclesError(
            message:
                'Failed to load vehicles: Exception: Failed to load vehicles'),
      ],
      verify: (_) {
        verify(() => mockRepository.getAllVehicles()).called(1);
      },
    );
  });

  group('AddVehicle', () {
    final newVehicle = Vehicle(
      id: 3,
      regNumber: 'DEF456',
      vehicleType: 'Bil',
      owner: Person(
          id: 3,
          name: 'Jake Bill',
          personNumber: '1260560020'), // Ensure owner is not null
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehiclesLoading, VehiclesLoaded] when adding a vehicle is successful',
      setUp: () {
        when(() => mockRepository.createVehicle(any())).thenAnswer(
          (invocation) async {
            final vehicle = invocation.positionalArguments.first as Vehicle;
            return vehicle.copyWith(
              owner:
                  Person(id: 3, name: 'Jake Bill', personNumber: '1260560020'),
            );
          },
        );

        when(() => mockRepository.getAllVehicles()).thenAnswer(
          (_) async => [
            Vehicle(
              id: 1,
              regNumber: 'ABC123',
              vehicleType: 'Bil',
              owner:
                  Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
            ),
            Vehicle(
              id: 2,
              regNumber: 'XYZ789',
              vehicleType: 'Lastbil',
              owner:
                  Person(id: 2, name: 'Jane Jones', personNumber: '1243560000'),
            ),
            Vehicle(
              id: 3,
              regNumber: 'DEF456',
              vehicleType: 'Bil',
              owner:
                  Person(id: 3, name: 'Jake Bill', personNumber: '1260560020'),
            ),
          ],
        );
      },
      build: () => vehicleBloc,
      act: (bloc) => bloc.add(CreateVehicle(vehicle: newVehicle)),
      expect: () => [
        VehiclesLoading(),
        VehiclesLoaded(vehicles: [
          Vehicle(
            id: 1,
            regNumber: 'ABC123',
            vehicleType: 'Bil',
            owner: Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
          ),
          Vehicle(
            id: 2,
            regNumber: 'XYZ789',
            vehicleType: 'Lastbil',
            owner:
                Person(id: 2, name: 'Jane Jones', personNumber: '1243560000'),
          ),
          Vehicle(
            id: 3,
            regNumber: 'DEF456',
            vehicleType: 'Bil',
            owner: Person(id: 3, name: 'Jake Bill', personNumber: '1260560020'),
          ),
        ], selectedVehicle: null),
      ],
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehiclesLoading, VehiclesError] when adding a vehicle fails',
      build: () {
        when(() => mockRepository.createVehicle(newVehicle))
            .thenThrow(Exception('Failed to add vehicles after creation'));
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(CreateVehicle(vehicle: newVehicle)),
      expect: () => [
        VehiclesLoading(),
        const VehiclesError(
            message:
                'Failed to add vehicles after creation: Exception: Failed to add vehicles after creation'),
      ],
      verify: (_) {
        verify(() => mockRepository.createVehicle(newVehicle)).called(1);
      },
    );
  });

  group('UpdateVehicle', () {
    final updatedVehicle = Vehicle(
        id: 1,
        regNumber: 'NEW123',
        vehicleType: 'Bil',
        owner: Person(id: 1, name: 'John Doe', personNumber: '123456789012'));

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehiclesLoading, VehicleUpdated, VehiclesLoaded] when update is successful',
      build: () => vehicleBloc,
      seed: () => VehiclesLoaded(vehicles: [
        Vehicle(
            id: 1,
            regNumber: 'OLD123',
            vehicleType: 'Bil',
            owner:
                Person(id: 1, name: 'John Doe', personNumber: '123456789012')),
        Vehicle(
            id: 2,
            regNumber: 'XYZ789',
            vehicleType: 'Bil',
            owner:
                Person(id: 2, name: 'Jane Doe', personNumber: '987654321016')),
      ]),
      setUp: () {
        when(() => mockRepository.updateVehicle(any(), any())).thenAnswer(
          (_) async => Vehicle(
              id: 1,
              regNumber: 'NEW123',
              vehicleType: 'Bil',
              owner: Person(
                  id: 1, name: 'John Doe', personNumber: '123456789012')),
        );
        when(() => mockRepository.getAllVehicles()).thenAnswer(
          (_) async => [
            Vehicle(
                id: 1,
                regNumber: 'NEW123',
                vehicleType: 'Bil',
                owner: Person(
                    id: 1, name: 'John Doe', personNumber: '1234567890')),
            Vehicle(
                id: 2,
                regNumber: 'XYZ789',
                vehicleType: 'Bil',
                owner: Person(
                    id: 2, name: 'Jane Doe', personNumber: '9876543210')),
          ],
        );
      },
      act: (bloc) => bloc.add(UpdateVehicle(vehicle: updatedVehicle)),
      expect: () => [
        VehiclesLoading(),
        VehicleUpdated(vehicle: updatedVehicle),
        VehiclesLoaded(vehicles: [
          Vehicle(
              id: 1,
              regNumber: 'NEW123',
              vehicleType: 'Bil',
              owner:
                  Person(id: 1, name: 'John Doe', personNumber: '1234567890')),
          Vehicle(
              id: 2,
              regNumber: 'XYZ789',
              vehicleType: 'Bil',
              owner:
                  Person(id: 2, name: 'Jane Doe', personNumber: '9876543210')),
        ]),
      ],
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehiclesLoading, VehiclesError] when update fails',
      build: () {
        when(() => mockRepository.updateVehicle(any(), any()))
            .thenThrow(Exception('Failed to update vehicle'));
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(UpdateVehicle(vehicle: updatedVehicle)),
      expect: () => [
        VehiclesLoading(),
        const VehiclesError(
            message:
                'Failed to update vehicle: Exception: Failed to update vehicle'),
      ],
    );
  });

  group('DeleteVehicle', () {
    const vehicleId = 1;

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehiclesLoading, VehicleDeleted, VehiclesLoaded] when delete is successful',
      build: () => vehicleBloc,
      setUp: () {
        when(() => mockRepository.deleteVehicle(any())).thenAnswer(
          (_) async => Vehicle(
            id: 1,
            regNumber: 'ABC123',
            vehicleType: 'Bil',
            owner: Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
          ),
        );
        when(() => mockRepository.getAllVehicles()).thenAnswer(
          (_) async => [], // Expecting an empty list after deletion
        );
      },
      act: (bloc) => bloc.add(DeleteVehicle(
        vehicle: Vehicle(
          id: vehicleId,
          regNumber: 'ABC123',
          vehicleType: 'Bil',
          owner: Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
        ),
      )),
      expect: () => [
        VehiclesLoading(), // Emitted first
        VehicleDeleted(
          vehicle: Vehicle(
            id: vehicleId,
            regNumber: 'ABC123',
            vehicleType: 'Bil',
            owner: Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
          ),
        ),
        const VehiclesLoaded(
            vehicles: [],
            selectedVehicle: null), // Finally, empty list of vehicles
      ],
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehiclesLoading, VehiclesError] when delete fails',
      build: () {
        when(() => mockRepository.deleteVehicle(vehicleId))
            .thenThrow(Exception('Failed to delete vehicle'));
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(DeleteVehicle(
          vehicle: Vehicle(
              id: vehicleId,
              regNumber: 'ABC123',
              vehicleType: 'Bil',
              owner: Person(
                  id: 1, name: 'John Doe', personNumber: '1234567890')))),
      expect: () => [
        VehiclesLoading(),
        const VehiclesError(
            message:
                'Failed to delete vehicle: Exception: Failed to delete vehicle'),
      ],
    );
  });

  group('SelectVehicle', () {
    blocTest<VehicleBloc, VehicleState>(
      'emits [VehiclesLoaded] with selected vehicle when selecting a vehicle',
      setUp: () {
        // Mock a successful API call to get all vehicles
        when(() => mockRepository.getAllVehicles()).thenAnswer(
          (_) async => [
            Vehicle(
                id: 1,
                regNumber: 'ABC123',
                vehicleType: 'Bil',
                owner: Person(
                    id: 1, name: 'John Doe', personNumber: '123456789016')),
            Vehicle(
                id: 2,
                regNumber: 'XYZ789',
                vehicleType: 'Lastbil',
                owner: Person(
                    id: 2, name: 'Jane Doe', personNumber: '987654321015')),
          ],
        );

        // Mock SharedPreferences
        final mockPrefs = MockSharedPreferences();
        when(() => mockPrefs.getString('selectedVehicle'))
            .thenReturn(null); // No vehicle selected initially
        when(() => mockPrefs.setString(any<String>(), any<String>()))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.remove(any<String>()))
            .thenAnswer((_) async => true);

        // Set the mock SharedPreferences to the bloc if needed (e.g., dependency injection)
        SharedPreferences.setMockInitialValues({});
      },
      build: () {
        // Mock repository and instantiate the VehicleBloc
        return VehicleBloc(mockRepository)..add(LoadVehicles());
      },
      act: (bloc) {
        // Select the vehicle
        bloc.add(SelectVehicle(
          vehicle: Vehicle(id: 1, regNumber: 'ABC123', vehicleType: 'Bil'),
        ));
      },
      expect: () => [
        // Expect VehiclesLoading to be emitted first
        VehiclesLoading(),

        // Expect VehiclesLoaded with vehicles but selectedVehicle null initially
        VehiclesLoaded(
          vehicles: [
            Vehicle(
                id: 1,
                regNumber: 'ABC123',
                vehicleType: 'Bil',
                owner: Person(
                    id: 1, name: 'John Doe', personNumber: '123456789016')),
            Vehicle(
                id: 2,
                regNumber: 'XYZ789',
                vehicleType: 'Lastbil',
                owner: Person(
                    id: 2, name: 'Jane Doe', personNumber: '987654321015')),
          ],
          selectedVehicle: null,
        ),

        // Expect VehiclesLoaded with selected vehicle
        VehiclesLoaded(
          vehicles: [
            Vehicle(
                id: 1,
                regNumber: 'ABC123',
                vehicleType: 'Bil',
                owner: Person(
                    id: 1, name: 'John Doe', personNumber: '123456789016')),
            Vehicle(
                id: 2,
                regNumber: 'XYZ789',
                vehicleType: 'Lastbil',
                owner: Person(
                    id: 2, name: 'Jane Doe', personNumber: '987654321015')),
          ],
          selectedVehicle: Vehicle(
              id: 1,
              regNumber: 'ABC123',
              vehicleType: 'Bil',
              owner: Person(
                  id: 1,
                  name: 'John Doe',
                  personNumber: '123456789016')), // Correct selected vehicle
        ),
      ],
    );
  });
}
