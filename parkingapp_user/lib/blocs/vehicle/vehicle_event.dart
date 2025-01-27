part of 'vehicle_bloc.dart';

abstract class VehicleEvent {}

class LoadVehicles extends VehicleEvent {}

class LoadVehiclesByPerson extends VehicleEvent {
  final Person person;

  LoadVehiclesByPerson({required this.person});
}

class CreateVehicle extends VehicleEvent {
  final Vehicle vehicle;

  CreateVehicle({required this.vehicle});
}

class UpdateVehicles extends VehicleEvent {
  final Vehicle vehicle;

  UpdateVehicles({required this.vehicle});
}

class DeleteVehicles extends VehicleEvent {
  final Vehicle vehicle;

  DeleteVehicles({required this.vehicle});
}

class SelectVehicle extends VehicleEvent {
  final Vehicle vehicle;

  SelectVehicle({required this.vehicle});
}
