import 'package:bloc/bloc.dart';
import 'package:shared/shared.dart';
import 'package:client_repositories/async_http_repos.dart';

part 'person_event.dart';
part 'person_state.dart';

class PersonBloc extends Bloc<PersonEvent, PersonState> {
  List<Person> _personList = [];
  PersonBloc() : super(PersonsInitial()) {
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
      await onUpdatePerson(emit, event.person);
    });
  }

  Future<void> onLoadPersons(Emitter<PersonState> emit) async {
    emit(PersonsLoading());
    try {
      _personList = await PersonRepository.instance.getAllPersons();
      emit(PersonsLoaded(persons: _personList));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }

  Future<void> onLoadPersonsById(
      Emitter<PersonState> emit, Person person) async {
    emit(PersonsLoading());
    try {
      final personById =
          await PersonRepository.instance.getPersonById(person.id);
      emit(PersonLoaded(person: personById));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }

  onCreatePerson(Emitter<PersonState> emit, Person person) async {
    try {
      await PersonRepository.instance.createPerson(
          Person(name: person.name, personNumber: person.personNumber));

      _personList = await PersonRepository.instance.getAllPersons();
      emit(PersonsLoaded(persons: _personList));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }

  onUpdatePerson(Emitter<PersonState> emit, Person person) async {
    try {
      await PersonRepository.instance.updatePerson(person.id, person);

      add(LoadPersonsById(person: person));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }

  onDeletePerson(Emitter<PersonState> emit, Person person) async {
    try {
      await PersonRepository.instance.deletePerson(person.id);

      _personList = await PersonRepository.instance.getAllPersons();
      emit(PersonsLoaded(persons: _personList));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }
}
