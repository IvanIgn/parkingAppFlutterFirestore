// import 'package:bloc/bloc.dart';
// import 'package:shared/shared.dart';
// import 'package:client_repositories/async_http_repos.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:equatable/equatable.dart';

// part 'vehicle_event.dart';
// part 'vehicle_state.dart';

// class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
//   List<Vehicle> _vehicleList = [];

//   VehicleBloc() : super(VehiclesInitial()) {
//     on<LoadVehicles>((event, emit) async {
//       await _onLoadVehicles(emit);
//     });

//     on<LoadVehiclesByPerson>((event, emit) async {
//       await _onLoadVehiclesByPerson(emit, event.person);
//     });

//     on<CreateVehicle>((event, emit) async {
//       await _onCreateVehicle(emit, event.vehicle);
//     });

//     on<UpdateVehicle>((event, emit) async {
//       await _onUpdateVehicle(emit, event.vehicle);
//     });

//     on<DeleteVehicle>((event, emit) async {
//       await _onDeleteVehicle(emit, event.vehicle);
//     });

//     on<SelectVehicle>((event, emit) async {
//       await _onSelectVehicle(emit, event.vehicle);
//     });

//     on<DeselectVehicle>((event, emit) async {
//       await _onDeselectVehicle(emit);
//     });
//   }

//   Future<void> _onLoadVehicles(Emitter<VehicleState> emit) async {
//     emit(VehiclesLoading());
//     try {
//       _vehicleList = await VehicleRepository.instance.getAllVehicles();
//       emit(VehiclesLoaded(vehicles: _vehicleList));
//     } catch (e) {
//       emit(VehiclesError(message: e.toString()));
//     }
//   }

//   Future<void> _onLoadVehiclesByPerson(
//       Emitter<VehicleState> emit, Person person) async {
//     emit(VehiclesLoading());
//     try {
//       _vehicleList = await VehicleRepository.instance.getAllVehicles();
//       final vehiclesForPerson = _vehicleList
//           .where(
//               (vehicle) => vehicle.owner?.personNumber == person.personNumber)
//           .toList();
//       emit(VehiclesLoaded(vehicles: vehiclesForPerson));
//     } catch (e) {
//       emit(VehiclesError(message: e.toString()));
//     }
//   }

//   Future<void> _onCreateVehicle(
//       Emitter<VehicleState> emit, Vehicle vehicle) async {
//     try {
//       await VehicleRepository.instance.createVehicle(vehicle);
//       emit(VehicleAdded(vehicle: vehicle)); // Emit after creating
//       add(LoadVehiclesByPerson(person: vehicle.owner!));
//     } catch (e) {
//       emit(VehiclesError(message: e.toString()));
//     }
//   }

//   Future<void> _onUpdateVehicle(
//       Emitter<VehicleState> emit, Vehicle vehicle) async {
//     try {
//       await VehicleRepository.instance.updateVehicle(vehicle.id, vehicle);
//       emit(VehicleUpdated(vehicle: vehicle)); // Emit after updating
//       add(LoadVehiclesByPerson(person: vehicle.owner!));
//     } catch (e) {
//       emit(VehiclesError(message: e.toString()));
//     }
//   }

//   Future<void> _onDeleteVehicle(
//       Emitter<VehicleState> emit, Vehicle vehicle) async {
//     try {
//       await VehicleRepository.instance.deleteVehicle(vehicle.id);
//       emit(VehicleDeleted(vehicle: vehicle)); // Emit after deletion
//       add(LoadVehiclesByPerson(person: vehicle.owner!));
//     } catch (e) {
//       emit(VehiclesError(message: e.toString()));
//     }
//   }

//   Future<void> _onSelectVehicle(
//       Emitter<VehicleState> emit, Vehicle vehicle) async {
//     final prefs = await SharedPreferences.getInstance();
//     final currentState = state;

