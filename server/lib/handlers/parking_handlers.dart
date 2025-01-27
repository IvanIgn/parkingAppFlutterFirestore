import 'dart:convert';
import 'package:server/repositories/parkingRepository.dart';
import 'package:shared/shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

final ParkingRepository parkingRepo = ParkingRepository.instance;

/// GET /parkings

Future<Response> getAllParkingsHandler(Request request) async {
  final parkings = await parkingRepo.getAll();
  final payload = parkings?.map((p) => (p).toJson()).toList();

  return Response.ok(
    jsonEncode(payload),
    headers: {'Content-Type': 'application/json'},
  );
}

/// POST /parkings
Future<Response> createParkingHandler(Request request) async {
  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final parking = Parking.fromJson(data);

    final createdParking = await parkingRepo.add(parking);

    return Response.ok(
      jsonEncode(createdParking?.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.badRequest(body: 'Error: ${e.toString()}');
  }
}

/// GET /parkings/<id>
Future<Response> getParkingByIdHandler(Request request) async {
  final idStr = request.params["id"];

  if (idStr != null) {
    final id = int.tryParse(idStr);

    if (id != null) {
      final parking = await parkingRepo.getById(id);
      if (parking != null) {
        return Response.ok(
          jsonEncode(parking.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound('Parkering med ID $id hittades inte.');
      }
    }
  }

  return Response.badRequest(body: 'Invalid ID format.');
}

/// PUT /parkings/<id>
Future<Response> updateParkingHandler(Request request) async {
  final idStr = request.params["id"];

  if (idStr != null) {
    final id = int.tryParse(idStr);

    if (id != null) {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);
        final updatedParking = Parking.fromJson(data);

        final updated = await parkingRepo.update(id, updatedParking);

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

/// DELETE /parkings/<id>
Future<Response> deleteParkingHandler(Request request) async {
  final idStr = request.params["id"];

  if (idStr != null) {
    final id = int.tryParse(idStr);

    if (id != null) {
      try {
        final deletedParking = await parkingRepo.delete(id);
        return Response.ok(
          jsonEncode(deletedParking?.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: 'Error: ${e.toString()}');
      }
    }
  }

  return Response.badRequest(body: 'Invalid ID format.');
}
