import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/shared.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:parkingapp_user/blocs/parking/parking_bloc.dart';
import 'package:clock/clock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MockParkingRepository extends Mock implements ParkingRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class FakeParking extends Fake implements Parking {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  late ParkingBloc parkingBloc;
  late MockParkingRepository mockParkingRepository;
  late SharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockParkingRepository = MockParkingRepository();
    parkingBloc = ParkingBloc(
      parkingRepository: mockParkingRepository,
      sharedPreferences: mockSharedPreferences,
    );
    parkingBloc = ParkingBloc(
      parkingRepository: mockParkingRepository,
      sharedPreferences: mockSharedPreferences,
    );
    when(() => mockSharedPreferences.getString('loggedInPerson'))
        .thenReturn(json.encode({'id': 0})); // Simulate a logged-in user
  });

  setUpAll(() {
    registerFallbackValue(FakeParking());
  });

  tearDown(() {
    parkingBloc.close();
  });

  group('LoadActiveParkings', () {
    final activeParkings = [
      Parking(
        id: '1',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        parkingSpace:
            ParkingSpace(id: '1', address: 'Testadress 10', pricePerHour: 100),
        vehicle: Vehicle(
            regNumber: 'ABC111',
            vehicleType: 'Bil',
            owner: Person(name: 'TestNamn1', personNumber: '199501071111')),
      ),
      Parking(
        id: '2',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        parkingSpace:
            ParkingSpace(id: '2', address: 'Testadress 20', pricePerHour: 200),
        vehicle: Vehicle(
            regNumber: 'ABC222',
            vehicleType: 'Lastbil',
            owner: Person(name: 'TestNamn2', personNumber: '199501072222')),
      )
    ];

    blocTest<ParkingBloc, ParkingState>(
      'emits [ParkingsLoading, ActiveParkingsLoaded] on successful fetch',
      setUp: () {
        // Mock SharedPreferences to return a logged-in user
        when(() => mockSharedPreferences.getString('loggedInPerson'))
            .thenReturn(
          json.encode({'id': 0}), // Simulate a logged-in user with ID 0
        );

        // Mock repository to return active parkings
        when(() => mockParkingRepository.getAllParkings()).thenAnswer(
          (_) async => activeParkings, // Ensure this matches logged-in user
        );
      },
      build: () => ParkingBloc(
        parkingRepository: mockParkingRepository,
        sharedPreferences:
            mockSharedPreferences, // Inject mock SharedPreferences
      ),
      act: (bloc) => bloc.add(LoadActiveParkings()), // Trigger the event
      expect: () {
        return [
          ParkingsLoading(),
          ActiveParkingsLoaded(
              parkings: activeParkings), // Correct expected state
        ];
      },
      verify: (_) {
        verify(() => mockParkingRepository.getAllParkings())
            .called(1); // Ensure method is called once
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits [ParkingsLoading, ParkingsError] on fetch failure',
      build: () {
        when(() => mockParkingRepository.getAllParkings())
            .thenThrow(Exception('Failed to load active parkings'));
        return parkingBloc;
      },
      act: (bloc) => bloc.add(LoadActiveParkings()),
      expect: () => [
        ParkingsLoading(),
        const ParkingsError(
            message: 'Exception: Failed to load active parkings'),
      ],
    );
  });

  group('LoadNonActiveParkings', () {
    final nonActiveParkings = [
      Parking(
        id: '2',
        startTime: DateTime(2025, 1, 28, 10, 0, 0),
        endTime: DateTime(2025, 1, 28, 11, 0, 0),
        parkingSpace:
            ParkingSpace(id: '2', address: 'Testadress 20', pricePerHour: 200),
        vehicle: Vehicle(
            id: '0',
            regNumber: 'ABC222',
            vehicleType: 'Lastbil',
            owner: Person(
                id: '0', name: 'TestNamn2', personNumber: '199501072222')),

        // Before the mocked DateTime.now
      ),
    ];

    blocTest<ParkingBloc, ParkingState>(
      'emits [ParkingsLoading, ParkingsLoaded] on successful fetch',
      build: () {
        final now = DateTime(2025, 1, 28, 12, 0, 0); // Fixed test time
        withClock(Clock.fixed(now), () {
          when(() => mockParkingRepository.getAllParkings())
              .thenAnswer((_) async => nonActiveParkings);
        });
        return ParkingBloc(
          parkingRepository: mockParkingRepository,
          sharedPreferences: mockSharedPreferences,
        );
      },
      act: (bloc) => bloc.add(LoadNonActiveParkings()),
      expect: () => [
        ParkingsLoading(),
        ParkingsLoaded(parkings: nonActiveParkings),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.getAllParkings()).called(1);
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits [ParkingsLoading, ParkingsError] on fetch failure',
      build: () {
        when(() => mockParkingRepository.getAllParkings())
            .thenThrow(Exception('Failed to load non-active parkings'));
        return parkingBloc;
      },
      act: (bloc) => bloc.add(LoadNonActiveParkings()),
      expect: () => [
        ParkingsLoading(),
        const ParkingsError(
            message: 'Exception: Failed to load non-active parkings'),
      ],
    );
  });

  group('AddParkingEvent', () {
    final parking = Parking(
      id: '1',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      parkingSpace: ParkingSpace(
        id: '1',
        address: 'Testadress 10',
        pricePerHour: 100,
      ),
      vehicle: Vehicle(
        regNumber: 'ABC111',
        vehicleType: 'Bil',
        owner: Person(name: 'TestNamn1', personNumber: '199501071111'),
      ),
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits ParkingsLoadedState on successful add',
      build: () {
        // Mock repository methods
        when(() => mockParkingRepository.createParking(parking))
            .thenAnswer((_) async => parking);
        when(() => mockParkingRepository.getAllParkings()).thenAnswer(
            (_) async => [parking]); // Returns a list with `parking`

        return parkingBloc;
      },
      act: (bloc) => bloc.add(CreateParking(parking: parking)),
      expect: () => [
        ParkingsLoading(), // First state emitted
        ActiveParkingsLoaded(
            parkings: [parking]), // Updated to match actual behavior
      ],
      verify: (_) {
        verify(() => mockParkingRepository.createParking(parking)).called(1);
        verify(() => mockParkingRepository.getAllParkings()).called(1);
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits ParkingsLoading and then ParkingsError on add failure',
      build: () {
        // Mock createParking to throw an exception
        when(() => mockParkingRepository.createParking(parking))
            .thenThrow(Exception('Failed to add parking'));
        return parkingBloc;
      },
      act: (bloc) => bloc.add(CreateParking(parking: parking)),
      expect: () => [
        ParkingsLoading(), // First state emitted
        const ParkingsError(
            message: 'Exception: Failed to add parking'), // Error state
      ],
      verify: (_) {
        verify(() => mockParkingRepository.createParking(parking)).called(1);
      },
    );
  });

  group('UpdateParkingEvent', () {
    final parking = Parking(
      id: '1',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      parkingSpace: ParkingSpace(
        id: '1',
        address: 'Testadress 10',
        pricePerHour: 100,
      ),
      vehicle: Vehicle(
        regNumber: 'ABC111',
        vehicleType: 'Bil',
        owner: Person(name: 'TestNamn1', personNumber: '199501071111'),
      ),
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits ActiveParkingsLoadedState on successful update',
      setUp: () {
        // Mock SharedPreferences to return a logged-in user
        when(() => mockSharedPreferences.getString('loggedInPerson'))
            .thenReturn(json.encode({'id': 0})); // Simulate a logged-in user

        // Mock updateParking method
        when(() => mockParkingRepository.updateParking(parking.id, parking))
            .thenAnswer((_) async => parking);

        // 🛠 FIX: Mock getAllParkings() to return a valid Future<List<Parking>>
        when(() => mockParkingRepository.getAllParkings())
            .thenAnswer((_) async => [parking]); // Ensure correct return type
      },
      build: () => ParkingBloc(
        parkingRepository: mockParkingRepository,
        sharedPreferences: mockSharedPreferences, // Inject SharedPreferences
      ),
      act: (bloc) => bloc.add(UpdateParking(parking: parking)),
      expect: () => [
        ParkingsLoading(),
        ActiveParkingsLoaded(parkings: [parking]), // Ensure correct state
      ],
      verify: (_) {
        verify(() => mockParkingRepository.updateParking(parking.id, parking))
            .called(1);
        verify(() => mockParkingRepository.getAllParkings()).called(1);
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits ParkingErrorState on update failure',
      build: () {
        when(() => mockParkingRepository.updateParking(parking.id, parking))
            .thenThrow(Exception('Failed to edit parking'));
        return parkingBloc;
      },
      act: (bloc) => bloc.add(UpdateParking(parking: parking)),
      expect: () => [
        const ParkingsError(
            message:
                'Failed to edit parking. Details: Exception: Failed to edit parking'),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.updateParking(parking.id, parking))
            .called(1);
      },
    );
  });

  group('DeleteParkingEvent', () {
    const parkingId = '1';

    blocTest<ParkingBloc, ParkingState>(
      'emits ParkingLoadedState on successful delete',
      build: () {
        when(() => mockParkingRepository.deleteParking(parkingId))
            .thenAnswer((_) async => FakeParking());
        when(() => mockParkingRepository.getAllParkings())
            .thenAnswer((_) async => []);
        return parkingBloc;
      },
      act: (bloc) => bloc.add(DeleteParking(
          parking: Parking(
        id: parkingId,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        parkingSpace:
            ParkingSpace(id: '1', address: 'Testadress 10', pricePerHour: 100),
        vehicle: Vehicle(
            regNumber: 'ABC111',
            vehicleType: 'Bil',
            owner: Person(name: 'TestNamn1', personNumber: '199501071111')),
      ))),
      expect: () => [
        ParkingsLoading(),
        const ParkingsLoaded(parkings: []),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.deleteParking(parkingId)).called(1);
        verify(() => mockParkingRepository.getAllParkings()).called(1);
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits MonitorParkingsErrorState on delete failure',
      build: () {
        when(() => mockParkingRepository.deleteParking(parkingId))
            .thenThrow(Exception('Failed to delete parking'));
        return parkingBloc;
      },
      act: (bloc) => bloc.add(DeleteParking(
          parking: Parking(
              id: parkingId,
              startTime: DateTime.now(),
              endTime: DateTime.now().add(const Duration(hours: 2)),
              parkingSpace: ParkingSpace(
                  id: '1', address: 'Testadress 10', pricePerHour: 100),
              vehicle: Vehicle(
                  regNumber: 'ABC111',
                  vehicleType: 'Bil',
                  owner: Person(
                      name: 'TestNamn1', personNumber: '199501071111'))))),
      expect: () => [
        const ParkingsError(
            message:
                'Failed to delete parking. Details: Exception: Failed to delete parking'),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.deleteParking(parkingId)).called(1);
      },
    );
  });
}
