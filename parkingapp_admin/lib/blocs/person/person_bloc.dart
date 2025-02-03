import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';
import 'package:equatable/equatable.dart';

part 'person_event.dart';
part 'person_state.dart';

class PersonBloc extends Bloc<PersonEvent, PersonState> {
  final PersonRepository repository;

  PersonBloc({required this.repository}) : super(PersonInitialState()) {
    on<FetchPersonsEvent>(_onFetchPersons);
    on<AddPersonEvent>(_onAddPerson);
    on<UpdatePersonEvent>(_onUpdatePerson);
    on<DeletePersonEvent>(_onDeletePerson);
  }

  Future<void> _onFetchPersons(
      FetchPersonsEvent event, Emitter<PersonState> emit) async {
    emit(PersonLoadingState());
    try {
      final persons = await repository.getAllPersons();
      emit(PersonLoadedState(persons)); // Ensure the updated list is emitted
    } catch (e) {
      emit(PersonErrorState("Error fetching persons: $e"));
    }
  }

  Future<void> _onAddPerson(
      AddPersonEvent event, Emitter<PersonState> emit) async {
    try {
      final newPerson = await repository.createPerson(event.person);

      if (state is PersonLoadedState) {
        final currentState = state as PersonLoadedState;
        final updatedList = List<Person>.from(currentState.persons)
          ..add(newPerson);
        emit(PersonLoadedState(updatedList));
      } else {
        emit(PersonLoadedState(
            [newPerson])); // Handle case where state is not loaded
      }
    } catch (e) {
      emit(PersonErrorState("Error adding person: $e"));
    }
  }

  // Future<void> _onUpdatePerson(
  //     UpdatePersonEvent event, Emitter<PersonState> emit) async {
  //   try {
  //     await repository.updatePerson(event.person.id, event.person);

  //     if (state is PersonLoadedState) {
  //       final currentState = state as PersonLoadedState;
  //       final updatedList = currentState.persons.map((p) {
  //         return p.id == event.person.id ? event.person : p;
  //       }).toList();
  //       emit(PersonLoadedState(updatedList));
  //     }
  //   } catch (e) {
  //     emit(PersonErrorState("Error updating person: $e"));
  //   }
  // }

  Future<void> _onUpdatePerson(
      UpdatePersonEvent event, Emitter<PersonState> emit) async {
    try {
      emit(PersonLoadingState()); // Emit loading state first

      // Update person in repository
      await repository.updatePerson(event.person.id, event.person);

      // Emit the updated state with the updated person
      emit(PersonUpdatedState(event.person));

      if (state is PersonLoadedState) {
        final currentState = state as PersonLoadedState;
        final updatedList = currentState.persons.map((p) {
          return p.id == event.person.id ? event.person : p;
        }).toList();
        emit(PersonLoadedState(
            updatedList)); // Emit loaded state with updated list
      }
    } catch (e) {
      emit(PersonErrorState("Error updating person: $e"));
    }
  }

  // Future<void> _onDeletePerson(
  //     DeletePersonEvent event, Emitter<PersonState> emit) async {
  //   try {
  //     await repository.deletePerson(event.personId);

  //     if (state is PersonLoadedState) {
  //       final currentState = state as PersonLoadedState;
  //       final updatedList =
  //           currentState.persons.where((p) => p.id != event.personId).toList();
  //       emit(PersonLoadedState(updatedList));
  //     }
  //   } catch (e) {
  //     emit(PersonErrorState("Error deleting person: $e"));
  //   }
  // }

  Future<void> _onDeletePerson(
      DeletePersonEvent event, Emitter<PersonState> emit) async {
    try {
      emit(PersonLoadingState()); // Emit loading state first

      await repository.deletePerson(event.personId);

      // Ensure the state update is valid
      if (state is PersonLoadedState &&
          (state as PersonLoadedState).persons.isNotEmpty) {
        final currentState = state as PersonLoadedState;
        final updatedList =
            currentState.persons.where((p) => p.id != event.personId).toList();
        emit(PersonLoadedState(updatedList)); // Emit updated list
      } else {
        emit(PersonLoadedState(const [])); // Emit empty list if no previous state
      }
    } catch (e) {
      emit(PersonErrorState("Error deleting person: $e"));
    }
  }
}
