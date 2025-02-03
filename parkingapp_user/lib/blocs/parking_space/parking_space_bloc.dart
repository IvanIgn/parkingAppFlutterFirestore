import 'package:bloc/bloc.dart';
import 'package:shared/shared.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

part 'parking_space_event.dart';
part 'parking_space_state.dart';

class ParkingSpaceBloc extends Bloc<ParkingSpaceEvent, ParkingSpaceState> {
  final ParkingSpaceRepository parkingSpaceRepository;
  final PersonRepository personRepository;
  final ParkingRepository parkingRepository;
  final VehicleRepository vehicleRepository;
  ParkingSpaceBloc(
      {required this.parkingSpaceRepository,
      required this.parkingRepository,
      required this.personRepository,
      required this.vehicleRepository})
      : super(ParkingSpaceInitial()) {
    on<LoadParkingSpaces>(_onLoadParkingSpaces);
    on<SelectParkingSpace>(_onSelectParkingSpace);
    on<StartParking>(_onStartParking);
    on<StopParking>(_onStopParking);
    on<DeselectParkingSpace>(_onDeselectParkingSpace);
  }

  Future<void> _onLoadParkingSpaces(
    LoadParkingSpaces event,
    Emitter<ParkingSpaceState> emit,
  ) async {
    emit(ParkingSpaceLoading());
    try {
      final parkingSpaces = await parkingSpaceRepository.getAllParkingSpaces();
      final prefs = await SharedPreferences.getInstance();

      // Load selected parking space safely
      final selectedParkingSpaceJson = prefs.getString('selectedParkingSpace');
      ParkingSpace? selectedParkingSpace;

      if (selectedParkingSpaceJson != null &&
          selectedParkingSpaceJson.isNotEmpty) {
        try {
          final decodedJson = json.decode(selectedParkingSpaceJson);
          final parsedSpace = ParkingSpace.fromJson(decodedJson);

          if (parkingSpaces.any((space) => space.id == parsedSpace.id)) {
            selectedParkingSpace = parsedSpace;
          }
        } catch (e) {
          debugPrint('Error decoding selectedParkingSpace JSON: $e');
        }
      }

      // Load active parking state safely
      final isParkingActive = prefs.getBool('isParkingActive') ?? false;

      emit(ParkingSpaceLoaded(
        parkingSpaces: parkingSpaces,
        selectedParkingSpace: selectedParkingSpace,
        isParkingActive: isParkingActive,
      ));
    } catch (e) {
      debugPrint('Error loading parking spaces: $e'); // Log the error
      emit(ParkingSpaceError(e.toString()));
    }
  }

  Future<void> _onSelectParkingSpace(
    SelectParkingSpace event,
    Emitter<ParkingSpaceState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final parkingSpaceJson = json.encode(event.parkingSpace.toJson());
    await prefs.setString('selectedParkingSpace', parkingSpaceJson);
    final selectedVehicleJson = prefs.getString('selectedVehicle');

    if (state is ParkingSpaceLoaded) {
      final currentState = state as ParkingSpaceLoaded;
      emit(ParkingSpaceLoaded(
        parkingSpaces: currentState.parkingSpaces,
        selectedParkingSpace: event.parkingSpace,
        isParkingActive: currentState.isParkingActive,
      ));
    }
  }

  Future<void> _onDeselectParkingSpace(
    DeselectParkingSpace event,
    Emitter<ParkingSpaceState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Clear the selected parking space from shared preferences
    await prefs.remove('selectedParkingSpace');

    if (state is ParkingSpaceLoaded) {
      final currentState = state as ParkingSpaceLoaded;

      // Emit a new state with `selectedParkingSpace` set to null
      emit(ParkingSpaceLoaded(
        parkingSpaces: currentState.parkingSpaces,
        selectedParkingSpace: null,
        isParkingActive: currentState.isParkingActive,
      ));
    }
  }

  // Future<void> _onStartParking(
  //   StartParking event,
  //   Emitter<ParkingSpaceState> emit,
  // ) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();

  //     final loggedInPersonJson = prefs.getString('loggedInPerson');

  //     if (loggedInPersonJson == null) {
  //       throw Exception("Missing logged-in person data in SharedPreferences.");
  //     }

