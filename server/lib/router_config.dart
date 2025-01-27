import 'package:server/handlers/person_handlers.dart';
import 'package:server/handlers/parking_handlers.dart';
import 'package:server/handlers/parkingSpace_handlers.dart';
import 'package:server/handlers/vehicle_handlers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shared/cli_server_stuff.dart';

class ServerConfig {
  // singleton constructor

  ServerConfig._privateConstructor() {
    initializer();
  }

  static final ServerConfig _instance = ServerConfig._privateConstructor();

  static ServerConfig get instance => _instance;

  late Store store;

  late Router router;

  initializer() {
    // Configure routes.
    router = Router();

    store = openStore();

    // Persons routes
    router.get('/persons', getAllPersonsHandler);
    router.get('/persons/<id>', getPersonByIdHandler);
    router.post('/persons', createPersonHandler);
    router.put('/persons/<id>', updatePersonHandler);
    router.delete('/persons/<id>', deletePersonHandler);

    // Vehicles routes
    router.get('/vehicles', getAllVehiclesHandler);
    router.get('/vehicles/<id>', getVehicleByIdHandler);
    router.post('/vehicles', createVehicleHandler);
    router.put('/vehicles/<id>', updateVehicleHandler);
    router.delete('/vehicles/<id>', deleteVehicleHandler);

    // Parking spaces routes
    router.get('/parkingspaces', getAllParkingSpacesHandler);
    router.get('/parkingspaces/<id>',
        getParkingSpaceByIdHandler); // maybe with lower case parkingspaces
    router.post('/parkingspaces', createParkingSpaceHandler);
    router.put('/parkingspaces/<id>', updateParkingSpaceHandler);
    router.delete('/parkingspaces/<id>', deleteParkingSpaceHandler);

    // Parkings routes
    router.get('/parkings', getAllParkingsHandler);
    router.get('/parkings/<id>', getParkingByIdHandler);
    router.post('/parkings', createParkingHandler);
    router.put('/parkings/<id>', updateParkingHandler);
    router.delete('/parkings/<id>', deleteParkingHandler);
  }
}
