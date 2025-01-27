part of 'parking_space_bloc.dart';

abstract class ParkingSpaceEvent {}

class LoadParkingSpaces extends ParkingSpaceEvent {}

class SelectParkingSpace extends ParkingSpaceEvent {
  final ParkingSpace parkingSpace;
  SelectParkingSpace(this.parkingSpace);
}

class StartParking extends ParkingSpaceEvent {}

class StopParking extends ParkingSpaceEvent {}

class DeselectParkingSpace extends ParkingSpaceEvent {
  //final ParkingSpace parkingSpace;
  // DeselectParkingSpace(this.parkingSpace);
}

// class CreateParkingSpace extends ParkingSpaceEvent {
//   final ParkingSpace parkingSpace;

//   CreateParkingSpace({required this.parkingSpace});
// }

// class UpdateParkingSpace extends ParkingSpaceEvent {
//   final ParkingSpace parkingSpace;

//   UpdateParkingSpace({required this.parkingSpace});
// }

// class DeleteParkingSpace extends ParkingSpaceEvent {
//   final ParkingSpace parkingSpace;

//   DeleteParkingSpace({required this.parkingSpace});
// }

// class SelectParkingSpace extends ParkingSpaceEvent {
//   final ParkingSpace parkingSpace;

//   SelectParkingSpace({required this.parkingSpace});
// }

// class ClearSelectedParkingSpace extends ParkingSpaceEvent {}

// class ToggleParkingState extends ParkingSpaceEvent {}

// class StartParking extends ParkingSpaceEvent {}

// class StopParking extends ParkingSpaceEvent {}
