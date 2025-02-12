import 'package:shared/shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VehicleRepository {
  static final VehicleRepository _instance = VehicleRepository._internal();
  static VehicleRepository get instance => _instance;
  VehicleRepository._internal();

  final db = FirebaseFirestore.instance; // Initialize FirebaseFirestore
  final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize FirebaseAuth

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

  // Future<List<Vehicle>> getVehiclesForLoggedInUserByID() async {
  //   try {
  //     final currentUser =
  //         _auth.currentUser; // Get the current user (Firebase Auth)

  //     if (currentUser == null) {
  //       throw Exception('User not logged in');
  //     }

  //     // Query vehicles where the 'owner' field matches the logged-in user's ID (or personNumber)
  //     final querySnapshot = await db
  //         .collection('vehicles')
  //         .where('owner.id', isEqualTo: currentUser.uid) // or use personNumber
  //         .get();

  //     // Convert the query snapshot into a list of Vehicle objects
  //     return querySnapshot.docs.map((doc) {
  //       return Vehicle.fromJson(doc.data()); // assuming fromJson method exists
  //     }).toList();
  //   } catch (e) {
  //     throw Exception('Failed to load vehicles: $e');
  //   }
  // }

  Future<List<Vehicle>> getVehiclesForUser(String userId) async {
    try {
      final querySnapshot = await db
          .collection('vehicles')
          .where('owner.authId',
              isEqualTo: userId) // Match with logged-in user ID
          .get();

      return querySnapshot.docs.map((doc) {
        return Vehicle.fromJson(doc.data());
      }).toList();
    } catch (e) {
      throw Exception('Failed to load vehicles: $e');
    }
  }

  // Future<List<Vehicle>> getAllVehicles() async {
  //   final snapshots = await db.collection("vehicles").get();

  //   final docs = snapshots.docs;

  //   final jsons = docs.map((doc) {
  //     final json = doc.data();
  //     json["id"] = doc.id;

  //     return json;
  //   }).toList();

  //   return jsons.map((json) => Vehicle.fromJson(json)).toList();
  // }

  Future<List<Vehicle>> getAllVehicles() async {
    try {
      final querySnapshot = await db.collection('vehicles').get();
      return querySnapshot.docs
          .map((doc) => Vehicle.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching vehicles: $e');
    }
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
