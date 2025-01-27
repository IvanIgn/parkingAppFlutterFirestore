import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/shared.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:parkingapp_user/blocs/person/person_bloc.dart';

class MockPersonRepository extends Mock implements PersonRepository {}

void main() {
  late PersonBloc personBloc;
  late MockPersonRepository mockPersonRepository;

  setUp(() {
    mockPersonRepository = MockPersonRepository();
    when(() => PersonRepository.instance).thenReturn(mockPersonRepository);

    personBloc = PersonBloc();
  });

  tearDown(() {
    personBloc.close();
  });

  group('LoadPersons', () {
    final personList = [
      Person(id: 1, name: 'John Doe', personNumber: '1234567890'),
      Person(id: 2, name: 'Jane Loan', personNumber: '0987654321'),
    ];

    blocTest<PersonBloc, PersonState>(
      'emits [PersonsLoading, PersonsLoaded] when LoadPersons is successful',
      build: () {
        when(() => mockPersonRepository.getAllPersons())
            .thenAnswer((_) async => personList);
        return personBloc;
      },
      act: (bloc) => bloc.add(LoadPersons()),
      expect: () => [
        PersonsLoading(),
        PersonsLoaded(persons: personList),
      ],
      verify: (_) {
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
    final person = Person(id: 1, name: 'John Doe', personNumber: '1234567890');

    blocTest<PersonBloc, PersonState>(
      'emits [PersonsLoading, PersonLoaded] when LoadPersonsById is successful',
      build: () {
        when(() => mockPersonRepository.getPersonById(person.id))
            .thenAnswer((_) async => person);
        return personBloc;
      },
      act: (bloc) => bloc.add(LoadPersonsById(person: person)),
      expect: () => [
        PersonsLoading(),
        PersonLoaded(person: person),
      ],
      verify: (_) {
        verify(() => mockPersonRepository.getPersonById(person.id)).called(1);
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
    final person = Person(id: 1, name: 'John Doe', personNumber: '1234567890');
    final updatedPersonList = [
      person,
      Person(id: 2, name: 'Jane Doe', personNumber: '0987654321'),
    ];

    blocTest<PersonBloc, PersonState>(
      'emits [PersonsLoaded] when CreatePerson is successful',
      build: () {
        when(() => mockPersonRepository.createPerson(any()))
            .thenAnswer((_) async => Future.value());
        when(() => mockPersonRepository.getAllPersons())
            .thenAnswer((_) async => updatedPersonList);
        return personBloc;
      },
      act: (bloc) => bloc.add(CreatePerson(person: person)),
      expect: () => [
        PersonsLoaded(persons: updatedPersonList),
      ],
      verify: (_) {
        verify(() => mockPersonRepository.createPerson(person)).called(1);
        verify(() => mockPersonRepository.getAllPersons()).called(1);
      },
    );

    blocTest<PersonBloc, PersonState>(
      'emits [PersonsError] when CreatePerson fails',
      build: () {
        when(() => mockPersonRepository.createPerson(any()))
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
    final person = Person(id: 1, name: 'John Doe', personNumber: '1234567890');

    blocTest<PersonBloc, PersonState>(
      'emits [PersonsLoading, PersonLoaded] when UpdatePerson is successful',
      build: () {
        when(() => mockPersonRepository.updatePerson(person.id, person))
            .thenAnswer((_) async => Future.value());
        when(() => mockPersonRepository.getPersonById(person.id))
            .thenAnswer((_) async => person);
        return personBloc;
      },
      act: (bloc) => bloc.add(UpdatePersons(person: person)),
      expect: () => [
        PersonsLoading(),
        PersonLoaded(person: person),
      ],
      verify: (_) {
        verify(() => mockPersonRepository.updatePerson(person.id, person))
            .called(1);
        verify(() => mockPersonRepository.getPersonById(person.id)).called(1);
      },
    );

    blocTest<PersonBloc, PersonState>(
      'emits [PersonsError] when UpdatePerson fails',
      build: () {
        when(() => mockPersonRepository.updatePerson(person.id, person))
            .thenThrow(Exception('Failed to update person'));
        return personBloc;
      },
      act: (bloc) => bloc.add(UpdatePersons(person: person)),
      expect: () => [
        PersonsError(message: 'Exception: Failed to update person'),
      ],
    );
  });

  group('DeletePerson', () {
    final person = Person(id: 1, name: 'John Doe', personNumber: '1234567890');
    final updatedPersonList = [
      Person(id: 2, name: 'Jane Doe', personNumber: '0987654321'),
    ];

    blocTest<PersonBloc, PersonState>(
      'emits [PersonsLoaded] when DeletePerson is successful',
      build: () {
        when(() => mockPersonRepository.deletePerson(person.id))
            .thenAnswer((_) async => Future.value());
        when(() => mockPersonRepository.getAllPersons())
            .thenAnswer((_) async => updatedPersonList);
        return personBloc;
      },
      act: (bloc) => bloc.add(DeletePersons(person: person)),
      expect: () => [
        PersonsLoaded(persons: updatedPersonList),
      ],
      verify: (_) {
        verify(() => mockPersonRepository.deletePerson(person.id)).called(1);
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
}
