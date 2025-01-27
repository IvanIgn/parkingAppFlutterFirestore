part of 'person_bloc.dart';

sealed class PersonState {}

class PersonsInitial extends PersonState {
  List<Object?> get persons => [];
}

class PersonsLoading extends PersonState {
  List<Object?> get persons => [];
}

class PersonsLoaded extends PersonState {
  final List<Person> persons;

  PersonsLoaded({required this.persons});
}

class PersonLoaded extends PersonState {
  Person person;

  PersonLoaded({required this.person});
}

class PersonsError extends PersonState {
  final String message;

  PersonsError({required this.message});

  List<Object?> get props => [message];
}
