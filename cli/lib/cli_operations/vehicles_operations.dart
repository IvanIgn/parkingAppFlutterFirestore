import 'dart:io';
import 'package:cli/cli_operations/main.dart';
import 'package:shared/shared.dart';
import 'package:cli/utils/validator.dart';
import 'package:client_repositories/async_http_repos.dart';

class VehiclesOperations extends SetMainPage {
  final VehicleRepository _vehicleRepository = VehicleRepository.instance;
  final PersonRepository _personRepository = PersonRepository.instance;

  List<String> menuTexts = [
    'Du har valt att hantera Fordon. Vad vill du göra?\n',
    '1. Skapa nytt fordon\n',
    '2. Visa alla fordon\n',
    '3. Uppdatera fordon\n',
    '4. Ta bort fordon\n',
    '5. Gå tillbaka till huvudmenyn\n\n',
    'Välj ett alternativ (1-5): ',
  ];

  void runOperation(int chosenOption) {
    try {
      switch (chosenOption) {
        case 1:
          _addVehicleOperation();
          break;
        case 2:
          _showAllVehiclesOperation();
          break;
        case 3:
          _updateVehicleOperation();
          break;
        case 4:
          _deleteVehicleOperation();
          break;
        case 5:
          setMainPage(clearCLI: true);
          return;
        default:
          _printError('Ogiltigt val, vänligen försök igen.');
      }
    } catch (e) {
      _printError('Ett oväntat fel inträffade: ${e.toString()}');
    }
  }

  Future<void> _addVehicleOperation() async {
    print('\n--- Skapa ett nytt fordon ---');

    try {
      // Steg 1: Hämta personnummer
      String? personNumberInput;
      do {
        personNumberInput =
            _promptInput('Ange ägarens personnummer (12 siffror):');
        if (personNumberInput == null ||
            !Validator.isValidSocialSecurityNumber(personNumberInput)) {
          _printError(
              'Ogiltigt personnummer. Det måste vara 12 siffror. Försök igen.');
        }
      } while (personNumberInput == null ||
          !Validator.isValidSocialSecurityNumber(personNumberInput));

      // Steg 2: Hitta personen baserat på personnummer

      final personList = await _personRepository.getAllPersons();

      final foundPersonIndex =
          personList.indexWhere((i) => i.personNumber == personNumberInput);

      late final Person personToAdd;
      if (foundPersonIndex != -1) {
        personToAdd = personList
            .firstWhere((person) => person.personNumber == personNumberInput);
        // Steg 1: Skapa nytt fordon
      } else {
        print('Personen finns inte. Skapa personen först.');
        setMainPage();
        return;
      }

      // Steg 2: Hämta registreringsnummer
      String? regNrInput;
      do {
        regNrInput = _promptInput('Ange registreringsnummer (ex. ABC123):');
        if (regNrInput == null || regNrInput.trim().isEmpty) {
          _printError('Registreringsnummer är obligatoriskt. Försök igen.');
        }
      } while (regNrInput == null || regNrInput.trim().isEmpty);

      // Steg 3: Hämta fordonstyp
      // Step 3: Get Vehicle Type
      String? typeInput;
      do {
        typeInput =
            _promptInput('Ange fordonstyp (1: Bil, 2: Motorcykel, 3: Annat):');
        if (typeInput == null ||
            !Validator.validateNumber(typeInput) ||
            int.parse(typeInput) < 1 ||
            int.parse(typeInput) > 3) {
          _printError(
              'Ogiltig inmatning. Ange en siffra (1: Bil, 2: Motorcykel, 3: Annat). Försök igen.');
        }
      } while (typeInput == null ||
          !Validator.validateNumber(typeInput) ||
          int.parse(typeInput) < 1 ||
          int.parse(typeInput) > 3);

      // Determine vehicle type
      final vehicleType = {
        1: 'Car',
        2: 'Motorcycle',
        3: 'Other',
      }[int.parse(typeInput)]!;

      // Steg 4: Skapa och spara fordonet
      final newVehicle = Vehicle(
        regNumber: regNrInput.toUpperCase(),
        vehicleType: vehicleType,
        owner: Person(
          id: personToAdd.id,
          name: personToAdd.name,
          personNumber: personToAdd.personNumber,
        ),
      );

      await _vehicleRepository.createVehicle(newVehicle);
      print(
          'Fordonet "${newVehicle.vehicleType}" med registreringsnummer "${newVehicle.regNumber}" har lagts till.');
      setMainPage();
    } catch (e) {
      _printError(
          'Ett oväntat fel inträffade vid skapandet av fordon: ${e.toString()}');
    }
  }

