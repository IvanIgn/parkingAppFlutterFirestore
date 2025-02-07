import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:shared/shared.dart';
import 'package:parkingapp_user/blocs/registration/registration_bloc.dart';

// Mock classes
class MockPersonRepository extends Mock implements PersonRepository {}

class MockPerson extends Mock implements Person {}

void main() {
  late MockPersonRepository mockPersonRepository;
  late RegistrationBloc registrationBloc;

  setUp(() {
    mockPersonRepository = MockPersonRepository();
    registrationBloc = RegistrationBloc(personRepository: mockPersonRepository);
    when(() => mockPersonRepository.getAllPersons())
        .thenAnswer((_) async => []); // Simulate no existing persons

    when(() => mockPersonRepository.createPerson(any())).thenAnswer(
      (_) async =>
          Person(id: '1', name: 'John Doe', personNumber: '123456789012'),
    );
  });

  tearDown(() {
    registrationBloc.close();
  });

  setUpAll(() {
    registerFallbackValue(
        Person(id: '0', name: 'John Doe', personNumber: '123456789012'));
  });

  group('RegistrationBloc', () {
    test('initial state is RegistrationInitial', () {
      final registrationBloc =
          RegistrationBloc(personRepository: mockPersonRepository);
      expect(registrationBloc.state, RegistrationInitial());
    });

    // Test successful registration
    blocTest<RegistrationBloc, RegistrationState>(
      'emits [RegistrationLoading, RegistrationSuccess] when registration is successful',
      build: () => registrationBloc,
      act: (bloc) => bloc.add(
        RegistrationSubmitted(
          name: 'John Doe',
          personNum: '123456789012',
          confirmPersonNum: '123456789012',
        ),
      ),
      expect: () => [
        RegistrationLoading(),
        RegistrationSuccess(
            successMessage:
                "Personen John Doe med personnummer 123456789012 har registrerats!"),
      ],
    );

    // Test for empty name validation
    blocTest<RegistrationBloc, RegistrationState>(
      'emits [RegistrationLoading, RegistrationError] when name is empty',
      build: () => RegistrationBloc(personRepository: mockPersonRepository),
      act: (bloc) => bloc.add(
        RegistrationSubmitted(
            name: '',
            personNum: '123456789012',
            confirmPersonNum: '123456789012'),
      ),
      expect: () => [
        RegistrationLoading(),
        RegistrationError(errorMessage: "Fyll i namn"),
      ],
    );

    // Test for empty person number validation
    blocTest<RegistrationBloc, RegistrationState>(
      'emits [RegistrationError] when person number is empty',
      build: () => RegistrationBloc(personRepository: mockPersonRepository),
      act: (bloc) => bloc.add(
        RegistrationSubmitted(
            name: 'John Doe', personNum: '', confirmPersonNum: ''),
      ),
      expect: () => [
        RegistrationLoading(),
        RegistrationError(errorMessage: "Fyll i personnummer"),
      ],
    );

    // Test for non-numeric person number
    blocTest<RegistrationBloc, RegistrationState>(
      'emits [RegistrationError] when person number is non-numeric',
      build: () => RegistrationBloc(personRepository: mockPersonRepository),
      act: (bloc) => bloc.add(
        RegistrationSubmitted(
            name: 'John Doe',
            personNum: '12345ABC7890',
            confirmPersonNum: '12345ABC7890'),
      ),
      expect: () => [
        RegistrationLoading(),
        RegistrationError(errorMessage: "Personnummer måste vara numeriskt"),
      ],
    );

    // Test for invalid person number length
    blocTest<RegistrationBloc, RegistrationState>(
      'emits [RegistrationError] when person number length is not 12',
      build: () => RegistrationBloc(personRepository: mockPersonRepository),
      act: (bloc) => bloc.add(
        RegistrationSubmitted(
            name: 'John Doe',
            personNum: '1234567890',
            confirmPersonNum: '1234567890'),
      ),
      expect: () => [
        RegistrationLoading(),
        RegistrationError(errorMessage: "Personnummer måste vara 12 siffror"),
      ],
    );

    // Test for already existing person
    blocTest<RegistrationBloc, RegistrationState>(
      'emits [RegistrationError] when the person is already registered',
      setUp: () {
        // Mock that the person is already registered
        when(() => mockPersonRepository.getAllPersons()).thenAnswer((_) async =>
            [Person(id: '1', name: 'John Doe', personNumber: '123456789012')]);
      },
      build: () => RegistrationBloc(personRepository: mockPersonRepository),
      act: (bloc) => bloc.add(
        RegistrationSubmitted(
            name: 'John Doe',
            personNum: '123456789012',
            confirmPersonNum: '123456789012'),
      ),
      expect: () => [
        RegistrationLoading(),
        RegistrationError(
            errorMessage:
                'Personen med detta personnummer 123456789012 är redan registrerad'),
      ],
    );

    // Test for unexpected errors
    blocTest<RegistrationBloc, RegistrationState>(
      'emits [RegistrationError] when an unexpected error occurs',
      setUp: () {
        // Simulate an error occurring during registration
        when(() => mockPersonRepository.getAllPersons())
            .thenThrow(Exception('Some unexpected error'));
      },
      build: () => RegistrationBloc(personRepository: mockPersonRepository),
      act: (bloc) => bloc.add(
        RegistrationSubmitted(
            name: 'John Doe',
            personNum: '123456789012',
            confirmPersonNum: '123456789012'),
      ),
      expect: () => [
        RegistrationLoading(),
        RegistrationError(
            errorMessage:
                "Error during registration: Exception: Some unexpected error"),
      ],
    );
  });
}
