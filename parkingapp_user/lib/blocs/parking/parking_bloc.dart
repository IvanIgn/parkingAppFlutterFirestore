import 'package:bloc/bloc.dart';
import 'package:shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:clock/clock.dart';
import 'dart:convert';

part 'parking_event.dart';
part 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;
  final SharedPreferences sharedPreferences;
  List<Parking> _parkingList = [];
  final List<Person> _personList = [];

  ParkingBloc(
      {required this.parkingRepository, required this.sharedPreferences})
      : super(ParkingsInitial()) {
    on<LoadParkings>((event, emit) async {
      await onLoadParkings(emit);
    });

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

  // Future<void> onLoadActiveParkings(Emitter<ParkingState> emit) async {
  //   emit(ParkingsLoading());
  //   try {
  //     List<Parking> activeParkings = _parkingList
  //         .where(
  //           (activeParking) => (activeParking.endTime.microsecondsSinceEpoch >
  //               DateTime.now().microsecondsSinceEpoch),
  //         )
  //         .toList();

  //     emit(ActiveParkingsLoaded(parkings: activeParkings));
  //   } catch (e) {
  //     emit(ParkingsError(message: e.toString()));
  //   }
  // }

  Future<void> onLoadActiveParkings(Emitter<ParkingState> emit) async {
    emit(ParkingsLoading());
    try {
      // Retrieve logged-in user's ID from SharedPreferences
      final loggedInPersonJson = sharedPreferences.getString('loggedInPerson');

      if (loggedInPersonJson == null) {
        throw Exception("Failed to load active parkings");
      }

      final loggedInPersonMap =
          json.decode(loggedInPersonJson) as Map<String, dynamic>;
      final loggedInUserId = loggedInPersonMap['id'];

      // Fetch all parkings from repository
      _parkingList = await parkingRepository.getAllParkings();

      // Filter only active parkings added by the logged-in user
      List<Parking> activeParkings = _parkingList
          .where(
            (parking) =>
                parking.vehicle?.owner?.id ==
                    loggedInUserId && // Filter by logged-in user
                parking.endTime.isAfter(
                    DateTime.now()), // Check if parking is still active
          )
          .toList();

      emit(ActiveParkingsLoaded(parkings: activeParkings));
    } catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }

  Future<void> onLoadParkings(Emitter<ParkingState> emit) async {
    emit(ParkingsLoading());
    try {
      _parkingList = await parkingRepository.getAllParkings();
      emit(ParkingsLoaded(parkings: _parkingList));
    } catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }

  // Future<void> onLoadActiveParkings(Emitter<ParkingState> emit) async {
  //   emit(ParkingsLoading());
  //   try {
  //     // Retrieve logged-in user's ID from SharedPreferences
  //     final prefs = await SharedPreferences.getInstance();
  //     final loggedInPersonJson = prefs.getString('loggedInPerson');

  //     if (loggedInPersonJson == null) {
  //       throw Exception("No logged-in user found.");
  //     }

  //     final loggedInPersonMap =
  //         json.decode(loggedInPersonJson) as Map<String, dynamic>;
  //     final loggedInUserId = loggedInPersonMap['id'];

  //     // Fetch all parkings from repository
  //     _parkingList = await parkingRepository.getAllParkings();

  //     // Filter only active parkings added by the logged-in user
  //     List<Parking> activeParkings = _parkingList
  //         .where(
  //           (parking) =>
  //               parking.vehicle?.owner?.id ==
  //                   loggedInUserId && // Filter by logged-in user
  //               parking.endTime.isAfter(
  //                   DateTime.now()), // Check if parking is still active
  //         )
  //         .toList();

  //     emit(ActiveParkingsLoaded(parkings: activeParkings));
  //   } catch (e) {
  //     emit(ParkingsError(message: e.toString()));
  //   }
  // }

  // Future<void> onLoadParkings() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   try {
  //     // Load saved parking JSON from SharedPreferences
  //     final parkingJson = prefs.getString('parking');
  //     if (parkingJson != null) {
  //       Parking parkingInstance = Parking.fromJson(json.decode(parkingJson));
  //       setState(() {});
  //     } else {
  //       print('No parking data found in SharedPreferences.');
  //     }
  //   } catch (e) {
  //     print('Error loading parking data: $e');
  //   }
  // }

  // Future<void> onLoadParkingByPerson(Emitter<ParkingState> emit) async {
  //   emit(ParkingsLoading());
  //   try {
  //     _parkingList = await parkingRepository.getAllParkings();
  //     _personList = await PersonRepository.instance.getAllPersons();

  //     // TODO: Implement logic to filter parkings by person
  //     List<Parking> activeParkings = _parkingList
  //         .where(
  //           (activeParking) => (activeParking.endTime.microsecondsSinceEpoch >
  //               DateTime.now().microsecondsSinceEpoch),
  //         )
  //         .toList();

  //     activeParkings = activeParkings
  //         .where((parking) =>
  //             parking.vehicle != null &&
  //             parking.vehicle!.owner != null &&
  //             _personList
  //                 .any((person) => person.id == parking.vehicle!.owner!.id))
  //         .toList();

  //     //activeParkings.sort((a, b) => a.endTime.compareTo(b.endTime));
  //     emit(ActiveParkingsLoaded(parkings: activeParkings));
  //   } catch (e) {
  //     emit(ParkingsError(message: e.toString()));
  //   }
  // }

  // Future<void> onLoadNonActiveParkings(Emitter<ParkingState> emit) async {
  //   emit(ParkingsLoading());
  //   try {
  //     _parkingList = await parkingRepository.getAllParkings();

  //     List<Parking> nonActiveParkings = _parkingList
  //         .where((parking) => parking.endTime.isBefore(DateTime.now()))
  //         .toList();

  //     emit(ParkingsLoaded(parkings: nonActiveParkings));
  //   } catch (e) {
  //     emit(ParkingsError(message: e.toString()));
  //   }
  // }

  Future<void> onLoadNonActiveParkings(Emitter<ParkingState> emit) async {
    emit(ParkingsLoading());
    try {
      _parkingList = await parkingRepository.getAllParkings();

      List<Parking> nonActiveParkings = _parkingList
          .where((parking) => parking.endTime.isBefore(clock.now()))
          .toList();

      emit(ParkingsLoaded(parkings: nonActiveParkings));
    } catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }

  onCreateParking(Emitter<ParkingState> emit, Parking parking) async {
    emit(ParkingsLoading()); // Emit loading state
    try {
      // emit(ParkingsLoading());
      await parkingRepository.createParking(parking);

      // Fetch all parkings from the repository
      final allParkings = await parkingRepository.getAllParkings();

      // Filter active parkings
      final activeParkings =
          allParkings.where((p) => p.endTime.isAfter(DateTime.now())).toList();

      // Emit loaded state with active parkings
      emit(ActiveParkingsLoaded(parkings: activeParkings));
    } catch (e) {
      // Emit an error state if something goes wrong
      emit(ParkingsError(message: e.toString()));
    }
  }

  // onCreateParking(Emitter<ParkingState> emit, Parking parking) async {
  //   try {
  //     emit(ParkingsLoading());

  //     await parkingRepository.createParking(parking);

  //     final activeParkings = await parkingRepository.getAllParkings();

  //     emit(ActiveParkingsLoaded(
  //       parkings: activeParkings
  //           .where((p) => p.endTime.isAfter(DateTime.now()))
  //           .toList(),
  //     ));
  //   } catch (e) {
  //     emit(ParkingsError(message: e.toString()));
  //   }
  // }

  onUpdateParking(Emitter<ParkingState> emit, Parking parking) async {
    try {
      await parkingRepository.updateParking(parking.id, parking);
      add(LoadActiveParkings());
    } catch (e) {
      // Modify error message to match the expected format
      emit(ParkingsError(
          message: 'Failed to edit parking. Details: ${e.toString()}'));
    }
  }

  // onDeleteParking(Emitter<ParkingState> emit, Parking parking) async {
  //   try {
  //     await parkingRepository.deleteParking(parking.id);

  //     add(LoadActiveParkings());
  //   } catch (e) {
  //     emit(ParkingsError(message: e.toString()));
  //   }
  // }

  // onDeleteParking(Emitter<ParkingState> emit, Parking parking) async {
  //   try {
  //     emit(ParkingsLoading()); // Emit loading state first

  //     await parkingRepository.deleteParking(parking.id);

  //     // After successful deletion, emit the loaded state with updated list of parkings
  //     final allParkings = await parkingRepository.getAllParkings();
  //     emit(ParkingsLoaded(parkings: allParkings));
  //   } catch (e) {
  //     emit(ParkingsError(
  //         message: 'Failed to delete parking. Details: ${e.toString()}'));
  //   }
  // }

  onDeleteParking(Emitter<ParkingState> emit, Parking parking) async {
    try {
      // Try to delete parking
      await parkingRepository.deleteParking(parking.id);

      // Emit loading state only if the delete operation is successful
      emit(ParkingsLoading());

      // After successful deletion, fetch the updated list of parkings
      final allParkings = await parkingRepository.getAllParkings();
      emit(ParkingsLoaded(parkings: allParkings));
    } catch (e) {
      // If an error occurs, directly emit the error state without loading state
      emit(ParkingsError(
          message: 'Failed to delete parking. Details: ${e.toString()}'));
    }
  }
}
