import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkingapp_admin/blocs/vehicle/vehicle_bloc.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

class FakeVehicle extends Fake implements Vehicle {}

void main() {
  late VehicleBloc vehicleBloc;
  late MockVehicleRepository mockRepository;

  setUpAll(() {
    // Register the fallback value for Person
    registerFallbackValue(FakeVehicle());
  });

  setUp(() {
    mockRepository = MockVehicleRepository();
    vehicleBloc = VehicleBloc(mockRepository);
  });

  tearDown(() {
    vehicleBloc.close();
  });

  group('LoadVehicles', () {
    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoading, VehicleLoaded] when loading vehicles is successful',
      build: () {
        when(() => mockRepository.getAllVehicles()).thenAnswer((_) async => [
              Vehicle(id: 1, regNumber: 'ABC123', vehicleType: 'Bil'),
              Vehicle(id: 2, regNumber: 'XYZ789', vehicleType: 'Lastbil'),
            ]);
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(LoadVehicles()),
      expect: () => [
        VehicleLoading(),
        VehicleLoaded([
          Vehicle(id: 1, regNumber: 'ABC123', vehicleType: 'Bil'),
          Vehicle(id: 2, regNumber: 'XYZ789', vehicleType: 'Lastbil'),
        ]),
      ],
      verify: (_) {
        verify(() => mockRepository.getAllVehicles()).called(1);
      },
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoading, VehicleError] when loading vehicles fails',
      build: () {
        when(() => mockRepository.getAllVehicles())
            .thenThrow(Exception('Failed to load vehicles'));
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(LoadVehicles()),
      expect: () => [
        VehicleLoading(),
        const VehicleError(
            'Failed to load vehicles: Exception: Failed to load vehicles'),
      ],
      verify: (_) {
        verify(() => mockRepository.getAllVehicles()).called(1);
      },
    );
  });

  group('AddVehicle', () {
    final newVehicle = Vehicle(id: 3, regNumber: 'DEF456', vehicleType: 'Bil');

    // Test case for adding a vehicle successfully
    blocTest<VehicleBloc, VehicleState>(
      'AddVehicleEvent emits [VehicleLoading, VehicleLoaded] when add is successful',
      build: () => vehicleBloc,
      setUp: () {
        // Simulate repository creating a vehicle
        when(() => mockRepository.createVehicle(any())).thenAnswer(
          (_) async => Vehicle(
            id: 3,
            regNumber: 'DEF456',
            vehicleType: 'Bil',
            owner: Person(id: 3, name: 'Jake Bill', personNumber: '1260560020'),
          ),
        );

        // Simulate repository fetching the updated list of vehicles
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
      act: (bloc) => bloc.add(AddVehicle(
        Vehicle(
          id: 3,
          regNumber: 'DEF456',
          vehicleType: 'Bil',
          owner: Person(id: 3, name: 'Jake Bill', personNumber: '1260560020'),
        ),
      )), // Trigger AddVehicleEvent with a vehicle
      expect: () => [
        VehicleLoading(), // First, the loading state is emitted
        VehicleLoaded([
          // Then, the loaded state is emitted with the updated list of vehicles
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
        ]), // After the vehicle is added, the loaded state is emitted
      ],
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoading, VehicleError] when adding a vehicle fails',
      build: () {
        when(() => mockRepository.createVehicle(newVehicle))
            .thenThrow(Exception('Failed to add vehicle'));
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(AddVehicle(newVehicle)),
      expect: () => [
        VehicleLoading(), // First, the loading state is emitted
        const VehicleError(
            'Failed to add vehicle: Exception: Failed to add vehicle'), // Then the error state is emitted
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
      owner: Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
    );

    blocTest<VehicleBloc, VehicleState>(
      'UpdateVehicle emits [VehicleLoading, VehicleUpdated, VehicleLoaded] when update is successful',
      build: () => vehicleBloc,
      seed: () => VehicleLoaded([
        // Start in VehicleLoaded state
        Vehicle(
          id: 1,
          regNumber: 'OLD123',
          vehicleType: 'Bil',
          owner: Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
        ),
        Vehicle(
          id: 2,
          regNumber: 'XYZ789',
          vehicleType: 'Bil',
          owner: Person(id: 2, name: 'Jane Doe', personNumber: '9876543210'),
        ),
      ]),
      setUp: () {
        // Mock repository methods
        when(() => mockRepository.updateVehicle(any(), any())).thenAnswer(
          (_) async => Vehicle(
            id: 1,
            regNumber: 'NEW123',
            vehicleType: 'Bil',
            owner: Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
          ),
        );
        when(() => mockRepository.getAllVehicles()).thenAnswer(
          (_) async => [
            Vehicle(
              id: 1,
              regNumber: 'NEW123',
              vehicleType: 'Bil',
              owner:
                  Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
            ),
            Vehicle(
              id: 2,
              regNumber: 'XYZ789',
              vehicleType: 'Bil',
              owner:
                  Person(id: 2, name: 'Jane Doe', personNumber: '9876543210'),
            ),
          ],
        );
      },
      act: (bloc) => bloc.add(UpdateVehicle(
        Vehicle(
          id: 1,
          regNumber: 'NEW123',
          vehicleType: 'Bil',
          owner: Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
        ),
      )),
      expect: () => [
        VehicleLoading(), // Emitted first
        VehicleUpdated(), // Indicates update success
        VehicleLoaded([
          // Updated list of vehicles
          Vehicle(
            id: 1,
            regNumber: 'NEW123',
            vehicleType: 'Bil',
            owner: Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
          ),
          Vehicle(
            id: 2,
            regNumber: 'XYZ789',
            vehicleType: 'Bil',
            owner: Person(id: 2, name: 'Jane Doe', personNumber: '9876543210'),
          ),
        ]),
      ],
    );

// Test case for failed update vehicle operation
    blocTest<VehicleBloc, VehicleState>(
      'UpdateVehicle emits [VehicleLoading, VehicleError] when update fails',
      build: () => vehicleBloc,
      setUp: () {
        // Simulate repository throwing an exception when updating a vehicle
        when(() => mockRepository.updateVehicle(any(), any()))
            .thenThrow(Exception());
      },
      act: (bloc) => bloc.add(UpdateVehicle(
        Vehicle(
          id: 1,
          regNumber: 'NEW123',
          vehicleType: 'Bil',
          owner: Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
        ),
      )), // Trigger UpdateVehicle with an updated vehicle
      expect: () => [
        VehicleLoading(), // First, the loading state is emitted
        const VehicleError(
            'Error updating vehicle: Exception'), // Then, the error state is emitted
      ],
    );
  });

  group('DeleteVehicle', () {
    const vehicleId = 1;

    blocTest<VehicleBloc, VehicleState>(
      'DeleteVehicle emits [VehicleLoading, VehicleDeleted, VehicleLoaded] when delete is successful',
      build: () => vehicleBloc,
      setUp: () {
        // Mock deleteVehicle to return a dummy Vehicle
        when(() => mockRepository.deleteVehicle(any())).thenAnswer(
          (_) async => Vehicle(
            id: 1,
            regNumber: 'ABC123',
            vehicleType: 'Bil',
            owner: Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
          ), // Return a dummy Vehicle
        );
        when(() => mockRepository.getAllVehicles()).thenAnswer(
          (_) async => [], // Return an empty list after deletion
        );
      },
      act: (bloc) => bloc.add(
          const DeleteVehicle(1)), // Trigger DeleteVehicle with a vehicle ID
      expect: () => [
        VehicleLoading(), // First, the loading state is emitted
        VehicleDeleted(), // Then, the deleted state is emitted
        const VehicleLoaded(
            []), // Finally, the updated list of vehicles (empty) is emitted
      ],
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleError] when deleting a vehicle fails',
      build: () {
        when(() => mockRepository.deleteVehicle(vehicleId))
            .thenThrow(Exception('Failed to delete vehicle'));
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(const DeleteVehicle(vehicleId)),
      expect: () => [
        VehicleLoading(),
        const VehicleError(
            'Failed to delete vehicle: Exception: Failed to delete vehicle'),
      ],
      verify: (_) {
        verify(() => mockRepository.deleteVehicle(vehicleId)).called(1);
      },
      //wait: const Duration(seconds: 2), // Increase timeout if needed
    );
  });
}
