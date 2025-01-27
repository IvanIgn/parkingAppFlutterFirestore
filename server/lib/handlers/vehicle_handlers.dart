import 'dart:convert';
import 'package:server/repositories/vehicleRepository.dart';
import 'package:shared/shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

final VehicleRepository vehicleRepo = VehicleRepository.instance;

/// GET /vehicles
Future<Response> getAllVehiclesHandler(Request request) async {
  final vehicles = await vehicleRepo.getAll();
  final payload = vehicles?.map((v) => (v).toJson()).toList();

  return Response.ok(
    jsonEncode(payload),
    headers: {'Content-Type': 'application/json'},
  );
}

/// POST /vehicles
Future<Response> createVehicleHandler(Request request) async {
  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final vehicle = Vehicle.fromJson(data);

    final createdVehicle = await vehicleRepo.add(vehicle);

    return Response.ok(
      jsonEncode(createdVehicle?.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.badRequest(body: 'Error: ${e.toString()}');
  }
}

/// GET /vehicles/<id>
Future<Response> getVehicleByIdHandler(Request request) async {
  final idStr = request.params["id"];

  if (idStr != null) {
    final id = int.tryParse(idStr);

    if (id != null) {
      final vehicle = await vehicleRepo.getById(id);
      if (vehicle != null) {
        return Response.ok(
          jsonEncode(vehicle.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound('Fordon med ID $id hittades inte.');
      }
    }
  }

  return Response.badRequest(body: 'Invalid ID format.');
}

/// PUT /vehicles/<id>
Future<Response> updateVehicleHandler(Request request) async {
  final idStr = request.params["id"];

  if (idStr != null) {
    final id = int.tryParse(idStr);

    if (id != null) {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);
        final updatedVehicle = Vehicle.fromJson(data);

        final updated = await vehicleRepo.update(id, updatedVehicle);

        return Response.ok(
          jsonEncode(updated.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.badRequest(body: 'Error: ${e.toString()}');
      }
    }
  }

  return Response.badRequest(body: 'Invalid ID format.');
}

/// DELETE /vehicles/<id>
Future<Response> deleteVehicleHandler(Request request) async {
  final idStr = request.params["id"];

  if (idStr != null) {
    final id = int.tryParse(idStr);

    if (id != null) {
      try {
        final deletedVehicle = await vehicleRepo.delete(id);
        return Response.ok(
          jsonEncode(deletedVehicle?.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: 'Error: ${e.toString()}');
      }
    }
  }

  return Response.badRequest(body: 'Invalid ID format.');
}