  //     // Create logged-in person object
  //     final loggedInPersonMap =
  //         json.decode(loggedInPersonJson) as Map<String, dynamic>;
  //     final loggedInPerson = Person(
  //       id: loggedInPersonMap['id'], // `id` is already an `int`
  //       name: loggedInPersonMap['name'],
  //       personNumber: loggedInPersonMap['personNumber'],
  //     );

  //     // Validate and parse JSON data
  //     final selectedParkingSpaceJson = prefs.getString('selectedParkingSpace');
  //     final selectedVehicleJson = prefs.getString('selectedVehicle');

  //     if (selectedParkingSpaceJson == null || selectedVehicleJson == null) {
  //       throw Exception(
  //           "Missing parking or vehicle data in SharedPreferences.");
  //     }
  //     final selectedParkingSpace =
  //         ParkingSpace.fromJson(json.decode(selectedParkingSpaceJson));
  //     var selectedVehicle = Vehicle.fromJson(json.decode(selectedVehicleJson));

  //     // Update vehicle owner information
  //     selectedVehicle = Vehicle(
  //       id: selectedVehicle.id,
  //       regNumber: selectedVehicle.regNumber,
  //       vehicleType: selectedVehicle.vehicleType,
  //       owner: loggedInPerson,
  //     );

  //     // Get the next available parking ID
  //     final parkings = await parkingRepository.getAllParkings();
  //     final nextParkingId = parkings.isNotEmpty ? parkings.last.id + 1 : 1;

  //     // Create a new parking instance
  //     final parkingInstance = Parking(
  //       id: nextParkingId,
  //       vehicle: selectedVehicle,
  //       parkingSpace: selectedParkingSpace,
  //       startTime: DateTime.now(),
  //       endTime: DateTime.now().add(const Duration(hours: 2)),
  //     );

  //     // Debugging created objects
  //     debugPrint('Creating parking instance:');
  //     debugPrint('Vehicle: ${json.encode(selectedVehicle.toJson())}');
  //     debugPrint(
  //         'Parking Space: ${json.encode(selectedParkingSpace.toJson())}');
  //     debugPrint('Parking Instance: ${json.encode(parkingInstance.toJson())}');

  //     // Save the parking instance to SharedPreferences
  //     await prefs.setString('parking', json.encode(parkingInstance.toJson()));
  //     await prefs.setString(
  //         'activeParkingSpace', json.encode(selectedParkingSpace.toJson()));
  //     await prefs.setBool('isParkingActive', true);

  //     // Add the parking instance to the repository
  //     await parkingRepository.createParking(parkingInstance);

  //     // Update Bloc state with selectedParkingSpace correctly set
  //     if (state is ParkingSpaceLoaded) {
  //       final currentState = state as ParkingSpaceLoaded;
  //       emit(ParkingSpaceLoaded(
  //         parkingSpaces: currentState.parkingSpaces,
  //         selectedParkingSpace:
  //             selectedParkingSpace, // Keep selectedParkingSpace as is
  //         isParkingActive: true,
  //       ));
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint('Error in _onStartParking: $e');
  //     debugPrint(stackTrace.toString());
  //     emit(ParkingSpaceError('Error starting parking: ${e.toString()}'));
  //   }
  // }

  // Future<void> _onStartParking(
  //   StartParking event,
  //   Emitter<ParkingSpaceState> emit,
  // ) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();

  //     final loggedInPersonJson = prefs.getString('loggedInPerson');
  //     if (loggedInPersonJson == null) {
  //       throw Exception("Missing logged-in person data in SharedPreferences.");
  //     }

  //     // Create logged-in person object
  //     final loggedInPersonMap =
  //         json.decode(loggedInPersonJson) as Map<String, dynamic>;
  //     final loggedInPerson = Person(
  //       id: loggedInPersonMap['id'], // `id` is already an `int`
  //       name: loggedInPersonMap['name'],
  //       personNumber: loggedInPersonMap['personNumber'],
  //     );

  //     // Helper method to load selected parking space and vehicle
  //     final parkingData = await _loadParkingData(prefs);
  //     final selectedParkingSpace = parkingData['parkingSpace'] as ParkingSpace;
  //     final selectedVehicle = parkingData['vehicle'] as Vehicle;

