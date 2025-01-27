part of 'person_bloc.dart';

/// Base class for all person-related events.
abstract class PersonEvent {
  const PersonEvent();
}

/// Event to fetch all persons.
class FetchPersonsEvent extends PersonEvent {
  @override
  List<Object?> get props => [];
}

/// Event to add a new person.
class AddPersonEvent extends PersonEvent {
  final Person person;

  const AddPersonEvent(this.person);
}

/// Event to update an existing person.
class UpdatePersonEvent extends PersonEvent {
  final Person person;

  const UpdatePersonEvent(this.person);
}

/// Event to delete a person by their ID.
class DeletePersonEvent extends PersonEvent {
  final int personId;

  const DeletePersonEvent(this.personId);
}
