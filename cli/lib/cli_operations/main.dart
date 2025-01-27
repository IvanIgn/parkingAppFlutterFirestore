import 'dart:io';
import 'package:cli/utils/console.dart';
import 'parkingSpaces_operations.dart';
import 'parkings_operations.dart';
import 'persons_operations.dart';
import 'vehicles_operations.dart';

class SetMainPage {
  final List<String> firstPageTexts = [
    'Välkommen till parkeringsappen!\n',
    'Vad vill du hantera?\n',
    '1. Personer\n',
    '2. Fordon\n',
    '3. Parkeringsplatser\n',
    '4. Parkeringar\n',
    '5. Avsluta\n\n',
    'Välj ett alternativ (1-5): ',
  ];

  Future<void> setMainPage({bool clearCLI = false}) async {
    if (clearCLI) clearConsole();
    stdout.writeAll(firstPageTexts);
    final input = stdin.readLineSync();

    if (input == null || input.isEmpty) {
      print('Du har inte valt något giltigt alternativ');
      return;
    }

    final option = int.tryParse(input);
    if (option == null || option < 1 || option > 5) {
      print('Ogiltigt val');
      return;
    }

    switch (option) {
      case 1:
        await _runSubMenu(PersonsOperations());
        break;
      case 2:
        await _runSubMenu(VehiclesOperations());
        break;
      case 3:
        await _runSubMenu(ParkingSpaceOperations());
        break;
      case 4:
        await _runSubMenu(ParkingsOperations());
        break;
      case 5:
        print('Du valde att avsluta');
        return;
      default:
        print('Ogiltigt val');
    }
  }

  Future<void> _runSubMenu(dynamic operation) async {
    clearConsole();
    stdout.writeAll(operation.menuTexts);
    final subInput = stdin.readLineSync();

    if (subInput == null || subInput.isEmpty) {
      print('Du har inte valt något giltigt alternativ');
      return;
    }

    final chosenOption = int.tryParse(subInput);
    if (chosenOption == null || chosenOption < 1 || chosenOption > 5) {
      print('Ogiltigt val');
      return;
    }

    // Await the operation run if it is async
    await operation.runOperation(chosenOption);
  }
}
