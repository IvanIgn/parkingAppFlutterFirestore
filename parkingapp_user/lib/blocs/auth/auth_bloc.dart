import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:client_repositories/async_http_repos.dart'; // Assume this contains PersonRepository and Person model

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final PersonRepository personRepository;

  AuthBloc({required this.personRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final loggedInPerson = prefs.getString('loggedInPerson');
      if (loggedInPerson != null) {
        final personData = json.decode(loggedInPerson);
        emit(AuthAuthenticated(
          name: personData['name'],
          personNumber: personData['personNumber'],
        ));
      } else {
        emit(AuthLoggedOut());
      }
    } catch (e) {
      emit(AuthError(errorMessage: 'Error checking authentication status: $e'));
      emit(AuthLoggedOut()); // Reset to a retryable state
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final persons = await personRepository.getAllPersons();
      final personMap = {for (var p in persons) p.personNumber: p};

      if (!personMap.containsKey(event.personNum) ||
          personMap[event.personNum]?.name != event.personName) {
        emit(AuthError(
            errorMessage:
                'Personen "${event.personName}" med personnummer "${event.personNum}" är inte registrerad.'));
        emit(AuthLoggedOut()); // Allow retry without delay
        return;
      }

      final loggedInPerson = personMap[event.personNum]!;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'loggedInPerson', json.encode(loggedInPerson.toJson()));

      emit(AuthAuthenticated(
        name: loggedInPerson.name,
        personNumber: loggedInPerson.personNumber,
      ));
    } catch (e) {
      emit(AuthError(errorMessage: 'An error occurred: $e'));
      emit(AuthLoggedOut()); // Allow retry without delay
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthError(errorMessage: 'An error occurred during logout: $e'));
    }
  }
}
