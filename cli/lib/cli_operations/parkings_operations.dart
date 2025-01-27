import 'dart:io';
import 'package:cli/cli_operations/main.dart';
import 'package:shared/shared.dart';
import 'package:cli/utils/validator.dart';
import 'package:client_repositories/async_http_repos.dart';

/// Hanterar operationer relaterade till parkeringar
class ParkingsOperations extends SetMainPage {
  final ParkingRepository parkingRepository = ParkingRepository.instance;
  final ParkingSpaceRepository parkingSpaceRepository =
      ParkingSpaceRepository.instance;
  final VehicleRepository vehicleRepository = VehicleRepository.instance;

  final List<String> menuTexts = [
    'Du har valt att hantera Parkeringar. Vad vill du göra?\n',
    '1. Skapa ny parkering\n',
    '2. Visa alla parkeringar\n',
    '3. Uppdatera parkering\n',
    '4. Ta bort parkering\n',
    '5. Gå tillbaka till huvudmenyn\n\n',
    'Välj ett alternativ (1-5): ',
  ];

  /// Kör vald operation baserat på användarens input
  void runOperation(int chosenOption) {
    try {
      switch (chosenOption) {
        case 1:
          _addParkingOperation();
          break;
        case 2:
          _showAllParkingsOperation();
          break;
        case 3:
          _updateParkingOperation();
          break;
        case 4:
          _deleteParkingOperation();
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

  /// Skapa ny parkering
  Future<void> _addParkingOperation() async {
    try {
      print('\n--- Skapa ny parkering ---');

      // Registreringsnummer input
      String? regNumInput;
      do {
        regNumInput = _promptInput('Ange registreringsnummer:');
        if (regNumInput == null || regNumInput.trim().isEmpty) {
          _printError('Registreringsnummer får inte vara tom. Försök igen.');
          setMainPage();
          return;
        }
      } while (regNumInput.trim().isEmpty);

      final vehicleList = await vehicleRepository.getAllVehicles();

      final foundRegIndex =
          vehicleList.indexWhere((i) => i.regNumber == regNumInput);

      late final Vehicle vehicleToAdd;
      if (foundRegIndex != -1) {
        vehicleToAdd = vehicleList
            .firstWhere((vehicle) => vehicle.regNumber == regNumInput);

        // Steg 1: Skapa nytt fordon
      } else {
        print('Fordonet finns inte. Skapa fordon först.');
        setMainPage();
        return;
      }
// Perkeringsplats ID input
      String? parkSpaceIdInput;
      do {
        parkSpaceIdInput = _promptInput('Ange parkeringsplats ID:');
        if (parkSpaceIdInput == null || parkSpaceIdInput.trim().isEmpty) {
          _printError('Registreringsnummer får inte vara tom. Försök igen.');
          setMainPage();
          return;
        }
      } while (regNumInput.trim().isEmpty);

      final parkSpaceList = await parkingSpaceRepository.getAllParkingSpaces();

      late final ParkingSpace spaceToAdd;
      if (foundRegIndex != -1) {
        spaceToAdd = parkSpaceList
            .firstWhere((i) => i.id.toString() == parkSpaceIdInput);

        // Steg 1: Skapa nytt fordon
      } else {
        print('Parkeringsplatset finns inte. Skapa parkeringsplats först.');
        setMainPage();
        return;
      }

      // Sluttid input
      String? endTimeInput;
      do {
        endTimeInput = _promptInput('Ange sluttid för parkeringen (hh:mm):');
        if (endTimeInput == null || endTimeInput.trim().isEmpty) {
          _printError('Sluttid är obligatoriskt. Försök igen.');
          setMainPage();
          return;
        }
      } while (endTimeInput.isEmpty);

      final formattedEndTimeInput =
          DateTime.tryParse(_getCorrectDate(endTimeInput));

      if (formattedEndTimeInput == null) {
        _printError('Du angav ett felaktigt tidsformat');
        setMainPage();
        return;
      }

      final newParking = Parking(
        vehicle: vehicleToAdd,
        parkingSpace: spaceToAdd,
        startTime: DateTime.now(),
        endTime: formattedEndTimeInput,
      );

      await parkingRepository.createParking(newParking);
      print('Parkering "${newParking.id}" har lagts till.');
    } catch (e) {
      _printError('Fel vid skapande av parkeringsplats: ${e.toString()}');
    } finally {
      setMainPage();
    }
  }

  /// Visar alla parkeringar funkar
  Future<void> _showAllParkingsOperation() async {
    try {
      print('\n--- Alla parkeringar ---');
      final parkings = await parkingRepository.getAllParkings();

      if (parkings.isEmpty) {
        print('Inga parkeringar hittades.');
      } else {
        for (var parking in parkings) {
          print(
              'Id: ${parking.id}\n Parkering: ${parking.parkingSpace?.address}\n Time (start and end): ${parking.startTime}-${parking.endTime}\n Reg. number: ${parking.vehicle?.regNumber}\n');
        }
      }
    } catch (e) {
      _printError('Fel vid visning av parkeringar: ${e.toString()}');
      setMainPage();
      return;
    } finally {
      _waitForUserInput();
    }
  }

  void _updateParkingOperation() async {
    print('\n--- Uppdatera en parkering ---');

    // Fetch all parkings
    final parkingList = await parkingRepository.getAllParkings();
    if (parkingList.isEmpty) {
      print(
          'Finns inga parkeringar att uppdatera, skapa en ny parkering först.');
      setMainPage();
      return;
    }

    // Prompt for registration number
    String? regNrInput;
    do {
      regNrInput = _promptInput('Fyll i registreringsnummer:');
      if (regNrInput == null || regNrInput.isEmpty) {
        _printError('Du måste ange ett registreringsnummer. Försök igen.');
      }
    } while (regNrInput == null || regNrInput.isEmpty);

    // Normalize registration number for comparison
    regNrInput = regNrInput.toUpperCase();

    // Find parking by registration number
    final foundParkingIndexId =
        parkingList.indexWhere((p) => p.vehicle?.regNumber == regNrInput);

    if (foundParkingIndexId == -1) {
      print('Finns ingen aktiv parkering med angivet registreringsnummer');
      setMainPage();
      return;
    }

    // Ask for new end time
    print('Vill du uppdatera parkeringens sluttid? Annars tryck Enter: ');
    final endTimeInput = stdin.readLineSync();

    if (endTimeInput == null || endTimeInput.isEmpty) {
      print('Du gjorde ingen ändring!');
      setMainPage();
      return;
    }

    // Validate and parse end time
    final formattedEndTimeInput =
        DateTime.tryParse(_getCorrectDate(endTimeInput));
    if (formattedEndTimeInput == null) {
      _printError('Du angav ett felaktigt tidsformat');
      setMainPage();
      return;
    }

    try {
      // Retrieve parking details by ID
      final parkingToUpdate = await parkingRepository.getParkingById(
        parkingList[foundParkingIndexId].id,
      );

      // Update parking in repository
      final updatedParking = Parking(
        id: parkingToUpdate.id,
        vehicle: parkingToUpdate.vehicle,
        parkingSpace: parkingToUpdate.parkingSpace,
        startTime: parkingToUpdate.startTime,
        endTime: formattedEndTimeInput,
      );

      final updateResult = await parkingRepository.updateParking(
        parkingToUpdate.id,
        updatedParking,
      );

      if (updateResult.id != -1) {
        calculateDuration(
          parkingToUpdate.startTime,
          formattedEndTimeInput,
          parkingToUpdate.parkingSpace!.pricePerHour.toDouble(),
        );
        print('Parkering uppdaterad.');
      } else {
        _printError('Något gick fel vid uppdatering av parkeringen.');
      }
    } catch (e) {
      _printError('Ett oväntat fel inträffade: ${e.toString()}');
    } finally {
      setMainPage();
    }
  }

  /// Ta bort parkering

  Future<void> _deleteParkingOperation() async {
    print('\n--- Ta bort en parkering ---\n');

    try {
      // Step 1: Retrieve all parkings from the repository
      final parkingList = await parkingRepository.getAllParkings();

      if (parkingList.isEmpty) {
        print('Inga parkeringar hittades.');
        setMainPage();
        return;
      }

      // Step 2: Prompt the user for the registration number of the parking to delete
      String? regInput;
      do {
        regInput = _promptInput(
            'Ange registreringsnummer för den parkeringen du vill ta bort:');
        if (regInput == null ||
            regInput.isEmpty ||
            !Validator.isValidRegistrationNumber(regInput)) {
          _printError('Ogiltigt registreringsnummer. Försök igen.');
        }
      } while (regInput == null ||
          regInput.isEmpty ||
          !Validator.isValidRegistrationNumber(regInput));

      // Normalize input for matching
      regInput = regInput.toUpperCase();

      // Step 3: Find the parking by registration number
      final parkingIndex = parkingList
          .indexWhere((parking) => parking.vehicle?.regNumber == regInput);

      if (parkingIndex == -1) {
        _printError(
            'Ingen parkering hittades med det angivna registreringsnumret.');
        setMainPage();
        return;
      }

      final parkingToDelete = parkingList[parkingIndex];

      // Step 4: Delete the parking from the repository
      await parkingRepository.deleteParking(parkingToDelete.id);

      // Notify the user
      print(
          'Parkeringen med registreringsnummer ${parkingToDelete.vehicle?.regNumber} har tagits bort.');
    } catch (e) {
      _printError('Ett oväntat fel inträffade: ${e.toString()}');
    } finally {
      setMainPage();
    }
  }

  /// Hjälpmetod för att läsa användarinmatning
  String? _promptInput(String promptText) {
    stdout.write(promptText);
    return stdin.readLineSync()?.trim();
  }

  /// Väntar på användarinmatning innan återgång till huvudmenyn
  void _waitForUserInput() {
    print('Tryck på valfri tangent för att återgå till huvudmenyn.');
    stdin.readLineSync();
    setMainPage(clearCLI: true);
  }

  /// Validerar om en sträng är ett giltigt nummer
  bool _validateNumber(String input) {
    final number = int.tryParse(input);
    return number != null;
  }

  /// Beräknar och skriver ut parkeringens varaktighet och kostnad
  void calculateDuration(
      DateTime startTime, DateTime endTime, double pricePerHour) {
    final duration = endTime.difference(startTime);
    final hours = duration.inHours + (duration.inMinutes % 60) / 60.0;
    final cost = hours * pricePerHour;
    print(
        'Parkeringens varaktighet: ${duration.inHours} timmar och ${duration.inMinutes % 60} minuter');
    print('Total kostnad: ${cost.toStringAsFixed(2)} SEK');
  }

  /// Skriver ut ett felmeddelande
  void _printError(String message) {
    print('Fel: $message');
  }
}

String _getCorrectDate(String endTime) {
  DateTime dateToday = DateTime.now();
  String date = dateToday.toString().substring(0, 10);
  return '$date $endTime';
}
