// parking_event.dart

part of 'parking_bloc.dart';

abstract class MonitorParkingsEvent {}

class LoadParkingsEvent extends MonitorParkingsEvent {}

class AddParkingEvent extends MonitorParkingsEvent {
  final Parking parking;

  AddParkingEvent(this.parking);
}

class EditParkingEvent extends MonitorParkingsEvent {
  final int parkingId;
  final Parking parking;

  EditParkingEvent({required this.parkingId, required this.parking});
}

class DeleteParkingEvent extends MonitorParkingsEvent {
  final int parkingId;

  DeleteParkingEvent(this.parkingId);
}
