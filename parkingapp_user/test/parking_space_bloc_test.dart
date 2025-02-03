import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shared/shared.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:parkingapp_user/blocs/parking_space/parking_space_bloc.dart';

class MockParkingSpaceRepository extends Mock
    implements ParkingSpaceRepository {}

class MockPersonRepository extends Mock implements PersonRepository {}

class MockParkingRepository extends Mock implements ParkingRepository {}

class MockVehicleRepository extends Mock implements VehicleRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class FakeParkingSpace extends Fake implements ParkingSpace {}

class FakeParking extends Fake implements Parking {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ParkingSpaceBloc parkingSpaceBloc;
  late MockParkingSpaceRepository mockParkingSpaceRepository;
  late MockPersonRepository mockPersonRepository;
  late MockParkingRepository mockParkingRepository;
  late MockVehicleRepository mockVehicleRepository;
  //late MockSharedPreferences mockSharedPreferences;

  setUpAll(() {
    registerFallbackValue(FakeParkingSpace());
    registerFallbackValue(FakeParking());
  });

  setUp(() {
    // Mock SharedPreferences with required values
    SharedPreferences.setMockInitialValues({
      'loggedInPerson': jsonEncode({
        'id': 1,
        'name': 'John Doe',
        'personNumber': '123456789016',
      }),
      // 'selectedParkingSpace':
      //     '', // Explicitly null for the selected parking space
      'selectedParkingSpace': jsonEncode({
        'id': 2,
        'address': 'Testadress 20',
        'pricePerHour': 200,
      }),
      'selectedVehicle': jsonEncode({
        'regNumber': 'ABC123',
        'vehicleType': 'Car',
        'owner': {'id': 1, 'name': 'John Doe', 'personNumber': '123456789016'},
      }),
      'isParkingActive': false,
    });

    // Initialize mock repositories
    mockParkingSpaceRepository = MockParkingSpaceRepository();
    mockPersonRepository = MockPersonRepository();
    mockParkingRepository = MockParkingRepository();
    mockVehicleRepository = MockVehicleRepository();

    // Instantiate the ParkingSpaceBloc with mocked preferences
    parkingSpaceBloc = ParkingSpaceBloc(
      parkingSpaceRepository: mockParkingSpaceRepository,
      personRepository: mockPersonRepository,
      parkingRepository: mockParkingRepository,
      vehicleRepository: mockVehicleRepository,
    );

    when(() => mockParkingRepository.getAllParkings())
        .thenAnswer((_) async => []);
    when(() => mockParkingRepository.createParking(any()))
        .thenAnswer((invocation) async => invocation.positionalArguments.first);
  });

  tearDown(() {
    parkingSpaceBloc.close();
  });

