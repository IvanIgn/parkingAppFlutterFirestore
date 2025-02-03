part of 'person_bloc.dart';

/// Base class for all person-related events.
abstract class PersonEvent extends Equatable {
  const PersonEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch all persons.
class FetchPersonsEvent extends PersonEvent {
  const FetchPersonsEvent();
}

/// Event to add a new person.
class AddPersonEvent extends PersonEvent {
  final Person person;

  const AddPersonEvent(this.person);

  @override
  List<Object?> get props => [person];
}

/// Event to update an existing person.
class UpdatePersonEvent extends PersonEvent {
  final Person person;

  const UpdatePersonEvent(this.person);

  @override
  List<Object?> get props => [person];
}

/// Event to delete a person by their ID.
class DeletePersonEvent extends PersonEvent {
  final int personId;

  const DeletePersonEvent(this.personId);

  @override
  List<Object?> get props => [personId];
}
