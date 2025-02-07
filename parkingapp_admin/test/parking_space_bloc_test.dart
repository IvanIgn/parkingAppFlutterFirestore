import 'package:bloc_test/bloc_test.dart' show blocTest;
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:shared/shared.dart';
import 'package:parkingapp_admin/blocs/parking_space/parking_space_bloc.dart';

class MockParkingSpaceRepository extends Mock
    implements ParkingSpaceRepository {}

class FakeParkingSpace extends Fake implements ParkingSpace {}

void main() {
  late ParkingSpaceBloc parkingSpaceBloc;
  late MockParkingSpaceRepository mockRepository;

  setUpAll(() {
    // Register the fallback value for Person
    registerFallbackValue(FakeParkingSpace());
  });

  setUp(() {
    mockRepository = MockParkingSpaceRepository();
    parkingSpaceBloc = ParkingSpaceBloc(mockRepository);
  });

  tearDown(() {
    parkingSpaceBloc.close();
  });

  group('LoadParkingSpaces', () {
    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceLoading, ParkingSpaceLoaded] when load is successful',
      build: () {
        when(() => mockRepository.getAllParkingSpaces()).thenAnswer((_) async =>
            [
              ParkingSpace(id: '1', address: 'Testadress 10', pricePerHour: 100)
            ]);
        return parkingSpaceBloc;
      },
      act: (bloc) => bloc.add(const LoadParkingSpaces()),
      expect: () => [
        ParkingSpaceLoading(),
        ParkingSpaceLoaded([
          ParkingSpace(id: '1', address: 'Testadress 10', pricePerHour: 100),
        ]),
      ],
      verify: (_) {
        verify(() => mockRepository.getAllParkingSpaces()).called(1);
      },
    );

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceLoading, ParkingSpaceError] when load fails',
      build: () {
        when(() => mockRepository.getAllParkingSpaces())
            .thenThrow(Exception('Failed to fetch parking spaces'));
        return parkingSpaceBloc;
      },
      act: (bloc) => bloc.add(const LoadParkingSpaces()),
      expect: () => [
        ParkingSpaceLoading(),
        const ParkingSpaceError("Failed to load parking spaces."),
      ],
      verify: (_) {
        verify(() => mockRepository.getAllParkingSpaces()).called(1);
      },
    );
  });

  group('AddParkingSpace', () {
    final newParkingSpace =
        ParkingSpace(id: '3', address: 'Testadress 30', pricePerHour: 300);

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceLoaded] with updated list when add is successful',
      build: () {
        // Mock repository responses
        when(() => mockRepository.createParkingSpace(newParkingSpace))
            .thenAnswer((_) async => Future.value(newParkingSpace));
        when(() => mockRepository.getAllParkingSpaces())
            .thenAnswer((_) async => [newParkingSpace]);
        return parkingSpaceBloc;
      },
      act: (bloc) =>
          bloc.add(AddParkingSpace(newParkingSpace)), // Trigger event
      expect: () => [
        ParkingSpaceLoading(), // Optionally emit a loading state
        ParkingSpaceLoaded([newParkingSpace]), // Expect the updated state
      ],
      verify: (_) {
        // Ensure repository methods are called
        verify(() => mockRepository.createParkingSpace(newParkingSpace))
            .called(1);
        verify(() => mockRepository.getAllParkingSpaces()).called(1);
      },
    );
    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceLoading, ParkingSpaceError] when adding fails',
      build: () {
        // Mock repository response to throw an exception
        when(() => mockRepository.createParkingSpace(newParkingSpace))
            .thenThrow(Exception('Failed to add parking space'));
        return parkingSpaceBloc;
      },
      act: (bloc) =>
          bloc.add(AddParkingSpace(newParkingSpace)), // Trigger event
      expect: () => [
        ParkingSpaceLoading(), // Loading state emitted first
        const ParkingSpaceError(
            'Failed to add parking space: Exception: Failed to add parking space'),
      ],
      verify: (_) {
        // Verify repository call
        verify(() => mockRepository.createParkingSpace(newParkingSpace))
            .called(1);
      },
    );
  });

  group('UpdateParkingSpace', () {
    // Test case for successful update of parking space
    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'UpdateParkingSpace emits [ParkingSpaceLoading, ParkingSpaceUpdated, ParkingSpaceLoaded] when update is successful',
      build: () => parkingSpaceBloc,
      setUp: () {
        // Simulate repository updating a parking space
        when(() => mockRepository.updateParkingSpace(any(), any())).thenAnswer(
          (_) async => ParkingSpace(
              id: '1', address: 'Updated Address', pricePerHour: 200),
        );
        // Simulate repository fetching the updated list of parking spaces
        when(() => mockRepository.getAllParkingSpaces()).thenAnswer(
          (_) async => [
            ParkingSpace(
                id: '1', address: 'Updated Address', pricePerHour: 200),
          ],
        );
      },
      act: (bloc) => bloc.add(UpdateParkingSpace(
        ParkingSpace(id: '1', address: 'Updated Address', pricePerHour: 200),
      )), // Trigger UpdateParkingSpace with an updated parking space
      expect: () => [
        ParkingSpaceLoading(), // First, the loading state is emitted
        ParkingSpaceUpdated(), // Then, the updated state is emitted
        ParkingSpaceLoaded([
          // Finally, the updated list of parking spaces is emitted
          ParkingSpace(id: '1', address: 'Updated Address', pricePerHour: 200),
        ]),
      ],
    );

    // Test case for failed update of parking space
    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'UpdateParkingSpace emits [ParkingSpaceLoading, ParkingSpaceError] when update fails',
      build: () => parkingSpaceBloc,
      setUp: () {
        // Simulate repository throwing an exception when updating a parking space
        when(() => mockRepository.updateParkingSpace(any(), any()))
            .thenThrow(Exception());
      },
      act: (bloc) => bloc.add(UpdateParkingSpace(
        ParkingSpace(id: '1', address: 'Updated Address', pricePerHour: 200),
      )), // Trigger UpdateParkingSpace with the updated parking space
      expect: () => [
        ParkingSpaceLoading(), // First, the loading state is emitted
        const ParkingSpaceError(
            'Error updating parking space: Exception'), // Then, the error state is emitted
      ],
    );
  });

  group('DeleteParkingSpace', () {
    const parkingSpaceId = '1';

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'DeleteParkingSpace emits [ParkingSpaceLoading, ParkingSpaceDeleted, ParkingSpaceLoaded] when delete is successful',
      build: () => parkingSpaceBloc,
      setUp: () {
        // Mock deleteParkingSpace to return a dummy ParkingSpace
        when(() => mockRepository.deleteParkingSpace(any())).thenAnswer(
          (_) async => ParkingSpace(
            id: '1',
            address: 'Old Address',
            pricePerHour: 100,
          ), // Return a dummy ParkingSpace
        );
        when(() => mockRepository.getAllParkingSpaces()).thenAnswer(
          (_) async => [], // Return an empty list after deletion
        );
      },
      act: (bloc) => bloc.add(const DeleteParkingSpace(
          parkingSpaceId)), // Trigger DeleteParkingSpace with a parking space ID
      expect: () => [
        ParkingSpaceLoading(), // First, the loading state is emitted
        ParkingSpaceDeleted(), // Then, the deleted state is emitted
        const ParkingSpaceLoaded(
            []), // Finally, the updated list of parking spaces (empty) is emitted
      ],
    );

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceError] when deleting a parking space fails',
      build: () {
        when(() => mockRepository.deleteParkingSpace(parkingSpaceId))
            .thenThrow(Exception('Failed to delete parking space'));
        return parkingSpaceBloc;
      },
      act: (bloc) => bloc.add(const DeleteParkingSpace(parkingSpaceId)),
      expect: () => [
        ParkingSpaceLoading(),
        const ParkingSpaceError(
            'Failed to delete parking space: Exception: Failed to delete parking space'),
      ],
      verify: (_) {
        verify(() => mockRepository.deleteParkingSpace(parkingSpaceId))
            .called(1);
      },
    );
  });
}
