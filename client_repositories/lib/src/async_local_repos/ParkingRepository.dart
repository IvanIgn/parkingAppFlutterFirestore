//import '../models/Parking.dart' as server_parking;
//import 'package:objectbox/objectbox.dart';
//import 'package:cli_server/router_config.dart';

import 'package:server/router_config.dart';
import 'package:shared/cli_server_stuff.dart';
//import 'package:cli_shared/cli_shared.dart' as shared;

class ParkingRepository {
  static final ParkingRepository instance = ParkingRepository._();

  ParkingRepository._();

  Box<Parking> parkingBox = ServerConfig.instance.store.box<Parking>();

  Future<Parking?> add(Parking parking) async {
    parkingBox.put(parking, mode: PutMode.insert);

    // above command did not error
    return parking;
  }

  Future<Parking?> getById(int id) async {
    return parkingBox.get(id);
  }

  Future<List<Parking>?> getAll() async {
    return parkingBox.getAll();
  }

  Future<Parking> update(int id, Parking newParking) async {
    parkingBox.put(newParking, mode: PutMode.update);
    return newParking;
  }

  Future<Parking?> delete(int id) async {
    Parking? parking = parkingBox.get(id);

    if (parking != null) {
      parkingBox.remove(id);
    }

    return parking;
  }
}
