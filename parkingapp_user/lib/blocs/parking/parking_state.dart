part of 'parking_bloc.dart';

sealed class ParkingState {}

class ParkingInitial extends ParkingState {
  List<Object?> get parkings => [];
}

class ParkingsLoading extends ParkingState {
  List<Object?> get parkings => [];
}

class ParkingsLoaded extends ParkingState {
  final List<Parking> parkings;

  ParkingsLoaded({required this.parkings});
}

class ParkingsError extends ParkingState {
  final String message;

  ParkingsError({required this.message});

  List<Object?> get props => [message];
}

class ActiveParkingsLoaded extends ParkingState {
  final List<Parking> parkings;

  ActiveParkingsLoaded({required this.parkings});
}
