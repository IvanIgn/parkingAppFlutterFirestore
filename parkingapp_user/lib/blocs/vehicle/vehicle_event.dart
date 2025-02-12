// part of 'vehicle_bloc.dart';

// abstract class VehicleEvent extends Equatable {
//   const VehicleEvent();

//   @override
//   List<Object?> get props => [];
// }

// class LoadVehicles extends VehicleEvent {}

// // class LoadVehiclesByPerson extends VehicleEvent {
// //   final Person person;

// //   const LoadVehiclesByPerson({required this.person});

// //   @override
// //   List<Object> get props => [person];
// // }

// class LoadVehiclesByPerson extends VehicleEvent {
//   final String userId; // Use logged-in user's ID

//   const LoadVehiclesByPerson({required this.userId});
// }

// class CreateVehicle extends VehicleEvent {
//   final Vehicle vehicle;

//   const CreateVehicle({required this.vehicle});

//   @override
//   List<Object> get props => [vehicle];
// }

// class UpdateVehicle extends VehicleEvent {
//   final Vehicle vehicle;

//   const UpdateVehicle({required this.vehicle});

//   @override
//   List<Object> get props => [vehicle];
// }

// class DeleteVehicle extends VehicleEvent {
//   final Vehicle vehicle;

//   const DeleteVehicle({required this.vehicle});

//   @override
//   List<Object> get props => [vehicle];
// }

// class SelectVehicle extends VehicleEvent {
//   final Vehicle vehicle;

//   const SelectVehicle({required this.vehicle});

//   @override
//   List<Object> get props => [vehicle];
// }

// class DeselectVehicle extends VehicleEvent {
//   const DeselectVehicle();

//   @override
//   List<Object?> get props => [];
// }

part of 'vehicle_bloc.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class LoadVehicles extends VehicleEvent {}

class LoadVehiclesByPerson extends VehicleEvent {
  final Person person;
  final String userId;

  const LoadVehiclesByPerson(this.person, this.userId);

  @override
  List<Object> get props => [person, userId];
}

// class LoadVehiclesByPerson extends VehicleEvent {
//   final String userId; // Use logged-in user's ID

//   LoadVehiclesByPerson({required this.userId});

//   @override
//   List<Object> get props => [person];
// }

class CreateVehicle extends VehicleEvent {
  final Vehicle vehicle;

  const CreateVehicle({required this.vehicle});

  @override
  List<Object> get props => [vehicle];
}

class UpdateVehicle extends VehicleEvent {
  final Vehicle vehicle;

  const UpdateVehicle({required this.vehicle});

  @override
  List<Object> get props => [vehicle];
}

class DeleteVehicle extends VehicleEvent {
  final Vehicle vehicle;

  const DeleteVehicle({required this.vehicle});

  @override
  List<Object> get props => [vehicle];
}

class SelectVehicle extends VehicleEvent {
  final Vehicle vehicle;

  const SelectVehicle({required this.vehicle});

  @override
  List<Object> get props => [vehicle];
}

class DeselectVehicle extends VehicleEvent {
  const DeselectVehicle();

  @override
  List<Object?> get props => [];
}
