import 'dart:convert';
import 'package:objectbox/objectbox.dart';
import 'package:shared/src/models/ParkingSpace.dart';
import 'package:shared/src/models/Vehicle.dart';
import 'package:equatable/equatable.dart';

@Entity()
class Parking extends Equatable {
  @Id()
  int id;
  @Transient()
  Vehicle? vehicle;
  @Transient()
  ParkingSpace? parkingSpace; // Nullable parkingSpace
  final DateTime startTime;
  final DateTime endTime;

  Parking({
    this.vehicle,
    this.parkingSpace,
    required this.startTime,
    required this.endTime,
    this.id = 0, // Default to -1 for unassigned ID
  });

  // Convert vehicle to a JSON string for database storage
  String? get vehicleInDb =>
      vehicle == null ? null : jsonEncode(vehicle!.toJson());

  set vehicleInDb(String? json) {
    vehicle = json == null ? null : Vehicle.fromJson(jsonDecode(json));
  }

  // Convert parkingSpace to a JSON string for database storage
  String? get parkingSpaceInDb =>
      parkingSpace == null ? null : jsonEncode(parkingSpace!.toJson());

  set parkingSpaceInDb(String? json) {
    parkingSpace =
        json == null ? null : ParkingSpace.fromJson(jsonDecode(json));
  }

  // Factory constructor to create a Parking instance from JSON
  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'] ?? 0,
      vehicle:
          json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      parkingSpace: json['parkingSpace'] != null
          ? ParkingSpace.fromJson(json['parkingSpace'])
          : null,
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
    );
  }

  // Convert a Parking instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle': vehicle?.toJson(),
      'parkingSpace': parkingSpace?.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, vehicle, parkingSpace, startTime, endTime];
}
