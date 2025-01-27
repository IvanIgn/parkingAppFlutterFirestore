import 'package:bloc/bloc.dart';
import 'package:shared/shared.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

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

      // Load selected parking space
      final selectedParkingSpaceJson = prefs.getString('selectedParkingSpace');
      final selectedParkingSpace = selectedParkingSpaceJson != null
          ? ParkingSpace.fromJson(json.decode(selectedParkingSpaceJson))
          : null;

      // Load active parking state
      final isParkingActive = prefs.getBool('isParkingActive') ?? false;

      emit(ParkingSpaceLoaded(
        parkingSpaces: parkingSpaces,
        selectedParkingSpace: selectedParkingSpace,
        isParkingActive: isParkingActive,
      ));
    } catch (e) {
      emit(ParkingSpaceError(e.toString()));
      return;
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

    if (state is ParkingSpaceLoaded && selectedVehicleJson != null) {
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
        id: loggedInPersonMap['id'], // `id` is already an `int`
        name: loggedInPersonMap['name'],
        personNumber: loggedInPersonMap['personNumber'],
      );

      // Validate and parse JSON data
      final selectedParkingSpaceJson = prefs.getString('selectedParkingSpace');
      final selectedVehicleJson = prefs.getString('selectedVehicle');

      if (selectedParkingSpaceJson == null || selectedVehicleJson == null) {
        throw Exception(
            "Missing parking or vehicle data in SharedPreferences.");
      }

      final selectedParkingSpace =
          ParkingSpace.fromJson(json.decode(selectedParkingSpaceJson));
      var selectedVehicle = Vehicle.fromJson(json.decode(selectedVehicleJson));

      // Update vehicle owner information
      selectedVehicle = Vehicle(
        regNumber: selectedVehicle.regNumber,
        vehicleType: selectedVehicle.vehicleType,
        owner: loggedInPerson,
      );

      // Get the next available parking ID
      final parkings = await parkingRepository.getAllParkings();
      final nextParkingId = parkings.isNotEmpty ? parkings.last.id + 1 : 1;

      // Create a new parking instance
      final parkingInstance = Parking(
        id: nextParkingId,
        vehicle: selectedVehicle,
        parkingSpace: selectedParkingSpace,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 2)),
      );

      // Debugging created objects
      debugPrint('Creating parking instance:');
      debugPrint('Vehicle: ${json.encode(selectedVehicle.toJson())}');
      debugPrint(
          'Parking Space: ${json.encode(selectedParkingSpace.toJson())}');
      debugPrint('Parking Instance: ${json.encode(parkingInstance.toJson())}');

      // Save the parking instance to SharedPreferences
      await prefs.setString('parking', json.encode(parkingInstance.toJson()));
      await prefs.setString(
          'activeParkingSpace', json.encode(selectedParkingSpace.toJson()));
      await prefs.setBool('isParkingActive', true);

      // Add the parking instance to the repository
      await parkingRepository.createParking(parkingInstance);

      // Update Bloc state
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

    if (parkingJson == null) return;

    final parkingInstance = Parking.fromJson(json.decode(parkingJson));
    await parkingRepository.deleteParking(parkingInstance.id);

    await prefs.remove('isParkingActive');
    await prefs.remove('parking');

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
