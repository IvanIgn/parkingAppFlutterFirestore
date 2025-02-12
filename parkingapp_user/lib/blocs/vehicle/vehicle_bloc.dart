import 'package:bloc/bloc.dart';
import 'package:shared/shared.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:equatable/equatable.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  List<Vehicle> _vehicleList = [];
  final VehicleRepository repository; // Inject repository

  VehicleBloc(this.repository) : super(VehiclesInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<LoadVehiclesByPerson>(_onLoadVehiclesByPerson);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<CreateVehicle>(_onCreateVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<SelectVehicle>(_onSelectVehicle);
  }

  Future<void> _onLoadVehicles(
      LoadVehicles event, Emitter<VehicleState> emit) async {
    emit(VehiclesLoading());
    try {
      _vehicleList = await repository.getAllVehicles();
      emit(VehiclesLoaded(vehicles: _vehicleList));
    } catch (e) {
      emit(VehiclesError(message: 'Failed to load vehicles: $e'));
    }
  }

  Future<void> _onLoadVehiclesByPerson(
      LoadVehiclesByPerson event, Emitter<VehicleState> emit) async {
    emit(VehiclesLoading());
    try {
      final vehicles = await repository.getVehiclesForUser(event.userId);
      emit(VehiclesLoaded(vehicles: vehicles)); // Emit user-specific vehicles
    } catch (e) {
      emit(VehiclesError(message: 'Failed to load vehicles: $e'));
    }
  }

  Future<void> _onCreateVehicle(
      CreateVehicle event, Emitter<VehicleState> emit) async {
    try {
      emit(VehiclesLoading()); // Emit loading state

      // Load the vehicles list first
      final allVehicles = await repository.getAllVehicles();

      // Check if a vehicle with the same registration number exists
      final vehicleExists = allVehicles.any(
        (vehicle) => vehicle.regNumber == event.vehicle.regNumber,
      );

      if (vehicleExists) {
        // Instead of emitting an error, simply ignore and load the list again
        // You could also show the error message as a SnackBar or Toast if needed
        // Just omit the emit of VehiclesError, and re-load the vehicle list
        final updatedVehicles = await repository.getAllVehicles();
        emit(VehiclesLoaded(vehicles: updatedVehicles, selectedVehicle: null));
        return;
      }

      // If no duplicate is found, create the vehicle
      await repository.createVehicle(event.vehicle);

      // After creation, load the vehicles list again (with the new vehicle)
      final updatedVehicles = await repository.getAllVehicles();

      // Emit the updated list of vehicles
      emit(VehiclesLoaded(vehicles: updatedVehicles, selectedVehicle: null));
    } catch (e) {
      emit(VehiclesError(message: 'Failed to add vehicles after creation: $e'));
    }
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehiclesLoading()); // Emit loading state

    try {
      // Load all vehicles first to check for duplicate regNumber
      final allVehicles = await repository.getAllVehicles();

      // Check if a vehicle with the same registration number exists
      final vehicleExists = allVehicles.any(
        (vehicle) =>
            vehicle.regNumber == event.vehicle.regNumber &&
            vehicle.id != event.vehicle.id,
      );

      if (vehicleExists) {
        // If a vehicle with the same regNumber exists, show an error in the form
        emit(VehiclesError(message: 'Fordon med detta reg.nummer finns redan'));
        return; // Exit early if there's a duplicate registration number
      }

      // Proceed with updating the vehicle if no duplicates are found
      await repository.updateVehicle(event.vehicle.id, event.vehicle);

      // Load the updated list of vehicles (this should return the updated list)
      final updatedVehicles = await repository.getAllVehicles();

      // Emit the updated vehicle and the updated vehicle list
      emit(VehicleUpdated(vehicle: event.vehicle)); // Emit vehicle updated
      emit(VehiclesLoaded(vehicles: updatedVehicles)); // Emit loaded vehicles
    } catch (error) {
      emit(VehiclesError(message: 'Failed to update vehicle: $error'));
    }
  }

  Future<void> _onDeleteVehicle(
      DeleteVehicle event, Emitter<VehicleState> emit) async {
    try {
      emit(VehiclesLoading()); // Emit loading state

      // Attempt to delete the vehicle
      await repository.deleteVehicle(event.vehicle.id);

      // Get the updated list of vehicles (could be empty)
      final updatedVehicles = await repository.getAllVehicles();

      // After successful deletion, emit the VehicleDeleted state
      emit(VehicleDeleted(vehicle: event.vehicle));

      // Emit the updated list of vehicles (which will be empty if no vehicles exist)
      emit(VehiclesLoaded(vehicles: updatedVehicles, selectedVehicle: null));
    } catch (e) {
      // If an error occurs during deletion, emit an error state
      emit(VehiclesError(
        message: 'Failed to delete vehicle: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSelectVehicle(
      SelectVehicle event, Emitter<VehicleState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final currentState = state;

    if (currentState is VehiclesLoaded) {
      final isSameVehicle =
          currentState.selectedVehicle?.id == event.vehicle.id;

      if (isSameVehicle) {
        // Deselect the vehicle (remove from shared preferences)
        await prefs.remove('selectedVehicle');
        emit(VehiclesLoaded(
            vehicles: currentState.vehicles, selectedVehicle: null));
      } else {
        // Find the full vehicle object with owner details
        final selectedVehicle = currentState.vehicles.firstWhere(
            (vehicle) => vehicle.id == event.vehicle.id,
            orElse: () => event.vehicle);

        // Store the selected vehicle in shared preferences
        final vehicleJson = json.encode(selectedVehicle.toJson());
        await prefs.setString('selectedVehicle', vehicleJson);
        emit(VehiclesLoaded(
            vehicles: currentState.vehicles, selectedVehicle: selectedVehicle));
      }
    }
  }
}
