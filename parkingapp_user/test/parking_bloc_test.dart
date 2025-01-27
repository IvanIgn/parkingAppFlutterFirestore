import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/shared.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:parkingapp_user/blocs/parking/parking_bloc.dart';

class MockParkingRepository extends Mock implements ParkingRepository {}

class FakeParking extends Fake implements Parking {}

void main() {
  late ParkingBloc parkingBloc;
  late MockParkingRepository mockParkingRepository;

  setUp(() {
    mockParkingRepository = MockParkingRepository();
    parkingBloc = ParkingBloc();
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
        id: 1,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        parkingSpace:
            ParkingSpace(id: 1, address: 'Testadress 10', pricePerHour: 100),
        vehicle: Vehicle(
            regNumber: 'ABC111',
            vehicleType: 'Bil',
            owner: Person(name: 'TestNamn1', personNumber: '199501071111')),
      ),
      Parking(
        id: 2,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        parkingSpace:
            ParkingSpace(id: 2, address: 'Testadress 20', pricePerHour: 200),
        vehicle: Vehicle(
            regNumber: 'ABC222',
            vehicleType: 'Lastbil',
            owner: Person(name: 'TestNamn2', personNumber: '199501072222')),
      )
    ];

    blocTest<ParkingBloc, ParkingState>(
      'emits [ParkingsLoading, ActiveParkingsLoaded] on successful fetch',
      build: () {
        when(() => mockParkingRepository.getAllParkings())
            .thenAnswer((_) async => activeParkings);
        return parkingBloc;
      },
      act: (bloc) => bloc.add(LoadActiveParkings()),
      expect: () => [
        ParkingsLoading(),
        ActiveParkingsLoaded(parkings: activeParkings),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.getAllParkings()).called(1);
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
        ParkingsError(message: 'Exception: Failed to load active parkings'),
      ],
    );
  });

  group('LoadNonActiveParkings', () {
    final nonActiveParkings = [
      Parking(
        id: 2,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        parkingSpace:
            ParkingSpace(id: 2, address: 'Testadress 20', pricePerHour: 200),
        vehicle: Vehicle(
            regNumber: 'ABC222',
            vehicleType: 'Lastbil',
            owner: Person(name: 'TestNamn2', personNumber: '199501072222')),
      ),
    ];

    blocTest<ParkingBloc, ParkingState>(
      'emits [ParkingsLoading, ParkingsLoaded] on successful fetch',
      build: () {
        when(() => mockParkingRepository.getAllParkings())
            .thenAnswer((_) async => nonActiveParkings);
        return parkingBloc;
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
        ParkingsError(message: 'Exception: Failed to load non-active parkings'),
      ],
    );
  });

  group('CreateParking', () {
    final newParking = Parking(
      id: 3,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 3)),
      parkingSpace:
          ParkingSpace(id: 3, address: 'Testadress 300', pricePerHour: 300),
      vehicle: Vehicle(
          regNumber: 'CBA333',
          vehicleType: 'Bil',
          owner: Person(name: 'TestNamn3', personNumber: '199303253333')),
    );

    blocTest<ParkingBloc, ParkingState>(
      'calls createParking and refreshes active parkings',
      build: () {
        when(() => mockParkingRepository.createParking(newParking))
            .thenAnswer((_) async => Future.value());
        when(() => mockParkingRepository.getAllParkings())
            .thenAnswer((_) async => [newParking]);
        return parkingBloc;
      },
      act: (bloc) => bloc.add(CreateParking(parking: newParking)),
      expect: () => [
        ParkingsLoading(),
        ActiveParkingsLoaded(parkings: [newParking]),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.createParking(newParking)).called(1);
        verify(() => mockParkingRepository.getAllParkings()).called(1);
      },
    );
  });

  group('UpdateParking', () {
    final updatedParking = Parking(
      id: 3,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 3)),
      parkingSpace:
          ParkingSpace(id: 3, address: 'Testadress 300', pricePerHour: 300),
      vehicle: Vehicle(
          regNumber: 'CBA333',
          vehicleType: 'Bil',
          owner: Person(name: 'TestNamn3', personNumber: '199303253333')),
    );

    blocTest<ParkingBloc, ParkingState>(
      'calls updateParking and refreshes active parkings',
      build: () {
        when(() => mockParkingRepository.updateParking(
                updatedParking.id, updatedParking))
            .thenAnswer((_) async => Future.value());
        when(() => mockParkingRepository.getAllParkings())
            .thenAnswer((_) async => [updatedParking]);
        return parkingBloc;
      },
      act: (bloc) => bloc.add(UpdateParking(parking: updatedParking)),
      expect: () => [
        ParkingsLoading(),
        ActiveParkingsLoaded(parkings: [updatedParking]),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.updateParking(
            updatedParking.id, updatedParking)).called(1);
        verify(() => mockParkingRepository.getAllParkings()).called(1);
      },
    );
  });

  group('DeleteParking', () {
    final parkingToDelete = Parking(
      id: 4,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 3)),
      parkingSpace:
          ParkingSpace(id: 3, address: 'Testadress 300', pricePerHour: 300),
      vehicle: Vehicle(
          regNumber: 'CBA333',
          vehicleType: 'Bil',
          owner: Person(name: 'TestNamn3', personNumber: '199303253333')),
    );

    blocTest<ParkingBloc, ParkingState>(
      'calls deleteParking and refreshes active parkings',
      build: () {
        when(() => mockParkingRepository.deleteParking(parkingToDelete.id))
            .thenAnswer((_) async => Future.value());
        when(() => mockParkingRepository.getAllParkings())
            .thenAnswer((_) async => []);
        return parkingBloc;
      },
      act: (bloc) => bloc.add(DeleteParking(parking: parkingToDelete)),
      expect: () => [
        ParkingsLoading(),
        ActiveParkingsLoaded(parkings: []),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.deleteParking(parkingToDelete.id))
            .called(1);
        verify(() => mockParkingRepository.getAllParkings()).called(1);
      },
    );
  });
}
