part of 'parking_bloc.dart';

sealed class ParkingEvent {}

class LoadParkings extends ParkingEvent {}

class LoadActiveParkings extends ParkingEvent {}

class LoadNonActiveParkings extends ParkingEvent {}

class CreateParking extends ParkingEvent {
  final Parking parking;

  CreateParking({required this.parking});
}

class UpdateParking extends ParkingEvent {
  final Parking parking;

  UpdateParking({required this.parking});
}

class DeleteParking extends ParkingEvent {
  final Parking parking;

  DeleteParking({required this.parking});
}
