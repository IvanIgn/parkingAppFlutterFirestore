//import 'package:objectbox/objectbox.dart';
//import '../models/Vehicle.dart';
//import 'package:cli_server/router_config.dart';

import 'package:server/router_config.dart';
import 'package:shared/cli_server_stuff.dart';

class VehicleRepository {
  static final VehicleRepository instance = VehicleRepository._();
  VehicleRepository._();

  // Инициализируем Box<Vehicle> через конфигурацию сервера
  final Box<Vehicle> vehicleBox = ServerConfig.instance.store.box<Vehicle>();

  // Future<Vehicle?> add(Vehicle vehicle) async {
  //   vehicleBox.put(vehicle, mode: PutMode.insert);

  //   // above command did not error
  //   return vehicle;
  // }

  // Future<Vehicle> add(Vehicle vehicle) async {
  //   vehicleBox.put(vehicle, mode: PutMode.insert);
  //   return vehicle; // Always return a valid Vehicle, not null
  // }

  // Future<Vehicle> add(Vehicle vehicle) async {
  //   try {
  //     vehicleBox.put(vehicle, mode: PutMode.insert);
  //     return vehicle; // Make sure this never returns null
  //   } catch (e) {
  //     // Handle any potential error and ensure that the return type matches
  //     throw Exception('Error adding vehicle: $e');
  //   }
  // }

  Future<Vehicle?> add(Vehicle vehicle) async {
    vehicleBox.put(vehicle, mode: PutMode.insert);
    return vehicle; // Ensure this is returning the correct vehicle after adding it.
  }

  Future<Vehicle?> getById(int id) async {
    return vehicleBox.get(id);
  }

  Future<List<Vehicle>?> getAll() async {
    return vehicleBox.getAll();
  }

  Future<Vehicle> update(int id, Vehicle newVehicle) async {
    vehicleBox.put(newVehicle, mode: PutMode.update);
    return newVehicle;
  }

  Future<Vehicle?> delete(int id) async {
    Vehicle? vehicle = vehicleBox.get(id);

    if (vehicle != null) {
      vehicleBox.remove(id);
    }

    return vehicle;
  }
}
