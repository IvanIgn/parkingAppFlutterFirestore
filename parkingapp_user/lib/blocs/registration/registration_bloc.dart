import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:shared/shared.dart'; // PersonRepository

part 'registration_event.dart';
part 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final PersonRepository _personRepository;

  RegistrationBloc({required PersonRepository personRepository})
      : _personRepository = personRepository,
        super(RegistrationInitial()) {
    on<RegistrationSubmitted>(_mapRegistrationSubmittedToState);
  }

  Future<void> _mapRegistrationSubmittedToState(
      RegistrationSubmitted event, Emitter<RegistrationState> emit) async {
    emit(RegistrationLoading());

    try {
      // Basic form validation
      if (event.name.isEmpty) {
        emit(RegistrationError(errorMessage: "Fyll i namn"));
        return;
      } else if (event.personNum.isEmpty) {
        emit(RegistrationError(errorMessage: "Fyll i personnummer"));
        return;
      } else if (!isNumeric(event.personNum)) {
        emit(RegistrationError(
            errorMessage: "Personnummer måste vara numeriskt"));
        return;
      } else if (event.personNum.length != 12) {
        emit(RegistrationError(
            errorMessage: "Personnummer måste vara 12 siffror"));
        return;
      }

      // Check if the person already exists
      final personList = await _personRepository.getAllPersons();
      final personMap = {
        for (var person in personList) person.personNumber: person
      };

      if (personMap.containsKey(event.personNum)) {
        emit(RegistrationError(
            errorMessage:
                'Personen med detta personnummer ${event.personNum} är redan registrerad'));
        return;
      }

      // Create new person
      final newPerson = Person(
        // id: '',
        name: event.name,
        personNumber: event.personNum,
      );

      await _personRepository.createPerson(newPerson);

      emit(RegistrationSuccess(
          successMessage:
              "Personen ${event.name} med personnummer ${event.personNum} har registrerats!"));
    } catch (e) {
      emit(RegistrationError(errorMessage: "Error during registration: $e"));
    }
  }

  // Helper function to check if a string contains only digits
  bool isNumeric(String str) {
    final numericRegex = RegExp(r'^[0-9]+$');
    return numericRegex.hasMatch(str);
  }
}