//     if (currentState is VehiclesLoaded) {
//       if (currentState.selectedVehicle == vehicle) {
//         // Unselect the vehicle
//         await prefs.remove('selectedVehicle');
//         emit(VehiclesLoaded(
//           vehicles: currentState.vehicles,
//           selectedVehicle: null,
//         ));
//       } else {
//         // Select the new vehicle
//         final vehicleJson = json.encode(vehicle.toJson());
//         await prefs.setString('selectedVehicle', vehicleJson);
//         emit(VehiclesLoaded(
//           vehicles: currentState.vehicles,
//           selectedVehicle: vehicle,
//         ));
//       }
//     }
//   }

//   Future<void> _onDeselectVehicle(Emitter<VehicleState> emit) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('selectedVehicle');

//     final currentState = state;
//     if (currentState is VehiclesLoaded) {
//       emit(VehiclesLoaded(
//         vehicles: currentState.vehicles,
//         selectedVehicle: null,
//       ));
//     }
//   }
// }

import 'package:bloc/bloc.dart';
import 'package:shared/shared.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:equatable/equatable.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  List<Vehicle> _vehicleList = [];
  final VehicleRepository repository; // Inject repository

  VehicleBloc(this.repository) : super(VehiclesInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<LoadVehiclesByPerson>(_onLoadVehiclesByPerson);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<CreateVehicle>(_onCreateVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<SelectVehicle>(_onSelectVehicle);
  }

  Future<void> _onLoadVehicles(
      LoadVehicles event, Emitter<VehicleState> emit) async {
    emit(VehiclesLoading());
    try {
      // Wait for the repository to get the vehicles
      _vehicleList = await repository.getAllVehicles();
      // Emit the loaded vehicles
      emit(VehiclesLoaded(vehicles: _vehicleList));
    } catch (e) {
      emit(VehiclesError(message: 'Failed to load vehicles: $e'));
    }
  }

  Future<void> _onLoadVehiclesByPerson(
      LoadVehiclesByPerson event, Emitter<VehicleState> emit) async {
    emit(VehiclesLoading());
    try {
      _vehicleList = await repository.getAllVehicles();
      final vehiclesForPerson = _vehicleList
          .where((vehicle) =>
              vehicle.owner?.personNumber == event.person.personNumber)
          .toList();
      emit(VehiclesLoaded(vehicles: vehiclesForPerson));
    } catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }

  // Future<void> _onCreateVehicle(
  //     CreateVehicle event, Emitter<VehicleState> emit) async {
  //   emit(VehiclesLoading());
  //   try {
  //     await repository.createVehicle(event.vehicle);
  //     final vehicles = await repository.getAllVehicles();
  //     if (vehicles != null) {
  //       emit(VehiclesLoaded(vehicles: vehicles));
  //     } else {
  //       emit(VehiclesError(message: 'Failed to add vehicles after creation'));
  //     }
  //   } catch (e) {
  //     emit(VehiclesError(message: e.toString()));
  //   }
  // }

  // Future<void> _onCreateVehicle(
  //     CreateVehicle event, Emitter<VehicleState> emit) async {
  //   emit(VehiclesLoading());
  //   try {
  //     await repository.createVehicle(event.vehicle);
  //     final vehicles = await repository.getAllVehicles();
  //     if (vehicles != null) {
  //       emit(VehiclesLoaded(vehicles: vehicles));
  //     } else {
  //       emit(VehiclesError(message: 'Failed to add vehicles after creation'));
  //     }
  //   } catch (e) {
  //     emit(VehiclesError(message: 'Failed to add vehicles after creation: $e'));
  //   }
  // }

  // Future<void> _onCreateVehicle(
  //     CreateVehicle event, Emitter<VehicleState> emit) async {
  //   try {
  //     emit(VehiclesLoading()); // Add this to match test expectation
  //     await repository.createVehicle(event.vehicle);
  //     // emit(VehicleAdded(vehicle: event.vehicle)); // Emit after creating
  //     add(LoadVehiclesByPerson(person: event.vehicle.owner!));
  //   } catch (e) {
  //     emit(VehiclesError(message: 'Failed to add vehicles after creation: $e'));
  //   }
  // }

  // Future<void> _onCreateVehicle(
  //     CreateVehicle event, Emitter<VehicleState> emit) async {
  //   try {
  //     emit(VehiclesLoading()); // Add this to match test expectation
  //     final createdVehicle = await repository.createVehicle(event.vehicle);

  //     // Check if the owner is null before proceeding
  //     if (createdVehicle.owner == null) {
  //       emit(VehiclesError(message: 'Vehicle has no owner.'));
  //       return;
  //     }

  //     add(LoadVehiclesByPerson(
  //         person: createdVehicle.owner!)); // Proceed only if owner is non-null
  //   } catch (e) {
  //     emit(VehiclesError(message: 'Failed to add vehicles after creation: $e'));
  //   }
  // }

  // Future<void> _onCreateVehicle(
  //     CreateVehicle event, Emitter<VehicleState> emit) async {
  //   try {
  //     emit(VehiclesLoading()); // Emit loading state

  //     // Create the vehicle and add it
  //     final createdVehicle = await repository.createVehicle(event.vehicle);

  //     // After creation, load the vehicles list (including new vehicle)
  //     final allVehicles = await repository.getAllVehicles();

  //     emit(VehiclesLoaded(vehicles: allVehicles));
  //   } catch (e) {
  //     emit(VehiclesError(message: 'Failed to add vehicles after creation: $e'));
  //   }
  // }

  // Future<void> _onCreateVehicle(
  //     CreateVehicle event, Emitter<VehicleState> emit) async {
  //   try {
  //     emit(VehiclesLoading()); // Emit loading state

  //     // Load the vehicles list first
  //     final allVehicles = await repository.getAllVehicles();

  //     // Check if a vehicle with the same registration number exists
  //     final vehicleExists = allVehicles.any(
  //       (vehicle) => vehicle.regNumber == event.vehicle.regNumber,
  //     );

  //     if (vehicleExists) {
  //       // If the vehicle already exists, show an error in the snackbar
  //       emit(VehiclesError(message: 'Fordon med detta reg.nummer finns redan'));
  //       return; // Exit early, no need to create the vehicle
  //     }

  //     // If no duplicate is found, create the vehicle
  //     await repository.createVehicle(event.vehicle);

  //     // After creation, load the vehicles list again (with the new vehicle)
  //     final updatedVehicles = await repository.getAllVehicles();

  //     // Emit the updated list of vehicles
  //     emit(VehiclesLoaded(vehicles: updatedVehicles));
  //   } catch (e) {
  //     emit(VehiclesError(message: 'Failed to add vehicles after creation: $e'));
  //   }
  // }

  Future<void> _onCreateVehicle(
      CreateVehicle event, Emitter<VehicleState> emit) async {
    try {
      emit(VehiclesLoading()); // Emit loading state

      // Load the vehicles list first
      final allVehicles = await repository.getAllVehicles();

      // Check if a vehicle with the same registration number exists
      final vehicleExists = allVehicles.any(
        (vehicle) => vehicle.regNumber == event.vehicle.regNumber,
      );

      if (vehicleExists) {
        // Instead of emitting an error, simply ignore and load the list again
        // You could also show the error message as a SnackBar or Toast if needed
        // Just omit the emit of VehiclesError, and re-load the vehicle list
        final updatedVehicles = await repository.getAllVehicles();
        emit(VehiclesLoaded(vehicles: updatedVehicles, selectedVehicle: null));
        return;
      }

      // If no duplicate is found, create the vehicle
      await repository.createVehicle(event.vehicle);

      // After creation, load the vehicles list again (with the new vehicle)
      final updatedVehicles = await repository.getAllVehicles();

      // Emit the updated list of vehicles
      emit(VehiclesLoaded(vehicles: updatedVehicles, selectedVehicle: null));
    } catch (e) {
      emit(VehiclesError(message: 'Failed to add vehicles after creation: $e'));
    }
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehiclesLoading()); // Emit loading state

    try {
      // Load all vehicles first to check for duplicate regNumber
      final allVehicles = await repository.getAllVehicles();

      // Check if a vehicle with the same registration number exists
      final vehicleExists = allVehicles.any(
        (vehicle) =>
            vehicle.regNumber == event.vehicle.regNumber &&
            vehicle.id != event.vehicle.id,
      );

      if (vehicleExists) {
        // If a vehicle with the same regNumber exists, show an error in the form
        emit(VehiclesError(message: 'Fordon med detta reg.nummer finns redan'));
        return; // Exit early if there's a duplicate registration number
      }

      // Proceed with updating the vehicle if no duplicates are found
      await repository.updateVehicle(event.vehicle.id, event.vehicle);

      // Load the updated list of vehicles (this should return the updated list)
      final updatedVehicles = await repository.getAllVehicles();

      // Emit the updated vehicle and the updated vehicle list
      emit(VehicleUpdated(vehicle: event.vehicle)); // Emit vehicle updated
      emit(VehiclesLoaded(vehicles: updatedVehicles)); // Emit loaded vehicles
    } catch (error) {
      emit(VehiclesError(message: 'Failed to update vehicle: $error'));
    }
  }

  // Future<void> _onDeleteVehicle(
  //     DeleteVehicle event, Emitter<VehicleState> emit) async {
  //   try {
  //     await repository.deleteVehicle(event.vehicle.id);
  //     add(LoadVehiclesByPerson(person: event.vehicle.owner!));
  //   } catch (e) {
  //     emit(VehiclesError(message: 'Failed to delete vehicle: $e'));
  //   }
  // }

  Future<void> _onDeleteVehicle(
      DeleteVehicle event, Emitter<VehicleState> emit) async {
    try {
      emit(VehiclesLoading()); // Emit loading state

      // Attempt to delete the vehicle
      await repository.deleteVehicle(event.vehicle.id);

      // Get the updated list of vehicles (could be empty)
      final updatedVehicles = await repository.getAllVehicles();

      // After successful deletion, emit the VehicleDeleted state
      emit(VehicleDeleted(vehicle: event.vehicle));

      // Emit the updated list of vehicles (which will be empty if no vehicles exist)
      emit(VehiclesLoaded(vehicles: updatedVehicles, selectedVehicle: null));
    } catch (e) {
      // If an error occurs during deletion, emit an error state
      emit(VehiclesError(
        message: 'Failed to delete vehicle: ${e.toString()}',
      ));
    }
  }

  // Future<void> _onSelectVehicle(
  //     SelectVehicle event, Emitter<VehicleState> emit) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final currentState = state;

  //   if (currentState is VehiclesLoaded) {
  //     final isSameVehicle = currentState.selectedVehicle == event.vehicle;
  //     if (isSameVehicle) {
  //       await prefs.remove('selectedVehicle');
  //       emit(VehiclesLoaded(
  //           vehicles: currentState.vehicles, selectedVehicle: null));
  //     } else {
  //       final vehicleJson = json.encode(event.vehicle.toJson());
  //       await prefs.setString('selectedVehicle', vehicleJson);
  //       emit(VehiclesLoaded(
  //           vehicles: currentState.vehicles, selectedVehicle: event.vehicle));
  //     }
  //   }
  // }

  Future<void> _onSelectVehicle(
      SelectVehicle event, Emitter<VehicleState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final currentState = state;

    if (currentState is VehiclesLoaded) {
      final isSameVehicle =
          currentState.selectedVehicle?.id == event.vehicle.id;

      if (isSameVehicle) {
        // Deselect the vehicle (remove from shared preferences)
        await prefs.remove('selectedVehicle');
        emit(VehiclesLoaded(
            vehicles: currentState.vehicles, selectedVehicle: null));
      } else {
        // Find the full vehicle object with owner details
        final selectedVehicle = currentState.vehicles.firstWhere(
            (vehicle) => vehicle.id == event.vehicle.id,
            orElse: () => event.vehicle);

        // Store the selected vehicle in shared preferences
        final vehicleJson = json.encode(selectedVehicle.toJson());
        await prefs.setString('selectedVehicle', vehicleJson);
        emit(VehiclesLoaded(
            vehicles: currentState.vehicles, selectedVehicle: selectedVehicle));
      }
    }
  }
}
