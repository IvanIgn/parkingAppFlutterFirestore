import 'package:shared/shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleRepository {
  static final VehicleRepository _instance = VehicleRepository._internal();
  static VehicleRepository get instance => _instance;
  VehicleRepository._internal();

  final db = FirebaseFirestore.instance; // Initialize FirebaseFirestore

  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    //await Future.delayed(Duration(seconds: 5));

    await db.collection("vehicles").doc(vehicle.id).set(vehicle.toJson());

    return vehicle;
  }

  Future<Vehicle> getVehicleById(String id) async {
    final snapshot = await db.collection("vehicles").doc(id).get();

    final json = snapshot.data();

    if (json == null) {
      throw Exception("Vehicle with id $id not found");
    }

    json["id"] = snapshot.id;

    return Vehicle.fromJson(json);
  }

  Future<List<Vehicle>> getAllVehicles() async {
    final snapshots = await db.collection("vehicles").get();

    final docs = snapshots.docs;

    final jsons = docs.map((doc) {
      final json = doc.data();
      json["id"] = doc.id;

      return json;
    }).toList();

    return jsons.map((json) => Vehicle.fromJson(json)).toList();
  }

  Future<Vehicle> deleteVehicle(String id) async {
    final vehicle = await getVehicleById(id);

    await db.collection("vehicles").doc(id).delete();

    return vehicle;
  }

  Future<Vehicle> updateVehicle(String id, Vehicle vehicle) async {
    await db.collection("vehicles").doc(vehicle.id).set(vehicle.toJson());

    return vehicle;
  }
}