  //     // Get the next available parking ID
  //     final parkings = await parkingRepository.getAllParkings();
  //     final nextParkingId = parkings.isNotEmpty ? parkings.last.id + 1 : 1;

  //     // Create parking instance
  //     final parkingInstance = Parking(
  //       id: nextParkingId,
  //       vehicle: selectedVehicle.copyWith(owner: loggedInPerson),
  //       parkingSpace: selectedParkingSpace,
  //       startTime: DateTime.now(),
  //       endTime: DateTime.now().add(const Duration(hours: 2)),
  //     );

  //     await prefs.setString('parking', json.encode(parkingInstance.toJson()));
  //     await prefs.setString(
  //         'activeParkingSpace', json.encode(selectedParkingSpace.toJson()));
  //     await prefs.setBool('isParkingActive', true);

  //     await parkingRepository.createParking(parkingInstance);

  //     // Emit state after parking starts
  //     if (state is ParkingSpaceLoaded) {
  //       final currentState = state as ParkingSpaceLoaded;
  //       emit(ParkingSpaceLoaded(
  //         parkingSpaces: currentState.parkingSpaces,
  //         selectedParkingSpace: selectedParkingSpace,
  //         isParkingActive: true,
  //       ));
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint('Error in _onStartParking: $e');
  //     debugPrint(stackTrace.toString());
  //     emit(ParkingSpaceError('Error starting parking: ${e.toString()}'));
  //   }
  // }

  // Future<Map<String, dynamic>> _loadParkingData(SharedPreferences prefs) async {
  //   final selectedParkingSpaceJson = prefs.getString('selectedParkingSpace');
  //   final selectedVehicleJson = prefs.getString('selectedVehicle');

  //   if (selectedParkingSpaceJson == null || selectedVehicleJson == null) {
  //     throw Exception("Missing parking or vehicle data in SharedPreferences.");
  //   }

  //   final selectedParkingSpace =
  //       ParkingSpace.fromJson(json.decode(selectedParkingSpaceJson));
  //   final selectedVehicle = Vehicle.fromJson(json.decode(selectedVehicleJson));

  //   return {
  //     'parkingSpace': selectedParkingSpace,
  //     'vehicle': selectedVehicle,
  //   };
  // }

  Future<Map<String, dynamic>> _loadParkingData(SharedPreferences prefs) async {
    final selectedParkingSpaceJson = prefs.getString('selectedParkingSpace');
    final selectedVehicleJson = prefs.getString('selectedVehicle');

    if (selectedParkingSpaceJson == null || selectedVehicleJson == null) {
      throw Exception("Missing parking or vehicle data in SharedPreferences.");
    }

    try {
      final selectedParkingSpace =
          ParkingSpace.fromJson(json.decode(selectedParkingSpaceJson));
      final selectedVehicle =
          Vehicle.fromJson(json.decode(selectedVehicleJson));

      return {
        'parkingSpace': selectedParkingSpace,
        'vehicle': selectedVehicle,
      };
    } catch (e) {
      throw Exception("Error parsing parking or vehicle data: $e");
    }
  }

  Future<void> _onStartParking(
    StartParking event,
    Emitter<ParkingSpaceState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final loggedInPersonJson = prefs.getString('loggedInPerson');
      if (loggedInPersonJson == null) {
        throw Exception("Missing logged-in person data in SharedPreferences.");
      }

      // Create logged-in person object
      final loggedInPersonMap =
          json.decode(loggedInPersonJson) as Map<String, dynamic>;
      final loggedInPerson = Person(
        id: loggedInPersonMap['id'],
        name: loggedInPersonMap['name'],
        personNumber: loggedInPersonMap['personNumber'],
      );

      // Helper method to load selected parking space and vehicle
      final parkingData = await _loadParkingData(prefs);
      final selectedParkingSpace = parkingData['parkingSpace'] as ParkingSpace;
      final selectedVehicle = parkingData['vehicle'] as Vehicle;

      // Debug logs
      debugPrint('Selected Parking Space: $selectedParkingSpace');
      debugPrint('Selected Vehicle: $selectedVehicle');

      // Get all existing parkings
      // final parkings = await parkingRepository.getAllParkings();

      // Determine next available parking ID
      // final nextParkingId = parkings.isNotEmpty ? parkings.last.id + 1 : 1;

      // debugPrint('Next Parking ID: $nextParkingId');

      // Create parking instance with the next available ID
      final parkingInstance = Parking(
        id: 0,
        vehicle: selectedVehicle.copyWith(owner: loggedInPerson),
        parkingSpace: selectedParkingSpace,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 2)),
      );

