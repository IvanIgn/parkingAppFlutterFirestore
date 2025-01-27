part of 'vehicle_bloc.dart';

abstract class VehicleState {}

class VehiclesInitial extends VehicleState {}

class VehiclesLoading extends VehicleState {}

class VehiclesLoaded extends VehicleState {
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;

  VehiclesLoaded({required this.vehicles, this.selectedVehicle});
}

class VehiclesError extends VehicleState {
  final String message;

  VehiclesError({required this.message});
}
