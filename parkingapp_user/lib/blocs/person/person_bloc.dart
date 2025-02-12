import 'package:bloc/bloc.dart';
import 'package:shared/shared.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:equatable/equatable.dart';

part 'person_event.dart';
part 'person_state.dart';

class PersonBloc extends Bloc<PersonEvent, PersonState> {
  List<Person> _personList = [];
  final PersonRepository repository;

  PersonBloc({required this.repository}) : super(PersonsInitial()) {
    on<LoadPersons>((event, emit) async {
      await onLoadPersons(emit);
    });

    on<LoadPersonsById>((event, emit) async {
      await onLoadPersonsById(emit, event.person);
    });

    on<DeletePersons>((event, emit) async {
      await onDeletePerson(emit, event.person);
    });

    on<CreatePerson>((event, emit) async {
      await onCreatePerson(emit, event.person);
    });

    on<UpdatePersons>((event, emit) async {
      await onUpdatePerson(event, emit);
    });
  }

  Future<void> onLoadPersons(Emitter<PersonState> emit) async {
    emit(PersonsLoading());
    try {
      _personList = await repository.getAllPersons();
      emit(PersonsLoaded(persons: _personList));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }

  onLoadPersonsById(Emitter<PersonState> emit, Person person) async {
    emit(PersonsLoading()); // Emit loading state first
    try {
      final personById = await repository.getPersonById(person.id);
      emit(PersonLoaded(person: personById));
      print('Emitted PersonLoaded: $personById'); // Print state transition
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }

  onCreatePerson(Emitter<PersonState> emit, Person person) async {
    try {
      await repository.createPerson(person); // Await person creation
      _personList =
          await repository.getAllPersons(); // Fetch updated list of persons
      emit(PersonsLoaded(persons: _personList)); // Emit the updated list
    } catch (e) {
      emit(PersonsError(message: e.toString())); // Handle error case
    }
  }

  onUpdatePerson(
    UpdatePersons event,
    Emitter<PersonState> emit,
  ) async {
    emit(PersonsLoading()); // Always emit loading state first
    try {
      await repository.updatePerson(event.person.id, event.person);
      final updatedPerson = await repository.getPersonById(event.person.id);
      emit(PersonLoaded(person: updatedPerson));
    } catch (e) {
      emit(PersonsError(message: e.toString())); // Emit error if update fails
    }
  }

  onDeletePerson(Emitter<PersonState> emit, Person person) async {
    try {
      print("Deleting person with id: ${person.id}");
      await repository.deletePerson(person.id);

      final updatedPersons = await repository.getAllPersons();
      print("Updated persons: $updatedPersons");

      emit(PersonsLoaded(persons: updatedPersons));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }
}
