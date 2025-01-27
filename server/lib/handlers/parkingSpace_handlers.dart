import 'dart:convert';
import 'package:server/repositories/parkingSpaceRepository.dart';
import 'package:shared/shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

final ParkingSpaceRepository parkingSpaceRepo = ParkingSpaceRepository.instance;

/// GET /parkingspaces
Future<Response> getAllParkingSpacesHandler(Request request) async {
  final parkingSpaces = await parkingSpaceRepo.getAll();
  final payload = parkingSpaces?.map((p) => (p).toJson()).toList();

  return Response.ok(
    jsonEncode(payload),
    headers: {'Content-Type': 'application/json'},
  );
}

/// POST /parkingspaces
Future<Response> createParkingSpaceHandler(Request request) async {
  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final parkingSpace = ParkingSpace.fromJson(data);

    final createdParkingSpace = await parkingSpaceRepo.add(parkingSpace);

    return Response.ok(
      jsonEncode(createdParkingSpace?.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.badRequest(body: 'Error: ${e.toString()}');
  }
}

/// GET /parkingspaces/<id>
Future<Response> getParkingSpaceByIdHandler(Request request) async {
  final idStr = request.params["id"];

  if (idStr != null) {
    final id = int.tryParse(idStr);

    if (id != null) {
      final parkingSpace = await parkingSpaceRepo.getById(id);
      if (parkingSpace != null) {
        return Response.ok(
          jsonEncode(parkingSpace.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound('Parkeringsplats med ID $id hittades inte.');
      }
    }
  }

  return Response.badRequest(body: 'Invalid ID format.');
}

/// PUT /parkingspaces/<id>
Future<Response> updateParkingSpaceHandler(Request request) async {
  final idStr = request.params["id"];

  if (idStr != null) {
    final id = int.tryParse(idStr);

    if (id != null) {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);
        final updatedParkingSpace = ParkingSpace.fromJson(data);

        final updated = await parkingSpaceRepo.update(id, updatedParkingSpace);

        return Response.ok(
          jsonEncode(updated?.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.badRequest(body: 'Error: ${e.toString()}');
      }
    }
  }

  return Response.badRequest(body: 'Invalid ID format.');
}

/// DELETE /parkingspaces/<id>
Future<Response> deleteParkingSpaceHandler(Request request) async {
  final idStr = request.params["id"];

  if (idStr != null) {
    final id = int.tryParse(idStr);

    if (id != null) {
      try {
        final deletedParkingSpace = await parkingSpaceRepo.delete(id);

        return Response.ok(
          jsonEncode(deletedParkingSpace?.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: 'Error: ${e.toString()}');
      }
    }
  }

  return Response.badRequest(body: 'Invalid ID format.');
}
