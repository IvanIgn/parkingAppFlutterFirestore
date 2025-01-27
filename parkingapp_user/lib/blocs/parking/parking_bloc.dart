import 'package:bloc/bloc.dart';
import 'package:shared/shared.dart';
import 'package:client_repositories/async_http_repos.dart';

part 'parking_event.dart';
part 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  List<Parking> _parkingList = [];

  ParkingBloc() : super(ParkingInitial()) {
    // on<LoadParkings>((event, emit) async {
    //   await onLoadParkings(emit);
    // });

    on<LoadActiveParkings>((event, emit) async {
      await onLoadActiveParkings(emit);
    });

    on<LoadNonActiveParkings>((event, emit) async {
      await onLoadNonActiveParkings(emit);
    });

    on<DeleteParking>((event, emit) async {
      await onDeleteParking(emit, event.parking);
    });

    on<CreateParking>((event, emit) async {
      await onCreateParking(emit, event.parking);
    });

    on<UpdateParking>((event, emit) async {
      await onUpdateParking(emit, event.parking);
    });
  }

  Future<void> onLoadActiveParkings(Emitter<ParkingState> emit) async {
    emit(ParkingsLoading());
    try {
      _parkingList = await ParkingRepository.instance.getAllParkings();

      List<Parking> activeParkings = _parkingList
          .where(
            (activeParking) => (activeParking.endTime.microsecondsSinceEpoch >
                DateTime.now().microsecondsSinceEpoch),
          )
          .toList();

      emit(ActiveParkingsLoaded(parkings: activeParkings));
    } catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }

  Future<void> onLoadNonActiveParkings(Emitter<ParkingState> emit) async {
    emit(ParkingsLoading());
    try {
      _parkingList = await ParkingRepository.instance.getAllParkings();

      List<Parking> nonActiveParkings = _parkingList
          .where((parking) => parking.endTime.isBefore(DateTime.now()))
          .toList();

      emit(ParkingsLoaded(parkings: nonActiveParkings));
    } catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }

  onCreateParking(Emitter<ParkingState> emit, Parking parking) async {
    try {
      await ParkingRepository.instance.createParking(parking);

      add(LoadActiveParkings());
    } catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }

  onUpdateParking(Emitter<ParkingState> emit, Parking parking) async {
    try {
      await ParkingRepository.instance.updateParking(parking.id, parking);

      add(LoadActiveParkings());
    } catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }

  onDeleteParking(Emitter<ParkingState> emit, Parking parking) async {
    try {
      await ParkingRepository.instance.deleteParking(parking.id);

      add(LoadActiveParkings());
    } catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }
}