  group('LoadParkingSpaces', () {
    final parkingSpaces = [
      ParkingSpace(id: 1, address: 'Testadress 10', pricePerHour: 100),
      ParkingSpace(id: 2, address: 'Testadress 20', pricePerHour: 200),
    ];

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceLoading, ParkingSpaceLoaded] when loading is successful',
      build: () {
        // Mock SharedPreferences to return a selectedParkingSpace
        SharedPreferences.setMockInitialValues({
          'selectedParkingSpace': jsonEncode({
            'id': 1,
            'address': 'Testadress 10',
            'pricePerHour': 100,
          }),
          'isParkingActive':
              false, // You can mock other preferences here if needed
        });

        when(() => mockParkingSpaceRepository.getAllParkingSpaces())
            .thenAnswer((_) async => parkingSpaces);
        return parkingSpaceBloc;
      },
      act: (bloc) => bloc.add(LoadParkingSpaces()),
      expect: () => [
        ParkingSpaceLoading(),
        ParkingSpaceLoaded(
          parkingSpaces: parkingSpaces,
          selectedParkingSpace: parkingSpaces
              .first, // Set it explicitly to the first parking space
          isParkingActive: false,
        ),
      ],
      verify: (_) {
        verify(() => mockParkingSpaceRepository.getAllParkingSpaces())
            .called(1);
      },
    );

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceLoading, ParkingSpaceError] when loading fails',
      build: () {
        when(() => mockParkingSpaceRepository.getAllParkingSpaces())
            .thenThrow(Exception('Failed to load parking spaces'));
        return parkingSpaceBloc;
      },
      act: (bloc) => bloc.add(LoadParkingSpaces()),
      expect: () => [
        ParkingSpaceLoading(),
        ParkingSpaceError('Exception: Failed to load parking spaces'),
      ],
    );
  });

  group('SelectParkingSpace', () {
    final parkingSpace =
        ParkingSpace(id: 1, address: 'Testadress 10', pricePerHour: 100);

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'updates selected parking space in state',
      build: () => parkingSpaceBloc,
      seed: () => ParkingSpaceLoaded(
        parkingSpaces: [parkingSpace],
        selectedParkingSpace: null,
        isParkingActive: false,
      ),
      act: (bloc) => bloc.add(SelectParkingSpace(parkingSpace)),
      expect: () => [
        ParkingSpaceLoaded(
          parkingSpaces: [parkingSpace],
          selectedParkingSpace: parkingSpace,
          isParkingActive: false,
        ),
      ],
    );
  });

  group('DeselectParkingSpace', () {
    final parkingSpace =
        ParkingSpace(id: 1, address: 'Testadress 10', pricePerHour: 100);

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'clears selected parking space in state',
      build: () => parkingSpaceBloc,
      seed: () => ParkingSpaceLoaded(
        parkingSpaces: [parkingSpace],
        selectedParkingSpace: parkingSpace,
        isParkingActive: false,
      ),
      act: (bloc) => bloc.add(DeselectParkingSpace()),
      expect: () => [
        ParkingSpaceLoaded(
          parkingSpaces: [parkingSpace],
          selectedParkingSpace: null,
          isParkingActive: false,
        ),
      ],
    );
  });

  group('StartParking', () {
    final parkingSpace =
        ParkingSpace(id: 2, address: 'Testadress 20', pricePerHour: 200);
    final parking = Parking(
      id: 2,
      startTime: DateTime(2025, 1, 28, 10, 0, 0),
      endTime: DateTime(2025, 1, 28, 11, 0, 0),
      parkingSpace: parkingSpace,
      vehicle: Vehicle(
          id: 0,
          regNumber: 'ABC222',
          vehicleType: 'Lastbil',
          owner:
              Person(id: 0, name: 'TestNamn2', personNumber: '199501072222')),

      // Before the mocked DateTime.now
    );

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'starts parking and updates state',
      setUp: () {
        when(() => mockParkingRepository.createParking(any()))
            .thenAnswer((_) async {
          return parking;
        });

        when(() => mockParkingRepository.getAllParkings()).thenAnswer(
          (_) async => [parking], // Ensure it returns the expected parking
        );
      },
      build: () => parkingSpaceBloc,
      seed: () => ParkingSpaceLoaded(
        parkingSpaces: [parkingSpace],
        selectedParkingSpace: parkingSpace,
        isParkingActive: false,
      ),
      act: (bloc) => bloc.add(StartParking()),
      expect: () => [
        ParkingSpaceLoaded(
          parkingSpaces: [parkingSpace],
          selectedParkingSpace: parkingSpace,
          isParkingActive: true,
        ),
      ],
    );
  });

  group('StopParking', () {
    final parkingSpace =
        ParkingSpace(id: 1, address: 'Testadress 10', pricePerHour: 100);

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'stops parking and updates state',
      build: () => parkingSpaceBloc,
      seed: () => ParkingSpaceLoaded(
        parkingSpaces: [parkingSpace],
        selectedParkingSpace: parkingSpace,
        isParkingActive: true,
      ),
      act: (bloc) => bloc.add(StopParking()),
      expect: () => [
        ParkingSpaceLoaded(
          parkingSpaces: [parkingSpace],
          selectedParkingSpace: null,
          isParkingActive: false,
        ),
      ],
    );
  });
}
