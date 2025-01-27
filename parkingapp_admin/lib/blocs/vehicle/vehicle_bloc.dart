import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository vehicleRepository;

  VehicleBloc(this.vehicleRepository) : super(VehicleInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<AddVehicle>(_onAddVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
  }

  Future<void> _onLoadVehicles(
    LoadVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      final vehicles = await vehicleRepository.getAllVehicles();
      emit(VehicleLoaded(vehicles));
    } catch (error) {
      emit(VehicleError('Failed to load vehicles: $error'));
    }
  }

  // void _onAddVehicle(AddVehicle event, Emitter<VehicleState> emit) async {
  //   try {
  //     final newVehicle = event.vehicle;
  //     print("Adding vehicle: $newVehicle");
  //     await vehicleRepository.createVehicle(newVehicle);
  //     final allVehicles = await vehicleRepository.getAllVehicles();
  //     print("All vehicles after addition: $allVehicles");
  //     emit(VehicleLoaded(allVehicles));
  //   } catch (e) {
  //     print("Error adding vehicle: $e");
  //     emit(VehicleError('Error adding vehicle: $e'));
  //   }
  // }

  // void _onAddVehicle(AddVehicle event, Emitter<VehicleState> emit) async {
  //   try {
  //     // Emit the loading state first
  //     emit(VehicleLoading());

  //     final newVehicle = event.vehicle;
  //     print("Adding vehicle: $newVehicle");

  //     // Create the vehicle and fetch the updated list of vehicles
  //     await vehicleRepository.createVehicle(newVehicle);
  //     final allVehicles = await vehicleRepository.getAllVehicles();

  //     print("All vehicles after addition: $allVehicles");

  //     // Emit the updated list of vehicles
  //     emit(VehicleLoaded(allVehicles));
  //   } catch (e) {
  //     print("Error adding vehicle: $e");
  //     emit(VehicleError('Error adding vehicle: $e'));
  //   }
  // }

  void _onAddVehicle(AddVehicle event, Emitter<VehicleState> emit) async {
    // First, emit the loading state
    emit(VehicleLoading());

    try {
      final newVehicle = event.vehicle;
      print("Adding vehicle: $newVehicle");

      // Simulate adding the vehicle
      await vehicleRepository.createVehicle(newVehicle);

      // Fetch the updated list after adding the vehicle
      final allVehicles = await vehicleRepository.getAllVehicles();
      print("All vehicles after addition: $allVehicles");

      // Emit the loaded state with the updated list
      emit(VehicleLoaded(allVehicles));
    } catch (e) {
      // In case of an error, print it and emit the error state
      print("Error adding vehicle: $e");
      emit(VehicleError('Failed to add vehicle: $e'));
    }
  }

  // Future<void> _onUpdateVehicle(
  //   UpdateVehicle event,
  //   Emitter<VehicleState> emit,
  // ) async {
  //   if (state is VehicleLoaded) {
  //     final currentState = state as VehicleLoaded;
  //     try {
  //       await vehicleRepository.updateVehicle(event.vehicle.id, event.vehicle);
  //       final updatedVehicles =
  //           await vehicleRepository.getAllVehicles(); // Refresh list
  //       emit(VehicleLoaded(updatedVehicles));
  //     } catch (error) {
  //       emit(VehicleError('Failed to update vehicle: $error'));
  //     }
  //   }
  // }

  // Future<void> _onUpdateVehicle(
  //   UpdateVehicle event,
  //   Emitter<VehicleState> emit,
  // ) async {
  //   if (state is VehicleLoaded) {
  //     final currentState = state as VehicleLoaded;
  //     try {
  //       // Update the vehicle in the repository
  //       await vehicleRepository.updateVehicle(event.vehicle.id, event.vehicle);

  //       // After updating, fetch the updated list of vehicles
  //       final updatedVehicles = await vehicleRepository.getAllVehicles();

  //       // Emit the VehicleLoaded state with the updated list
  //       emit(VehicleLoaded(updatedVehicles));
  //     } catch (error) {
  //       emit(VehicleError('Failed to update vehicle: $error'));
  //     }
  //   }
  // }
  Future<void> _onUpdateVehicle(
    UpdateVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      await vehicleRepository.updateVehicle(event.vehicle.id, event.vehicle);
      final updatedVehicles = await vehicleRepository.getAllVehicles();
      emit(VehicleUpdated());
      emit(VehicleLoaded(updatedVehicles));
    } catch (error) {
      emit(VehicleError('Error updating vehicle: $error'));
    }
  }

  // Future<void> _onDeleteVehicle(
  //   DeleteVehicle event,
  //   Emitter<VehicleState> emit,
  // ) async {
  //   if (state is VehicleLoaded) {
  //     try {
  //       await vehicleRepository.deleteVehicle(event.vehicleId);
  //       final updatedVehicles = await vehicleRepository.getAllVehicles();
  //       emit(VehicleLoaded(updatedVehicles));
  //     } catch (error) {
  //       // Ensure that we properly emit the error state
  //       emit(VehicleError('Failed to delete vehicle: $error'));
  //     }
  //   }
  // }

  Future<void> _onDeleteVehicle(
    DeleteVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading()); // Emit loading state

    try {
      await vehicleRepository.deleteVehicle(event.vehicleId); // Call delete
      emit(VehicleDeleted()); // Emit deleted state
      final updatedVehicles =
          await vehicleRepository.getAllVehicles(); // Fetch updated list
      emit(VehicleLoaded(updatedVehicles)); // Emit updated state
    } catch (error) {
      emit(VehicleError('Failed to delete vehicle: $error')); // Handle errors
    }
  }
}
