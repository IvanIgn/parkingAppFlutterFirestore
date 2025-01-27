import 'package:bloc/bloc.dart';
import 'package:shared/shared.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  List<Vehicle> _vehicleList = [];

  VehicleBloc() : super(VehiclesInitial()) {
    on<LoadVehicles>((event, emit) async {
      await _onLoadVehicles(emit);
    });

    on<LoadVehiclesByPerson>((event, emit) async {
      await _onLoadVehiclesByPerson(emit, event.person);
    });

    on<DeleteVehicles>((event, emit) async {
      await _onDeleteVehicle(emit, event.vehicle);
    });

    on<CreateVehicle>((event, emit) async {
      await _onCreateVehicle(emit, event.vehicle);
    });

    on<UpdateVehicles>((event, emit) async {
      await _onUpdateVehicle(emit, event.vehicle);
    });

    on<SelectVehicle>((event, emit) async {
      await _onSelectVehicle(emit, event.vehicle);
    });
  }

  Future<void> _onLoadVehicles(Emitter<VehicleState> emit) async {
    emit(VehiclesLoading());
    try {
      _vehicleList = await VehicleRepository.instance.getAllVehicles();
      emit(VehiclesLoaded(vehicles: _vehicleList));
    } catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }

  Future<void> _onLoadVehiclesByPerson(
      Emitter<VehicleState> emit, Person person) async {
    emit(VehiclesLoading());
    try {
      _vehicleList = await VehicleRepository.instance.getAllVehicles();
      final vehiclesForPerson = _vehicleList
          .where(
              (vehicle) => vehicle.owner?.personNumber == person.personNumber)
          .toList();
      emit(VehiclesLoaded(vehicles: vehiclesForPerson));
    } catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }

  Future<void> _onCreateVehicle(
      Emitter<VehicleState> emit, Vehicle vehicle) async {
    try {
      await VehicleRepository.instance.createVehicle(vehicle);
      add(LoadVehiclesByPerson(person: vehicle.owner!));
    } catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }

  Future<void> _onUpdateVehicle(
      Emitter<VehicleState> emit, Vehicle vehicle) async {
    try {
      await VehicleRepository.instance.updateVehicle(vehicle.id, vehicle);
      add(LoadVehiclesByPerson(person: vehicle.owner!));
    } catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }

  Future<void> _onDeleteVehicle(
      Emitter<VehicleState> emit, Vehicle vehicle) async {
    try {
      await VehicleRepository.instance.deleteVehicle(vehicle.id);
      add(LoadVehiclesByPerson(person: vehicle.owner!));
    } catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }

  Future<void> _onSelectVehicle(
      Emitter<VehicleState> emit, Vehicle vehicle) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedVehicleJson = prefs.getString('selectedVehicle');
    final currentState = state;

    if (currentState is VehiclesLoaded) {
      if (currentState.selectedVehicle == vehicle) {
        // Unselect the vehicle
        await prefs.remove('selectedVehicle');
        emit(VehiclesLoaded(
          vehicles: currentState.vehicles,
          selectedVehicle: null,
        ));
      } else {
        // Select the new vehicle
        final vehicleJson = json.encode(vehicle.toJson());
        await prefs.setString('selectedVehicle', vehicleJson);
        emit(VehiclesLoaded(
          vehicles: currentState.vehicles,
          selectedVehicle: vehicle,
        ));
      }
    }
  }
}
