import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:parkingapp_user/blocs/auth/auth_bloc.dart';
import 'package:shared/shared.dart';

class MockPersonRepository extends Mock implements PersonRepository {}

void main() {
  late AuthBloc authBloc;
  late MockPersonRepository mockPersonRepository;

  setUp(() {
    mockPersonRepository = MockPersonRepository();
    authBloc = AuthBloc(personRepository: mockPersonRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('CheckAuthStatus', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when user is logged in',
      setUp: () {
        SharedPreferences.setMockInitialValues({
          'loggedInPerson': json.encode({
            'name': 'John Doe',
            'personNumber': '199001011234',
          }),
        });
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(CheckAuthStatus()),
      expect: () => [
        AuthLoading(),
        const AuthAuthenticated(name: 'John Doe', personNumber: '199001011234'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthLoggedOut] when no user is logged in',
      setUp: () {
        SharedPreferences.setMockInitialValues({});
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(CheckAuthStatus()),
      expect: () => [AuthLoading(), AuthLoggedOut()],
    );
  });

  group('LoginRequested', () {
    final mockPersons = [
      Person(id: '1', name: 'John Doe', personNumber: '199001011234'),
      Person(id: '2', name: 'Jane Loen', personNumber: '199002022345'),
    ];

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(() => mockPersonRepository.getAllPersons())
            .thenAnswer((_) async => mockPersons);
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
          personName: 'John Doe', personNum: '199001011234')),
      expect: () => [
        AuthLoading(),
        const AuthAuthenticated(name: 'John Doe', personNumber: '199001011234'),
      ],
      verify: (_) {
        verify(() => mockPersonRepository.getAllPersons()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError, AuthLoggedOut] when login fails due to incorrect details',
      build: () {
        when(() => mockPersonRepository.getAllPersons())
            .thenAnswer((_) async => mockPersons);
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
          personName: 'Invalid User', personNum: '123456789012')),
      expect: () => [
        AuthLoading(),
        const AuthError(
            errorMessage:
                'Personen "Invalid User" med personnummer "123456789012" är inte registrerad.'),
        AuthLoggedOut(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError, AuthLoggedOut] when login fails due to exception',
      build: () {
        when(() => mockPersonRepository.getAllPersons())
            .thenThrow(Exception('Database error'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
          personName: 'John Doe', personNum: '199001011234')),
      expect: () => [
        AuthLoading(),
        const AuthError(
            errorMessage: 'An error occurred: Exception: Database error'),
        AuthLoggedOut(),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthLoggedOut] when logout succeeds',
      build: () {
        SharedPreferences.setMockInitialValues({});
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [AuthLoading(), AuthLoggedOut()],
    );
  });
}
