import 'dart:convert';
import 'package:server/repositories/personRepository.dart';
import 'package:shared/shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

final PersonRepository personRepo = PersonRepository.instance;

/// GET /persons
Future<Response> getAllPersonsHandler(Request request) async {
  final persons = await personRepo.getAll();
  final payload = persons.map((p) => (p).toJson()).toList();

  return Response.ok(
    jsonEncode(payload),
    headers: {'Content-Type': 'application/json'},
  );
}

/// POST /persons
Future<Response> createPersonHandler(Request request) async {
  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final person = Person.fromJson(data);

    final createdPerson = await personRepo.add(person);
    return Response.ok(
      jsonEncode(createdPerson.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.badRequest(body: 'Error: ${e.toString()}');
  }
}

/// GET /persons/<id>
Future<Response> getPersonByIdHandler(Request request) async {
  final idStr = request.params["id"];

  if (idStr != null) {
    final id = int.tryParse(idStr);

    if (id != null) {
      final person = await personRepo.getById(id);
      if (person != null) {
        return Response.ok(
          jsonEncode(person.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound('Person med ID $id hittades inte.');
      }
    }
  }

  return Response.badRequest(body: 'Invalid ID format.');
}

/// PUT /persons/<id>
Future<Response> updatePersonHandler(Request request) async {
  final idStr = request.params["id"];

  if (idStr != null) {
    final id = int.tryParse(idStr);

    if (id != null) {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);
        final updatedPerson = Person.fromJson(data);

        final updated = await personRepo.update(id, updatedPerson);

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

/// DELETE /persons/<id>
Future<Response> deletePersonHandler(Request request) async {
  final idStr = request.params["id"];

  if (idStr != null) {
    final id = int.tryParse(idStr);

    if (id != null) {
      try {
        final deletedPerson = await personRepo.delete(id);
        return Response.ok(
          jsonEncode(deletedPerson?.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: 'Error: ${e.toString()}');
      }
    }
  }

  return Response.badRequest(body: 'Invalid ID format.');
}
