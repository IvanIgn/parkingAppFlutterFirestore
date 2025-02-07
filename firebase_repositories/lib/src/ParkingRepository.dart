import 'package:shared/shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingRepository {
  static final ParkingRepository _instance = ParkingRepository._internal();
  static ParkingRepository get instance => _instance;
  ParkingRepository._internal();

  final db = FirebaseFirestore.instance; // Initialize FirebaseFirestore

  Future<Parking> createParking(Parking parking) async {
    // await Future.delayed(Duration(seconds: 2));

    if (parking.id.isEmpty) {
      throw Exception("Fel: parking.id ska inte vara tom!");
    }

    await db.collection("parkings").doc(parking.id).set(parking.toJson());

    return parking;
  }

  Future<Parking> getParkingById(String id) async {
    final snapshot = await db.collection("parkings").doc(id).get();

    final json = snapshot.data();

    if (json == null) {
      throw Exception("Parking with id $id not found");
    }

    json["id"] = snapshot.id;

    return Parking.fromJson(json);
  }

  Future<List<Parking>> getAllParkings() async {
    final snapshots = await db.collection("parkings").get();

    final docs = snapshots.docs;

    final jsons = docs.map((doc) {
      final json = doc.data();
      json["id"] = doc.id;

      return json;
    }).toList();

    return jsons.map((json) => Parking.fromJson(json)).toList();
  }

  Future<Parking> deleteParking(String id) async {
    final vehicle = await getParkingById(id);

    await db.collection("parkings").doc(id).delete();

    return vehicle;
  }

  Future<Parking> updateParking(String id, Parking parking) async {
    await db.collection("parkings").doc(parking.id).set(parking.toJson());

    return parking;
  }
}
