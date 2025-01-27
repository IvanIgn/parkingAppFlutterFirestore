part of 'person_bloc.dart';

sealed class PersonEvent {}

class LoadPersons extends PersonEvent {}

class LoadPersonsById extends PersonEvent {
  final Person person;

  LoadPersonsById({required this.person});
}

class CreatePerson extends PersonEvent {
  final Person person;

  CreatePerson({required this.person});
}

class UpdatePersons extends PersonEvent {
  final Person person;

  UpdatePersons({required this.person});
}

class DeletePersons extends PersonEvent {
  final Person person;

  DeletePersons({required this.person});
}