// Save to the database
      final createdParking =
          await parkingRepository.createParking(parkingInstance);

// Fetch the parking again using the actual assigned ID
      final allParkings = await parkingRepository.getAllParkings();
      final exactParking = allParkings.firstWhere(
        (parking) => parking.id == createdParking.id,
        orElse: () => throw Exception("Parking not found"),
      );
      // final fetchedParkingInstance = Parking(
      //   id: exactParking.id,
      //   vehicle: selectedVehicle.copyWith(owner: loggedInPerson),
      //   parkingSpace: selectedParkingSpace,
      //   startTime: DateTime.now(),
      //   endTime: DateTime.now().add(const Duration(hours: 2)),
      // );

      debugPrint(
          "Exact parking retrieved: ${json.encode(exactParking.toJson())}");

      // Store the parking data in SharedPreferences
      await prefs.setString('parking', json.encode(exactParking.toJson()));
      await prefs.setString(
          'activeParkingSpace', json.encode(selectedParkingSpace.toJson()));
      await prefs.setBool('isParkingActive', true);

      // Attempt to create parking in the repository

      // Emit the updated state after parking starts
      if (state is ParkingSpaceLoaded) {
        final currentState = state as ParkingSpaceLoaded;
        emit(ParkingSpaceLoaded(
          parkingSpaces: currentState.parkingSpaces,
          selectedParkingSpace: selectedParkingSpace,
          isParkingActive: true,
        ));
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _onStartParking: $e');
      debugPrint(stackTrace.toString());
      emit(ParkingSpaceError('Error starting parking: ${e.toString()}'));
    }
  }

  Future<void> _onStopParking(
    StopParking event,
    Emitter<ParkingSpaceState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final parkingJson = prefs.getString('parking');

    if (parkingJson != null) {
      final parkingInstance = Parking.fromJson(json.decode(parkingJson));
      await parkingRepository.deleteParking(parkingInstance.id);

      await prefs.remove('isParkingActive');
      await prefs.remove('parking');
    }

    // Ensure a new state is emitted no matter what
    if (state is ParkingSpaceLoaded) {
      final currentState = state as ParkingSpaceLoaded;
      emit(ParkingSpaceLoaded(
        parkingSpaces: currentState.parkingSpaces,
        selectedParkingSpace: null,
        isParkingActive: false,
      ));
    }
  }
}


  // Future<void> _onStartParking(
  //   StartParking event,
  //   Emitter<ParkingSpaceState> emit,
  // ) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();

  //     // Load and validate logged-in person data
  //     final loggedInPersonJson = prefs.getString('loggedInPerson');
  //     debugPrint('Logged-in person JSON: $loggedInPersonJson');
  //     if (loggedInPersonJson == null || loggedInPersonJson.isEmpty) {
  //       throw Exception("Missing or invalid logged-in person data.");
  //     }

  //     final loggedInPersonMap = jsonDecode(loggedInPersonJson);
  //     final loggedInPerson = Person(
  //       id: loggedInPersonMap['id'],
  //       name: loggedInPersonMap['name'],
  //       personNumber: loggedInPersonMap['personNumber'],
  //     );

  //     // Load and validate selected parking space
  //     final selectedParkingSpaceJson = prefs.getString('selectedParkingSpace');
  //     debugPrint('Selected parking space JSON: $selectedParkingSpaceJson');
  //     if (selectedParkingSpaceJson == null ||
  //         selectedParkingSpaceJson.isEmpty) {
  //       throw Exception("Missing or invalid parking space data.");
  //     }

  //     ParkingSpace selectedParkingSpace;
  //     try {
  //       selectedParkingSpace =
  //           ParkingSpace.fromJson(jsonDecode(selectedParkingSpaceJson));
  //     } catch (e) {
  //       throw Exception("Corrupt parking space data: $e");
  //     }

  //     // Load and validate selected vehicle
  //     final selectedVehicleJson = prefs.getString('selectedVehicle');
  //     debugPrint('Selected vehicle JSON: $selectedVehicleJson');
  //     if (selectedVehicleJson == null || selectedVehicleJson.isEmpty) {
  //       throw Exception("Missing or invalid vehicle data.");
  //     }

  //     Vehicle selectedVehicle;
  //     try {
  //       selectedVehicle = Vehicle.fromJson(jsonDecode(selectedVehicleJson));
  //     } catch (e) {
  //       throw Exception("Corrupt vehicle data: $e");
  //     }

  //     // Update vehicle owner
  //     selectedVehicle = Vehicle(
  //       id: selectedVehicle.id,
  //       regNumber: selectedVehicle.regNumber,
  //       vehicleType: selectedVehicle.vehicleType,
  //       owner: loggedInPerson,
  //     );

  //     // Fetch existing parkings and determine next ID
  //     final parkings = await parkingRepository.getAllParkings();
  //     final nextParkingId = parkings.isNotEmpty ? parkings.last.id + 1 : 1;

  //     // Create new parking instance
  //     final parkingInstance = Parking(
  //       id: nextParkingId,
  //       vehicle: selectedVehicle,
  //       parkingSpace: selectedParkingSpace,
  //       startTime: DateTime.now(),
  //       endTime: DateTime.now().add(const Duration(hours: 2)),
  //     );

  //     debugPrint(
  //         "Saving parking instance: ${jsonEncode(parkingInstance.toJson())}");

  //     // Save to SharedPreferences
  //     await prefs.setString('parking', jsonEncode(parkingInstance.toJson()));
  //     await prefs.setString(
  //         'activeParkingSpace', jsonEncode(selectedParkingSpace.toJson()));
  //     await prefs.setBool('isParkingActive', true);

  //     // Add parking instance to repository
  //     try {
  //       await parkingRepository.createParking(parkingInstance);
  //     } catch (e) {
  //       debugPrint("Failed to create parking: $e");
  //       throw Exception("Failed to create parking: $e");
  //     }

  //     // Emit updated state
  //     if (state is ParkingSpaceLoaded) {
  //       final currentState = state as ParkingSpaceLoaded;
  //       emit(ParkingSpaceLoaded(
  //         parkingSpaces: currentState.parkingSpaces,
  //         selectedParkingSpace: selectedParkingSpace,
  //         isParkingActive: true,
  //       ));
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint('Error in _onStartParking: $e');
  //     debugPrint(stackTrace.toString());
  //     emit(ParkingSpaceError('Error starting parking: ${e.toString()}'));
  //   }
  // }


 // Future<void> _onStartParking(
  //   StartParking event,
  //   Emitter<ParkingSpaceState> emit,
  // ) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();

  //     final loggedInPersonJson = prefs.getString('loggedInPerson');

  //     if (loggedInPersonJson == null) {
  //       throw Exception("Missing logged-in person data in SharedPreferences.");
  //     }

  //     // Create logged-in person object
  //     final loggedInPersonMap =
  //         json.decode(loggedInPersonJson) as Map<String, dynamic>;
  //     final loggedInPerson = Person(
  //       id: loggedInPersonMap['id'], // `id` is already an `int`
  //       name: loggedInPersonMap['name'],
  //       personNumber: loggedInPersonMap['personNumber'],
  //     );

  //     // Validate and parse JSON data
  //     final selectedParkingSpaceJson = prefs.getString('selectedParkingSpace');
  //     final selectedVehicleJson = prefs.getString('selectedVehicle');

  //     if (selectedParkingSpaceJson == null || selectedVehicleJson == null) {
  //       throw Exception(
  //           "Missing parking or vehicle data in SharedPreferences.");
  //     }
  //     final selectedParkingSpace =
  //         ParkingSpace.fromJson(json.decode(selectedParkingSpaceJson));
  //     var selectedVehicle = Vehicle.fromJson(json.decode(selectedVehicleJson));

  //     // Update vehicle owner information
  //     selectedVehicle = Vehicle(
  //       regNumber: selectedVehicle.regNumber,
  //       vehicleType: selectedVehicle.vehicleType,
  //       owner: loggedInPerson,
  //     );

  //     // Get the next available parking ID
  //     final parkings = await parkingRepository.getAllParkings();
  //     final nextParkingId = parkings.isNotEmpty ? parkings.last.id + 1 : 1;

  //     // Create a new parking instance
  //     final parkingInstance = Parking(
  //       id: nextParkingId,
  //       vehicle: selectedVehicle,
  //       parkingSpace: selectedParkingSpace,
  //       startTime: DateTime.now(),
  //       endTime: DateTime.now().add(const Duration(hours: 2)),
  //     );

  //     // Debugging created objects
  //     debugPrint('Creating parking instance:');
  //     debugPrint('Vehicle: ${json.encode(selectedVehicle.toJson())}');
  //     debugPrint(
  //         'Parking Space: ${json.encode(selectedParkingSpace.toJson())}');
  //     debugPrint('Parking Instance: ${json.encode(parkingInstance.toJson())}');

  //     // Save the parking instance to SharedPreferences
  //     await prefs.setString('parking', json.encode(parkingInstance.toJson()));
  //     await prefs.setString(
  //         'activeParkingSpace', json.encode(selectedParkingSpace.toJson()));
  //     await prefs.setBool('isParkingActive', true);

  //     // Add the parking instance to the repository
  //     await parkingRepository.createParking(parkingInstance);

  //     // Update Bloc state with selectedParkingSpace correctly set
  //     if (state is ParkingSpaceLoaded) {
  //       final currentState = state as ParkingSpaceLoaded;
  //       emit(ParkingSpaceLoaded(
  //         parkingSpaces: currentState.parkingSpaces,
  //         selectedParkingSpace:
  //             selectedParkingSpace, // Keep selectedParkingSpace as is
  //         isParkingActive: true,
  //       ));
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint('Error in _onStartParking: $e');
  //     debugPrint(stackTrace.toString());
  //     emit(ParkingSpaceError('Error starting parking: ${e.toString()}'));
  //   }
  // }



  // Future<void> _onLoadParkingSpaces(
  //   LoadParkingSpaces event,
  //   Emitter<ParkingSpaceState> emit,
  // ) async {
  //   emit(ParkingSpaceLoading());
  //   try {
  //     final parkingSpaces = await parkingSpaceRepository.getAllParkingSpaces();
  //     final prefs = await SharedPreferences.getInstance();

  //     // Load selected parking space
  //     final selectedParkingSpaceJson = prefs.getString('selectedParkingSpace');
  //     final selectedParkingSpace = selectedParkingSpaceJson != null &&
  //             parkingSpaces.any((space) =>
  //                 space.id ==
  //                 ParkingSpace.fromJson(json.decode(selectedParkingSpaceJson))
  //                     .id)
  //         ? ParkingSpace.fromJson(json.decode(selectedParkingSpaceJson))
  //         : null;

  //     // Load active parking state
  //     final isParkingActive = prefs.getBool('isParkingActive') ?? false;

  //     emit(ParkingSpaceLoaded(
  //       parkingSpaces: parkingSpaces,
  //       selectedParkingSpace: selectedParkingSpace,
  //       isParkingActive: isParkingActive,
  //     ));
  //   } catch (e) {
  //     debugPrint('Error loading parking spaces: $e'); // Log the error
  //     emit(ParkingSpaceError(e.toString()));
  //   }
  // }


  // Future<void> _onStopParking(
  //   StopParking event,
  //   Emitter<ParkingSpaceState> emit,
  // ) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final parkingJson = prefs.getString('parking');

  //   if (parkingJson == null) return;

  //   final parkingInstance = Parking.fromJson(json.decode(parkingJson));
  //   await parkingRepository.deleteParking(parkingInstance.id);

  //   await prefs.remove('isParkingActive');
  //   await prefs.remove('parking');

  //   if (state is ParkingSpaceLoaded) {
  //     final currentState = state as ParkingSpaceLoaded;
  //     emit(ParkingSpaceLoaded(
  //       parkingSpaces: currentState.parkingSpaces,
  //       selectedParkingSpace: null,
  //       isParkingActive: false,
  //     ));
  //   }
  // }



  // Future<void> _onLoadParkingSpaces(
  //   LoadParkingSpaces event,
  //   Emitter<ParkingSpaceState> emit,
  // ) async {
  //   emit(ParkingSpaceLoading());
  //   try {
  //     final parkingSpaces = await parkingSpaceRepository.getAllParkingSpaces();
  //     final prefs = await SharedPreferences.getInstance();

  //     // Load selected parking space
  //     final selectedParkingSpaceJson = prefs.getString('selectedParkingSpace');
  //     final selectedParkingSpace = selectedParkingSpaceJson != null
  //         ? ParkingSpace.fromJson(json.decode(selectedParkingSpaceJson))
  //         : null;

  //     // Load active parking state
  //     final isParkingActive = prefs.getBool('isParkingActive') ?? false;

  //     emit(ParkingSpaceLoaded(
  //       parkingSpaces: parkingSpaces,
  //       selectedParkingSpace: selectedParkingSpace,
  //       isParkingActive: isParkingActive,
  //     ));
  //   } catch (e) {
  //     emit(ParkingSpaceError(e.toString()));
  //     return;
  //   }
  // }



  // Future<void> _onStartParking(
  //   StartParking event,
  //   Emitter<ParkingSpaceState> emit,
  // ) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();

  //     final loggedInPersonJson = prefs.getString('loggedInPerson');

  //     if (loggedInPersonJson == null) {
  //       throw Exception("Missing logged-in person data in SharedPreferences.");
  //     }

  //     // Create logged-in person object
  //     final loggedInPersonMap =
  //         json.decode(loggedInPersonJson) as Map<String, dynamic>;
  //     final loggedInPerson = Person(
  //       id: loggedInPersonMap['id'], // `id` is already an `int`
  //       name: loggedInPersonMap['name'],
  //       personNumber: loggedInPersonMap['personNumber'],
  //     );

  //     // Validate and parse JSON data
  //     final selectedParkingSpaceJson = prefs.getString('selectedParkingSpace');
  //     final selectedVehicleJson = prefs.getString('selectedVehicle');

  //     if (selectedParkingSpaceJson == null || selectedVehicleJson == null) {
  //       throw Exception(
  //           "Missing parking or vehicle data in SharedPreferences.");
  //     }

  //     final selectedParkingSpace =
  //         ParkingSpace.fromJson(json.decode(selectedParkingSpaceJson));
  //     var selectedVehicle = Vehicle.fromJson(json.decode(selectedVehicleJson));

  //     // Update vehicle owner information
  //     selectedVehicle = Vehicle(
  //       regNumber: selectedVehicle.regNumber,
  //       vehicleType: selectedVehicle.vehicleType,
  //       owner: loggedInPerson,
  //     );

  //     // Get the next available parking ID
  //     final parkings = await parkingRepository.getAllParkings();
  //     final nextParkingId = parkings.isNotEmpty ? parkings.last.id + 1 : 1;

  //     // Create a new parking instance
  //     final parkingInstance = Parking(
  //       id: nextParkingId,
  //       vehicle: selectedVehicle,
  //       parkingSpace: selectedParkingSpace,
  //       startTime: DateTime.now(),
  //       endTime: DateTime.now().add(const Duration(hours: 2)),
  //     );

  //     // Debugging created objects
  //     debugPrint('Creating parking instance:');
  //     debugPrint('Vehicle: ${json.encode(selectedVehicle.toJson())}');
  //     debugPrint(
  //         'Parking Space: ${json.encode(selectedParkingSpace.toJson())}');
  //     debugPrint('Parking Instance: ${json.encode(parkingInstance.toJson())}');

  //     // Save the parking instance to SharedPreferences
  //     await prefs.setString('parking', json.encode(parkingInstance.toJson()));
  //     await prefs.setString(
  //         'activeParkingSpace', json.encode(selectedParkingSpace.toJson()));
  //     await prefs.setBool('isParkingActive', true);

  //     // Add the parking instance to the repository
  //     await parkingRepository.createParking(parkingInstance);

  //     // Update Bloc state
  //     if (state is ParkingSpaceLoaded) {
  //       final currentState = state as ParkingSpaceLoaded;
  //       emit(ParkingSpaceLoaded(
  //         parkingSpaces: currentState.parkingSpaces,
  //         selectedParkingSpace: selectedParkingSpace,
  //         isParkingActive: true,
  //       ));
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint('Error in _onStartParking: $e');
  //     debugPrint(stackTrace.toString());
  //     emit(ParkingSpaceError('Error starting parking: ${e.toString()}'));
  //   }
  // }