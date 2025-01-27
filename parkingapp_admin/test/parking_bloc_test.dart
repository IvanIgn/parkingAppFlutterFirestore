import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';
import 'package:parkingapp_admin/blocs/parking/parking_bloc.dart';

class MockParkingRepository extends Mock implements ParkingRepository {}

class FakeParking extends Fake implements Parking {}

void main() {
  late ParkingsBloc parkingsBloc;
  late MockParkingRepository mockParkingRepository;

  setUpAll(() {
    registerFallbackValue(FakeParking());
  });

  setUp(() {
    mockParkingRepository = MockParkingRepository();
    parkingsBloc = ParkingsBloc(parkingRepository: mockParkingRepository);
  });

  tearDown(() {
    parkingsBloc.close();
  });

  group('LoadParkingsEvent', () {
    final mockParkings = [
      Parking(
        id: 1,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        parkingSpace: ParkingSpace(
          id: 1,
          address: 'Testadress 10',
          pricePerHour: 100,
        ),
        vehicle: Vehicle(
          regNumber: 'ABC111',
          vehicleType: 'Bil',
          owner: Person(name: 'TestNamn1', personNumber: '199501071111'),
        ),
      ),
      Parking(
        id: 2,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        parkingSpace: ParkingSpace(
          id: 2,
          address: 'Testadress 20',
          pricePerHour: 200,
        ),
        vehicle: Vehicle(
          regNumber: 'ABC222',
          vehicleType: 'Lastbil',
          owner: Person(name: 'TestNamn2', personNumber: '199501072222'),
        ),
      ),
    ];

    blocTest<ParkingsBloc, MonitorParkingsState>(
      'emits [MonitorParkingsLoadingState, MonitorParkingsLoadedState] on successful fetch',
      build: () {
        when(() => mockParkingRepository.getAllParkings())
            .thenAnswer((_) async => mockParkings);
        return parkingsBloc;
      },
      act: (bloc) => bloc.add(LoadParkingsEvent()),
      expect: () => [
        MonitorParkingsLoadingState(),
        MonitorParkingsLoadedState(mockParkings),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.getAllParkings()).called(1);
      },
    );

    blocTest<ParkingsBloc, MonitorParkingsState>(
      'emits [MonitorParkingsLoadingState, MonitorParkingsErrorState] on fetch failure',
      build: () {
        when(() => mockParkingRepository.getAllParkings())
            .thenThrow(Exception('Failed to load parkings'));
        return parkingsBloc;
      },
      act: (bloc) => bloc.add(LoadParkingsEvent()),
      expect: () => [
        MonitorParkingsLoadingState(),
        MonitorParkingsErrorState(
            'Failed to load parkings. Details: Exception: Failed to load parkings'),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.getAllParkings()).called(1);
      },
    );
    ;
  });

  group('AddParkingEvent', () {
    final parking = Parking(
      id: 1,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      parkingSpace: ParkingSpace(
        id: 1,
        address: 'Testadress 10',
        pricePerHour: 100,
      ),
      vehicle: Vehicle(
        regNumber: 'ABC111',
        vehicleType: 'Bil',
        owner: Person(name: 'TestNamn1', personNumber: '199501071111'),
      ),
    );

    blocTest<ParkingsBloc, MonitorParkingsState>(
      'emits MonitorParkingsLoadedState on successful add',
      build: () {
        when(() => mockParkingRepository.createParking(parking))
            .thenAnswer((_) async => parking);
        when(() => mockParkingRepository.getAllParkings())
            .thenAnswer((_) async => [parking]);
        return parkingsBloc;
      },
      act: (bloc) => bloc.add(AddParkingEvent(parking)),
      expect: () => [
        MonitorParkingsLoadingState(),
        MonitorParkingsLoadedState([parking]),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.createParking(parking)).called(1);
        verify(() => mockParkingRepository.getAllParkings()).called(1);
      },
    );

    blocTest<ParkingsBloc, MonitorParkingsState>(
      'emits MonitorParkingsErrorState on add failure',
      build: () {
        when(() => mockParkingRepository.createParking(parking))
            .thenThrow(Exception('Failed to add parking'));
        return parkingsBloc;
      },
      act: (bloc) => bloc.add(AddParkingEvent(parking)),
      expect: () => [
        MonitorParkingsErrorState('Exception: Failed to add parking'),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.createParking(parking)).called(1);
      },
    );
  });

  group('EditParkingEvent', () {
    final parking = Parking(
      id: 1,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      parkingSpace: ParkingSpace(
        id: 1,
        address: 'Testadress 10',
        pricePerHour: 100,
      ),
      vehicle: Vehicle(
        regNumber: 'ABC111',
        vehicleType: 'Bil',
        owner: Person(name: 'TestNamn1', personNumber: '199501071111'),
      ),
    );

    blocTest<ParkingsBloc, MonitorParkingsState>(
      'emits MonitorParkingsLoadedState on successful edit',
      build: () {
        when(() => mockParkingRepository.updateParking(parking.id, parking))
            .thenAnswer((_) async => parking);
        when(() => mockParkingRepository.getAllParkings())
            .thenAnswer((_) async => [parking]);
        return parkingsBloc;
      },
      act: (bloc) =>
          bloc.add(EditParkingEvent(parkingId: parking.id, parking: parking)),
      expect: () => [
        MonitorParkingsLoadingState(),
        MonitorParkingsLoadedState([parking]),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.updateParking(parking.id, parking))
            .called(1);
        verify(() => mockParkingRepository.getAllParkings()).called(1);
      },
    );

    blocTest<ParkingsBloc, MonitorParkingsState>(
      'emits MonitorParkingsErrorState on edit failure',
      build: () {
        when(() => mockParkingRepository.updateParking(parking.id, parking))
            .thenThrow(Exception('Failed to edit parking'));
        return parkingsBloc;
      },
      act: (bloc) =>
          bloc.add(EditParkingEvent(parkingId: parking.id, parking: parking)),
      expect: () => [
        MonitorParkingsErrorState(
            'Failed to edit parking. Details: Exception: Failed to edit parking'),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.updateParking(parking.id, parking))
            .called(1);
      },
    );
  });

  group('DeleteParkingEvent', () {
    const parkingId = 1;

    blocTest<ParkingsBloc, MonitorParkingsState>(
      'emits MonitorParkingsLoadedState on successful delete',
      build: () {
        when(() => mockParkingRepository.deleteParking(parkingId))
            .thenAnswer((_) async => FakeParking());
        when(() => mockParkingRepository.getAllParkings())
            .thenAnswer((_) async => []);
        return parkingsBloc;
      },
      act: (bloc) => bloc.add(DeleteParkingEvent(parkingId)),
      expect: () => [
        MonitorParkingsLoadingState(),
        MonitorParkingsLoadedState([]),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.deleteParking(parkingId)).called(1);
        verify(() => mockParkingRepository.getAllParkings()).called(1);
      },
    );

    blocTest<ParkingsBloc, MonitorParkingsState>(
      'emits MonitorParkingsErrorState on delete failure',
      build: () {
        when(() => mockParkingRepository.deleteParking(parkingId))
            .thenThrow(Exception('Failed to delete parking'));
        return parkingsBloc;
      },
      act: (bloc) => bloc.add(DeleteParkingEvent(parkingId)),
      expect: () => [
        MonitorParkingsErrorState(
            'Failed to delete parking. Details: Exception: Failed to delete parking'),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.deleteParking(parkingId)).called(1);
      },
    );
  });
}
