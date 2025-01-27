import 'dart:io';
import 'package:cli/cli_operations/main.dart';
import 'package:shared/shared.dart';
import 'package:cli/utils/validator.dart';
import 'package:client_repositories/async_http_repos.dart';

class PersonsOperations extends SetMainPage {
  final PersonRepository personRepository = PersonRepository.instance;

  List<String> menuTexts = [
    'Du har valt att hantera Personer. Vad vill du göra?\n',
    '1. Skapa ny person\n',
    '2. Visa alla personer\n',
    '3. Uppdatera person\n',
    '4. Ta bort person\n',
    '5. Gå tillbaka till huvudmenyn\n\n',
    'Välj ett alternativ (1-5): ',
  ];

  void runOperation(int chosenOption) {
    try {
      switch (chosenOption) {
        case 1:
          _addPersonOperation();
          break;
        case 2:
          _showAllPersonsOperation();
          break;
        case 3:
          _updatePersonOperation();
          break;
        case 4:
          _deletePersonOperation();
          break;
        case 5:
          setMainPage(clearCLI: true);
          return;
        default:
          printError('Ogiltigt val, vänligen försök igen.');
      }
    } catch (e) {
      printError('Ett oväntat fel inträffade: ${e.toString()}');
    }
  }

  // Add new person
  Future<void> _addPersonOperation() async {
    try {
      print('\n--- Skapa ny person ---');

      // Name input
      String? name;
      do {
        name = _promptInput('Fyll i namn:');
        if (name == null || name.trim().isEmpty || !Validator.isString(name)) {
          printError('Namnet får inte vara tomt eller ogiltigt. Försök igen.');
        }
      } while (
          name == null || name.trim().isEmpty || !Validator.isString(name));

      // Social Security Number (SSN) input
      String? ssn;
      do {
        ssn = _promptInput('Fyll i personnummer (12 siffror):');
        if (ssn == null || !Validator.isValidSocialSecurityNumber(ssn)) {
          printError('Ogiltigt personnummer, fyll i 12 siffror. Försök igen.');
        }
      } while (ssn == null || !Validator.isValidSocialSecurityNumber(ssn));

// Check if the person already exists
      final personList = await personRepository.getAllPersons();
      final personMap = {
        for (var person in personList) person.personNumber: person
      };

      if (personMap.containsKey(ssn)) {
        printError(
            'Personen med personnummer "$ssn" finns redan. Lägg till en annan person.');
        setMainPage();
        return;
      } else {
        // Create and add the person
        final person = Person(name: name, personNumber: ssn);
        await personRepository.createPerson(person);
        print('Personen "${person.name}" har lagts till.');
        setMainPage();
        return;
      }

      // Create person and add to repository
      // final person = Person(name: name, personNumber: ssn);
      // await personRepository.createPerson(person);
      // print('Personen "${person.name}" har lagts till.');
    } catch (e) {
      printError('Fel vid skapande av person: ${e.toString()}');
    } finally {
      setMainPage();
    }
  }

  // Show all persons
  Future<void> _showAllPersonsOperation() async {
    try {
      print('\n');
      print('\n--- Alla personer ---');
      print('\n');
      final persons = await personRepository.getAllPersons();

      if (persons.isEmpty) {
        print('Inga personer hittades.');
      } else {
        for (var person in persons) {
          print(
              'ID: ${person.id}, Namn: ${person.name}, Personnummer: ${person.personNumber}');
        }
        print('\n');
      }
    } catch (e) {
      printError('Fel vid visning av personer: ${e.toString()}');
    } finally {
      setMainPage();
    }
  }

  // Update person
  Future<void> _updatePersonOperation() async {
    print('\n--- Uppdatera en person ---\n');

    try {
      final personList = await personRepository.getAllPersons();

      if (personList.isEmpty) {
        print('Inga personer hittades.');
        setMainPage();
        return;
      }

      final personNrInput = _promptInput(
          'Fyll i personnummer på personen du vill uppdatera (12 siffror):');

      if (personNrInput == null || personNrInput.isEmpty) {
        print('Inget personnummer angavs. Återgår till huvudmenyn.');
        setMainPage();
        return;
      }

      final foundPersonIndex = personList
          .indexWhere((person) => person.personNumber == personNrInput);

      if (foundPersonIndex == -1) {
        print('Ingen person hittades med det angivna personnumret.');
        setMainPage();
        return;
      }

      final Person personToUpdate =
          await personRepository.getPersonById(personList[foundPersonIndex].id);

      final newName = _promptInput(
          'Nytt namn (tryck enter för att behålla aktuellt namn "${personToUpdate.name}"):');

      final updatedName =
          (newName == null || newName.isEmpty) ? personToUpdate.name : newName;

      final updateResult = await personRepository.updatePerson(
        personToUpdate.id,
        Person(
          id: personToUpdate.id,
          name: updatedName,
          personNumber: personNrInput,
        ),
      );

      print('Personen har uppdaterats framgångsrikt.');
    } catch (e) {
      print('Ett fel inträffade: ${e.toString()}');
    } finally {
      setMainPage();
    }
  }

  // Delete person

  Future<void> _deletePersonOperation() async {
    print('\n--- Ta bort en person ---\n');

    try {
      // Step 1: Retrieve all persons from the repository
      final personList = await personRepository.getAllPersons();

      if (personList.isEmpty) {
        print('Inga personer hittades.');
        setMainPage();
        return;
      }

      // Step 2: Prompt for a valid personal number
      String? personNrInput;
      do {
        personNrInput = _promptInput(
            'Fyll i personnummer (12 siffror) på personen du vill ta bort:');
        if (personNrInput == null || personNrInput.isEmpty) {
          printError('Personnummer krävs. Försök igen.');
        }
      } while (personNrInput == null || personNrInput.isEmpty);

      // Step 3: Find the person in the list
      final personIndex = personList
          .indexWhere((person) => person.personNumber == personNrInput);

      if (personIndex == -1) {
        printError('Ingen person hittades med det angivna personnumret.');
        setMainPage();
        return;
      }

      final personToDelete = personList[personIndex];

      // Step 4: Delete the person from the repository
      await personRepository.deletePerson(personToDelete.id);
      final personName = personToDelete.name;

      // Step 5: Notify the user
      print('Person $personName med personnummer $personNrInput har raderats.');
    } catch (e) {
      // Handle any errors during the deletion process
      printError('Ett oväntat fel inträffade: ${e.toString()}');
    } finally {
      setMainPage();
    }
  }

  // Helper for user input prompt
  String? _promptInput(String promptText) {
    stdout.write(promptText);
    return stdin.readLineSync()?.trim();
  }

  // Helper for error messages
  void printError(String message) {
    print('Fel: $message');
  }
}
