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

void main() {
  late ParkingSpaceBloc parkingSpaceBloc;
  late MockParkingSpaceRepository mockParkingSpaceRepository;
  late MockPersonRepository mockPersonRepository;
  late MockParkingRepository mockParkingRepository;
  late MockVehicleRepository mockVehicleRepository;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    mockParkingSpaceRepository = MockParkingSpaceRepository();
    mockPersonRepository = MockPersonRepository();
    mockParkingRepository = MockParkingRepository();
    mockVehicleRepository = MockVehicleRepository();
    sharedPreferences = await SharedPreferences.getInstance();

    parkingSpaceBloc = ParkingSpaceBloc(
      parkingSpaceRepository: mockParkingSpaceRepository,
      personRepository: mockPersonRepository,
      parkingRepository: mockParkingRepository,
      vehicleRepository: mockVehicleRepository,
    );
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
        when(() => mockParkingSpaceRepository.getAllParkingSpaces())
            .thenAnswer((_) async => parkingSpaces);
        when(() => sharedPreferences.getString('selectedParkingSpace'))
            .thenReturn(null);
        when(() => sharedPreferences.getBool('isParkingActive'))
            .thenReturn(false);
        return parkingSpaceBloc;
      },
      act: (bloc) => bloc.add(LoadParkingSpaces()),
      expect: () => [
        ParkingSpaceLoading(),
        ParkingSpaceLoaded(
          parkingSpaces: parkingSpaces,
          selectedParkingSpace: null,
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
      build: () {
        when(() => sharedPreferences.setString(
                'selectedParkingSpace', json.encode(parkingSpace.toJson())))
            .thenAnswer((_) async => true);
        return parkingSpaceBloc;
      },
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
      verify: (_) {
        verify(() => sharedPreferences.setString(
                'selectedParkingSpace', json.encode(parkingSpace.toJson())))
            .called(1);
      },
    );
  });

  group('DeselectParkingSpace', () {
    final parkingSpace =
        ParkingSpace(id: 1, address: 'Testadress 10', pricePerHour: 100);

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'clears selected parking space in state',
      build: () {
        when(() => sharedPreferences.remove('selectedParkingSpace'))
            .thenAnswer((_) async => true);
        return parkingSpaceBloc;
      },
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
      verify: (_) {
        verify(() => sharedPreferences.remove('selectedParkingSpace'))
            .called(1);
      },
    );
  });

  group('StartParking', () {
    final parkingSpace =
        ParkingSpace(id: 1, address: 'Testadress 10', pricePerHour: 100);
    final vehicle = Vehicle(
      regNumber: 'ABC123',
      vehicleType: 'Bil',
      owner: Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
    );
    final parking = Parking(
      id: 1,
      vehicle: vehicle,
      parkingSpace: parkingSpace,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
    );

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'starts parking and updates state',
      build: () {
        when(() => mockParkingRepository.createParking(parking))
            .thenAnswer((_) async => Future.value());
        when(() => sharedPreferences.setBool('isParkingActive', true))
            .thenAnswer((_) async => true);
        when(() => sharedPreferences.setString(
                'activeParkingSpace', json.encode(parkingSpace.toJson())))
            .thenAnswer((_) async => true);
        return parkingSpaceBloc;
      },
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
    final parking = Parking(
      id: 1,
      vehicle: Vehicle(
        regNumber: 'ABC123',
        vehicleType: 'Bil',
        owner: Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
      ),
      parkingSpace:
          ParkingSpace(id: 1, address: 'Testadress 10', pricePerHour: 100),
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
    );

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'stops parking and updates state',
      build: () {
        when(() => sharedPreferences.remove('isParkingActive'))
            .thenAnswer((_) async => true);
        when(() => sharedPreferences.remove('parking'))
            .thenAnswer((_) async => true);
        when(() => mockParkingRepository.deleteParking(parking.id))
            .thenAnswer((_) async => Future.value());
        return parkingSpaceBloc;
      },
      seed: () => ParkingSpaceLoaded(
        parkingSpaces: [
          parking.parkingSpace ??
              ParkingSpace(id: 0, address: '', pricePerHour: 0)
        ],
        selectedParkingSpace: parking.parkingSpace,
        isParkingActive: true,
      ),
      act: (bloc) => bloc.add(StopParking()),
      expect: () => [
        ParkingSpaceLoaded(
          parkingSpaces: [
            parking.parkingSpace ??
                ParkingSpace(id: 0, address: '', pricePerHour: 0)
          ],
          selectedParkingSpace: null,
          isParkingActive: false,
        ),
      ],
    );
  });
}
