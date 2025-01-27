// monitor_parkings_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:bloc/bloc.dart';
import 'package:shared/shared.dart';
import 'package:equatable/equatable.dart';

part 'parking_event.dart';
part 'parking_state.dart';

// we need to copy the style from VehicleBloc to ParkingsBloc

// class ParkingsBloc extends Bloc<MonitorParkingsEvent, MonitorParkingsState> {
//   final ParkingRepository _parkingRepository = ParkingRepository.instance;

//   ParkingsBloc() : super(MonitorParkingsInitialState()) {
//     on<LoadParkingsEvent>(_onLoadParkingsEvent);
//     on<AddParkingEvent>(_onAddParkingEvent);
//     on<EditParkingEvent>(_onEditParkingEvent);
//     on<DeleteParkingEvent>(_onDeleteParkingEvent);
//   }

//   Future<void> _onLoadParkingsEvent(
//     LoadParkingsEvent event,
//     Emitter<MonitorParkingsState> emit,
//   ) async {
//     emit(MonitorParkingsLoadingState());
//     try {
//       final parkings = await _parkingRepository.getAllParkings();
//       emit(MonitorParkingsLoadedState(parkings));
//     } catch (e) {
//       emit(MonitorParkingsErrorState(errorMessage: e.toString()));
//     }
//   }

//   Future<void> _onAddParkingEvent(
//     AddParkingEvent event,
//     Emitter<MonitorParkingsState> emit,
//   ) async {
//     try {
//       await _parkingRepository.createParking(event.parking);
//       add(LoadParkingsEvent()); // Refresh list after adding parking
//     } catch (e) {
//       emit(MonitorParkingsErrorState(errorMessage: e.toString()));
//     }
//   }

//   Future<void> _onEditParkingEvent(
//     EditParkingEvent event,
//     Emitter<MonitorParkingsState> emit,
//   ) async {
//     try {
//       await _parkingRepository.updateParking(event.parkingId, event.parking);
//       add(LoadParkingsEvent()); // Refresh list after editing parking
//     } catch (e) {
//       emit(MonitorParkingsErrorState(errorMessage: e.toString()));
//     }
//   }

//   Future<void> _onDeleteParkingEvent(
//     DeleteParkingEvent event,
//     Emitter<MonitorParkingsState> emit,
//   ) async {
//     try {
//       await _parkingRepository.deleteParking(event.parkingId);
//       add(LoadParkingsEvent()); // Refresh list after deleting parking
//     } catch (e) {
//       emit(MonitorParkingsErrorState(errorMessage: e.toString()));
//     }
//   }
// }

class ParkingsBloc extends Bloc<MonitorParkingsEvent, MonitorParkingsState> {
  final ParkingRepository parkingRepository;

  ParkingsBloc({required this.parkingRepository})
      : super(MonitorParkingsInitialState()) {
    on<LoadParkingsEvent>(_onLoadParkingsEvent);
    on<AddParkingEvent>(_onAddParkingEvent);
    on<EditParkingEvent>(_onEditParkingEvent);
    on<DeleteParkingEvent>(_onDeleteParkingEvent);
  }

  Future<void> _onLoadParkingsEvent(
    LoadParkingsEvent event,
    Emitter<MonitorParkingsState> emit,
  ) async {
    emit(MonitorParkingsLoadingState());
    try {
      final parkings = await parkingRepository.getAllParkings();
      emit(MonitorParkingsLoadedState(parkings));
    } catch (e) {
      emit(MonitorParkingsErrorState(
          'Failed to load parkings. Details: ${e.toString()}'));
    }
  }

  Future<void> _onAddParkingEvent(
    AddParkingEvent event,
    Emitter<MonitorParkingsState> emit,
  ) async {
    try {
      await parkingRepository.createParking(event.parking);
      add(LoadParkingsEvent());
    } catch (e) {
      emit(MonitorParkingsErrorState(e.toString()));
    }
  }

  Future<void> _onEditParkingEvent(
    EditParkingEvent event,
    Emitter<MonitorParkingsState> emit,
  ) async {
    try {
      await parkingRepository.updateParking(event.parkingId, event.parking);
      add(LoadParkingsEvent());
    } catch (e) {
      emit(MonitorParkingsErrorState(
          'Failed to edit parking. Details: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteParkingEvent(
    DeleteParkingEvent event,
    Emitter<MonitorParkingsState> emit,
  ) async {
    try {
      await parkingRepository.deleteParking(event.parkingId);
      add(LoadParkingsEvent());
    } catch (e) {
      emit(MonitorParkingsErrorState(
          'Failed to delete parking. Details: ${e.toString()}'));
    }
  }
}
