part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  // final String id;
  final String personName;
  final String personNum;

  const LoginRequested({required this.personName, required this.personNum});

  @override
  List<Object?> get props => [personName, personNum];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}