  // Show all vehicles
  Future<void> _showAllVehiclesOperation() async {
    try {
      print('\n');
      print('\n--- Alla fordon ---');
      print('\n');
      final vehicles = await _vehicleRepository.getAllVehicles();

      if (vehicles.isEmpty) {
        print('Inga fordon hittades.');
      } else {
        for (var vehicle in vehicles) {
          final ownerInfo = vehicle.owner != null
              ? 'Ägare: ${vehicle.owner!.name}, Personnummer: ${vehicle.owner!.personNumber}'
              : 'Ingen ägare';
          print(
              'ID: ${vehicle.id}, Registreringsnummer: ${vehicle.regNumber}, Typ: ${vehicle.vehicleType}, $ownerInfo');
        }
      }
    } catch (e) {
      _printError('Fel vid visning av fordon: ${e.toString()}');
    } finally {
      setMainPage();
    }
  }

  Future<void> _updateVehicleOperation() async {
    print('\n--- Uppdatera ett fordon ---');

    try {
      // Step 1: Fetch all vehicles
      final vehicleList = await _vehicleRepository.getAllVehicles();
      if (vehicleList.isEmpty) {
        print('Inga fordon hittades för att uppdatera.');
        setMainPage();
        return;
      }

      // Step 2: Prompt for the registration number
      String? regNumber;
      do {
        regNumber = _promptInput(
            'Ange registreringsnummer för det fordon du vill uppdatera (ex. ABC123):');
        if (regNumber == null || regNumber.trim().isEmpty) {
          _printError('Registreringsnummer är obligatoriskt. Försök igen.');
        }
      } while (regNumber == null || regNumber.trim().isEmpty);

      // Step 3: Find the vehicle
      final foundVehicleIndex = vehicleList.indexWhere((vehicle) =>
          vehicle.regNumber.toUpperCase() == regNumber!.toUpperCase());

      if (foundVehicleIndex == -1) {
        _printError(
            'Inget fordon hittades med registreringsnummer "$regNumber".');
        setMainPage();
        return;
      }

      final vehicleToUpdate = await _vehicleRepository
          .getVehicleById(vehicleList[foundVehicleIndex].id);

      // Step 4: Prompt for new registration number
      final newRegNumber = _promptInput(
          'Ange nytt registreringsnummer för fordonet (lämna tomt för att behålla aktuellt):');

      final updatedRegNumber =
          (newRegNumber == null || newRegNumber.trim().isEmpty)
              ? vehicleToUpdate.regNumber
              : newRegNumber.trim().toUpperCase();

      // Step 5: Update the vehicle
      await _vehicleRepository.updateVehicle(
        vehicleToUpdate.id,
        Vehicle(
          id: vehicleToUpdate.id,
          regNumber: updatedRegNumber,
          vehicleType: vehicleToUpdate.vehicleType,
          owner: vehicleToUpdate.owner,
        ),
      );

      // If the update completes successfully, notify the user
      print(
          'Fordon med registreringsnummer "$updatedRegNumber" har uppdaterats.');
    } catch (e) {
      // Catch any error during the update process and print it
      _printError(
          'Ett fel inträffade vid uppdatering av fordon: ${e.toString()}');
    } finally {
      setMainPage();
    }
  }

  // Delete a vehicle
  Future<void> _deleteVehicleOperation() async {
    print('\n--- Ta bort ett fordon ---\n');

    try {
      // Step 1: Retrieve all vehicles from the repository
      final vehicleList = await _vehicleRepository.getAllVehicles();

      if (vehicleList.isEmpty) {
        print('Inga fordon hittades.');
        setMainPage();
        return;
      }

      // Step 2: Prompt for a valid registration number
      String? regNumber;
      do {
        regNumber = _promptInput(
            'Ange registreringsnummer (ex. ABC123) för det fordon du vill ta bort:');
        if (regNumber == null || regNumber.isEmpty) {
          _printError('Registreringsnummer krävs. Försök igen');
          if (regNumber == null || regNumber.isEmpty) {
            setMainPage();
            return;
          }
        }
      } while (regNumber.isEmpty);

      // Step 3: Find the vehicle in the list
      final vehicleIndex =
          vehicleList.indexWhere((vehicle) => vehicle.regNumber == regNumber);

      if (vehicleIndex == -1) {
        _printError(
            'Inget fordon hittades med registreringsnummer $regNumber.');
        setMainPage();
        return;
      }

      final vehicleToDelete = vehicleList[vehicleIndex];

      // Step 4: Delete the vehicle from the repository
      await _vehicleRepository.deleteVehicle(vehicleToDelete.id);

      // Step 5: Notify the user
      print('Fordon med registreringsnummer $regNumber har raderats.');
    } catch (e) {
      // Handle any errors during the deletion process
      _printError('Ett oväntat fel inträffade: ${e.toString()}');
    } finally {
      setMainPage();
    }
  }

  // Helper for user input
  String? _promptInput(String promptText) {
    stdout.write(promptText);
    return stdin.readLineSync()?.trim();
  }

  // Helper for error messages
  void _printError(String message) {
    print('Fel: $message');
  }
}
