import 'package:server/router_config.dart';
import 'package:shared/only_import_on_storage_device.dart';
import 'package:shared/shared.dart';

class ParkingSpaceRepository {
  // final String baseUrl = 'http://localhost:8080'; // Serverns URL

  // Singleton-instans av ParkingSpaceRepository

  static final ParkingSpaceRepository instance = ParkingSpaceRepository._();

  ParkingSpaceRepository._();

  final Box<ParkingSpace> parkingSpaceBox =
      ServerConfig.instance.store.box<ParkingSpace>();

  Future<ParkingSpace?> add(ParkingSpace parkingSpace) async {
    parkingSpaceBox.put(parkingSpace, mode: PutMode.insert);

    // above command did not error
    return parkingSpace;
  }

  Future<ParkingSpace?> getById(int id) async {
    return parkingSpaceBox.get(id);
  }

  Future<List<ParkingSpace>?> getAll() async {
    return parkingSpaceBox.getAll();
  }

  Future<ParkingSpace?> update(int id, ParkingSpace newParkingSpace) async {
    parkingSpaceBox.put(newParkingSpace, mode: PutMode.update);
    return newParkingSpace;
  }

  Future<ParkingSpace?> delete(int id) async {
    ParkingSpace? parkingSpace = parkingSpaceBox.get(id);

    if (parkingSpace != null) {
      parkingSpaceBox.remove(id);
    }

    return parkingSpace;
  }
}
