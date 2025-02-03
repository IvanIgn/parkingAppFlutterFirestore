import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/shared.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:parkingapp_user/blocs/person/person_bloc.dart';

class MockPersonRepository extends Mock implements PersonRepository {}

class FakePerson extends Fake implements Person {
  @override
  int get id => 1;

  @override
  String get name => 'John Doe';

  @override
  String get personNumber => '123456789016';
}

void main() {
  late PersonBloc personBloc;
  late MockPersonRepository mockPersonRepository;

  setUp(() {
    mockPersonRepository = MockPersonRepository();
    //when(() => PersonRepository.instance).thenReturn(mockPersonRepository);

    personBloc = PersonBloc(repository: mockPersonRepository);

    when(() => mockPersonRepository.getAllPersons()).thenAnswer(
      (_) async => [
        Person(id: 1, name: 'John Doe', personNumber: '123456789016'),
      ],
    );

    final person =
        Person(id: 1, name: 'John Doe', personNumber: '123456789016');
    when(() => mockPersonRepository.getPersonById(person.id))
        .thenAnswer((_) async => person);
  });

  tearDown(() {
    personBloc.close();
  });

  group('LoadPersons', () {
    group('PersonBloc Tests', () {
      // Test case for successful fetch of persons
      blocTest<PersonBloc, PersonState>(
        'emits [PersonsLoading, PersonsLoaded] when LoadPersons is successful',
        build: () => personBloc,
        setUp: () {
          // Mocking the repository to return a person
          when(() => mockPersonRepository.getAllPersons()).thenAnswer(
            (_) async => [
              Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
            ],
          );
        },
        act: (bloc) {
          // Ensure async completion by adding await
          bloc.add(LoadPersons()); // Dispatch LoadPersons event
        },
        expect: () => [
          PersonsLoading(), // Expect PersonsLoading state to be emitted first
          PersonsLoaded(persons: [
            Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
          ]), // Then, expect PersonsLoaded with person data
        ],
        verify: (_) {
          // Verify that the repository's getAllPersons method was called once
          verify(() => mockPersonRepository.getAllPersons()).called(1);
        },
      );

      blocTest<PersonBloc, PersonState>(
        'emits [PersonsLoading, PersonsError] when LoadPersons fails',
        build: () {
          when(() => mockPersonRepository.getAllPersons())
              .thenThrow(Exception('Failed to load persons'));
          return personBloc;
        },
        act: (bloc) => bloc.add(LoadPersons()),
        expect: () => [
          PersonsLoading(),
          PersonsError(message: 'Exception: Failed to load persons'),
        ],
      );
    });

    group('LoadPersonsById', () {
      final person =
          Person(id: 1, name: 'John Doe', personNumber: '123456789016');

      blocTest<PersonBloc, PersonState>(
        'emits [PersonsLoading, PersonLoaded] when LoadPersonsById is successful',
        build: () {
          when(() => mockPersonRepository.getPersonById(person.id)).thenAnswer(
              (_) async =>
                  person); // Mock repository to return the person object
          return personBloc;
        },
        act: (bloc) async {
          bloc.add(LoadPersonsById(person: person)); // Ensure async completion
        },
        expect: () => [
          PersonsLoading(), // First, expect PersonsLoading state
          PersonLoaded(
              person:
                  person), // Then expect PersonLoaded state with the correct person data
        ],
        verify: (_) {
          verify(() => mockPersonRepository.getPersonById(person.id))
              .called(1); // Verify the method was called
        },
      );

      blocTest<PersonBloc, PersonState>(
        'emits [PersonsLoading, PersonsError] when LoadPersonsById fails',
        build: () {
          when(() => mockPersonRepository.getPersonById(person.id))
              .thenThrow(Exception('Failed to load person by ID'));
          return personBloc;
        },
        act: (bloc) => bloc.add(LoadPersonsById(person: person)),
        expect: () => [
          PersonsLoading(),
          PersonsError(message: 'Exception: Failed to load person by ID'),
        ],
      );
    });

    group('CreatePerson', () {
      final person =
          Person(id: 1, name: 'John Doe', personNumber: '123456789016');
      final updatedPersonList = [
        person,
        Person(id: 2, name: 'Jane Doe', personNumber: '098765432113'),
      ];

      blocTest<PersonBloc, PersonState>(
        'emits [PersonsLoaded] when CreatePerson is successful',
        build: () {
          when(() => mockPersonRepository.createPerson(person)).thenAnswer(
              (_) async =>
                  FakePerson()); // Ensure person is created successfully
          when(() => mockPersonRepository.getAllPersons()).thenAnswer(
              (_) async => updatedPersonList); // Ensure mock returns valid list
          return personBloc;
        },
        act: (bloc) async {
          bloc.add(
              CreatePerson(person: person)); // Ensure async action is awaited
        },
        expect: () => [
          PersonsLoaded(persons: updatedPersonList), // Expect the updated list
        ],
        verify: (_) {
          verify(() => mockPersonRepository.createPerson(person)).called(1);
          verify(() => mockPersonRepository.getAllPersons()).called(1);
        },
      );

      blocTest<PersonBloc, PersonState>(
        'emits [PersonsError] when CreatePerson fails',
        build: () {
          when(() => mockPersonRepository.createPerson(person))
              .thenThrow(Exception('Failed to create person'));
          return personBloc;
        },
        act: (bloc) => bloc.add(CreatePerson(person: person)),
        expect: () => [
          PersonsError(message: 'Exception: Failed to create person'),
        ],
      );
    });

    group('UpdatePerson', () {
      final person =
          Person(id: 1, name: 'John Doe', personNumber: '1234567890');

      blocTest<PersonBloc, PersonState>(
        'emits [PersonsLoading, PersonLoaded] when UpdatePerson is successful',
        build: () {
          // Mocking updatePerson to return the correct Person object
          when(() => mockPersonRepository.updatePerson(person.id, person))
              .thenAnswer((_) async => person);
          when(() => mockPersonRepository.getPersonById(person.id))
              .thenAnswer((_) async => person);
          return personBloc;
        },
        act: (bloc) =>
            bloc.add(UpdatePersons(person: person)), // Trigger update event
        expect: () => [
          PersonsLoading(), // Expect loading state first
          PersonLoaded(
              person: person), // Then expect the updated person to be loaded
        ],
        verify: (_) {
          verify(
              () =>
                  mockPersonRepository.updatePerson(person.id, person)).called(
              1); // Verify updatePerson was called with the correct id and person
          verify(() => mockPersonRepository.getPersonById(person.id))
              .called(1); // Verify fetching the updated person
        },
      );

      blocTest<PersonBloc, PersonState>(
        'emits [PersonsLoading, PersonsError] when UpdatePerson fails',
        build: () {
          // Simulate failure in update
          when(() => mockPersonRepository.updatePerson(person.id, person))
              .thenThrow(Exception('Failed to update person'));
          return personBloc;
        },
        act: (bloc) =>
            bloc.add(UpdatePersons(person: person)), // Trigger update event
        expect: () => [
          PersonsLoading(), // Expect loading state first
          PersonsError(
              message:
                  'Exception: Failed to update person'), // Expect error state
        ],
      );
    });

    group('DeletePerson', () {
      final person =
          Person(id: 1, name: 'John Doe', personNumber: '123456789016');
      final updatedPersonList = [
        Person(id: 2, name: 'Jane Doe', personNumber: '098765432116'),
      ];

      blocTest<PersonBloc, PersonState>(
        'emits [PersonsLoaded] when DeletePerson is successful',
        build: () {
          // Simulate successful deletion of person
          when(() => mockPersonRepository.deletePerson(person.id))
              .thenAnswer((_) async => FakePerson());

          // Simulate getting updated list of persons after deletion
          when(() => mockPersonRepository.getAllPersons())
              .thenAnswer((_) async => updatedPersonList);

          return personBloc;
        },
        act: (bloc) =>
            bloc.add(DeletePersons(person: person)), // Trigger the delete event
        expect: () => [
          PersonsLoaded(persons: updatedPersonList), // Expect updated list
        ],
        verify: (_) {
          // Verify deletePerson is called with the correct ID
          verify(() => mockPersonRepository.deletePerson(person.id)).called(1);

          // Verify getAllPersons is called after deletion to get the updated list
          verify(() => mockPersonRepository.getAllPersons()).called(1);
        },
      );

      blocTest<PersonBloc, PersonState>(
        'emits [PersonsError] when DeletePerson fails',
        build: () {
          when(() => mockPersonRepository.deletePerson(person.id))
              .thenThrow(Exception('Failed to delete person'));
          return personBloc;
        },
        act: (bloc) => bloc.add(DeletePersons(person: person)),
        expect: () => [
          PersonsError(message: 'Exception: Failed to delete person'),
        ],
      );
    });
  });
}
