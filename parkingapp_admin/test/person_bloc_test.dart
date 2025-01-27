import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkingapp_admin/blocs/person/person_bloc.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';

// Mock the PersonRepository
class MockPersonRepository extends Mock implements PersonRepository {}

// Test Person model that extends Equatable
class FakePerson extends Fake implements Person {}

void main() {
  late MockPersonRepository mockRepository;
  late PersonBloc personBloc;

  setUpAll(() {
    // Register the fallback value for Person
    registerFallbackValue(FakePerson());
  });

  setUp(() {
    mockRepository = MockPersonRepository();
    personBloc = PersonBloc(repository: mockRepository);
  });

  tearDown(() {
    personBloc.close();
  });

  group('PersonBloc Tests', () {
    // Test case for successful fetch of persons
    blocTest<PersonBloc, PersonState>(
      'FetchPersonsEvent emits [PersonLoadingState, PersonLoadedState] when fetch is successful',
      build: () => personBloc,
      setUp: () {
        when(() => mockRepository.getAllPersons()).thenAnswer(
          (_) async => [
            Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
          ],
        );
      },
      act: (bloc) => bloc.add(FetchPersonsEvent()), // Trigger the fetch event
      expect: () => [
        PersonLoadingState(), // First, the loading state is emitted
        PersonLoadedState([
          // Then, the loaded state with persons is emitted
          Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
        ]),
      ],
    );

    // Test case for failed fetch of persons
    blocTest<PersonBloc, PersonState>(
      'FetchPersonsEvent emits [PersonLoadingState, PersonErrorState] when fetch fails',
      build: () => personBloc,
      setUp: () {
        when(() => mockRepository.getAllPersons()).thenThrow(Exception());
      },
      act: (bloc) => bloc.add(FetchPersonsEvent()), // Trigger the fetch event
      expect: () => [
        PersonLoadingState(), // First, the loading state is emitted
        PersonErrorState(
            'Error fetching persons: Exception'), // Then, the error state is emitted
      ],
    );

    // Test case for adding a person successfully
    blocTest<PersonBloc, PersonState>(
      'AddPersonEvent emits [PersonLoadingState, PersonAddedState, PersonLoadedState] when add is successful',
      build: () => personBloc,
      setUp: () {
        // Simulate repository creating a person
        when(() => mockRepository.createPerson(any())).thenAnswer(
          (_) async =>
              Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
        );
        // Simulate repository fetching the updated list of persons
        when(() => mockRepository.getAllPersons()).thenAnswer(
          (_) async => [
            Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
          ],
        );
      },
      act: (bloc) => bloc.add(AddPersonEvent(
        Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
      )), // Trigger AddPersonEvent with a person
      expect: () => [
        PersonLoadingState(), // First, the loading state is emitted
        PersonAddedState(), // Then, the added state is emitted
        PersonLoadedState([
          // Finally, the updated list of persons is emitted
          Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
        ]),
      ],
    );

    // Test case for failed add person operation
    blocTest<PersonBloc, PersonState>(
      'AddPersonEvent emits [PersonLoadingState, PersonErrorState] when add fails',
      build: () => personBloc,
      setUp: () {
        when(() => mockRepository.createPerson(any())).thenThrow(Exception());
      },
      act: (bloc) => bloc.add(AddPersonEvent(
        Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
      )), // Trigger AddPersonEvent with a person
      expect: () => [
        PersonLoadingState(), // First, the loading state is emitted
        PersonErrorState(
            'Error adding person: Exception'), // Then, the error state is emitted
      ],
    );

    // Test case for updating a person successfully
    blocTest<PersonBloc, PersonState>(
      'UpdatePersonEvent emits [PersonLoadingState, PersonUpdatedState, PersonLoadedState] when update is successful',
      build: () => personBloc,
      setUp: () {
        // Simulate repository updating a person
        when(() => mockRepository.updatePerson(any(), any())).thenAnswer(
          (_) async => Person(
              id: 1, name: 'John Doe Updated', personNumber: '199876543211'),
        );
        // Simulate repository fetching the updated list of persons
        when(() => mockRepository.getAllPersons()).thenAnswer(
          (_) async => [
            Person(
                id: 1, name: 'John Doe Updated', personNumber: '199876543211'),
          ],
        );
      },
      act: (bloc) => bloc.add(UpdatePersonEvent(
        Person(id: 1, name: 'John Doe Updated', personNumber: '199876543211'),
      )), // Trigger UpdatePersonEvent with an updated person
      expect: () => [
        PersonLoadingState(), // First, the loading state is emitted
        PersonUpdatedState(), // Then, the updated state is emitted
        PersonLoadedState([
          // Finally, the updated list of persons is emitted
          Person(id: 1, name: 'John Doe Updated', personNumber: '199876543211'),
        ]),
      ],
    );

    // Test case for failed update person operation
    blocTest<PersonBloc, PersonState>(
      'UpdatePersonEvent emits [PersonLoadingState, PersonErrorState] when update fails',
      build: () => personBloc,
      setUp: () {
        // Simulate repository throwing an exception when updating a person
        when(() => mockRepository.updatePerson(any(), any()))
            .thenThrow(Exception());
      },
      act: (bloc) => bloc.add(UpdatePersonEvent(
        Person(id: 1, name: 'John Doe Updated', personNumber: '0987654321'),
      )), // Trigger UpdatePersonEvent with an updated person
      expect: () => [
        PersonLoadingState(), // First, the loading state is emitted
        PersonErrorState(
            'Error updating person: Exception'), // Then, the error state is emitted
      ],
    );
  });

// Test case for deleting a person successfully
  blocTest<PersonBloc, PersonState>(
    'DeletePersonEvent emits [PersonLoadingState, PersonDeletedState, PersonLoadedState] when delete is successful',
    build: () => personBloc,
    setUp: () {
      // Mock deletePerson to return a dummy Person
      when(() => mockRepository.deletePerson(any())).thenAnswer(
        (_) async => Person(
            id: 1,
            name: 'John Doe',
            personNumber: '1234567890'), // Return a dummy Person
      );
      when(() => mockRepository.getAllPersons()).thenAnswer(
        (_) async => [], // Return an empty list after deletion
      );
    },
    act: (bloc) => bloc.add(const DeletePersonEvent(
        1)), // Trigger DeletePersonEvent with a person ID
    expect: () => [
      PersonLoadingState(), // First, the loading state is emitted
      PersonDeletedState(), // Then, the deleted state is emitted
      PersonLoadedState(
          const []), // Finally, the updated list of persons (empty) is emitted
    ],
  );

  // Test case for failed delete person operation
  blocTest<PersonBloc, PersonState>(
    'DeletePersonEvent emits [PersonLoadingState, PersonErrorState] when delete fails',
    build: () => personBloc,
    setUp: () {
      when(() => mockRepository.deletePerson(any())).thenThrow(Exception());
    },
    act: (bloc) => bloc.add(const DeletePersonEvent(
        1)), // Trigger DeletePersonEvent with a person ID
    expect: () => [
      PersonLoadingState(), // First, the loading state is emitted
      PersonErrorState(
          'Error deleting person: Exception'), // Corrected error message without the extra space
    ],
  );
}
