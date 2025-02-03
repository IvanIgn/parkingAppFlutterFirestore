import 'dart:convert';
import 'package:objectbox/objectbox.dart';
import 'package:shared/src/models/Person.dart';
import 'package:equatable/equatable.dart';

@Entity()
class Vehicle extends Equatable {
  @Id()
  int id;
  final String regNumber;
  final String vehicleType;

  @Transient()
  Person? owner;

  Vehicle({
    required this.regNumber,
    required this.vehicleType,
    this.owner,
    this.id = 0, // Default to -1 for unassigned ID
  });

  // Getter to encode `owner` as a JSON string for database storage
  String? get ownerInDb {
    return owner == null ? null : jsonEncode(owner!.toJson());
  }

  // Setter to decode a JSON string to assign the `owner` property
  set ownerInDb(String? json) {
    if (json == null) {
      owner = null;
    } else {
      try {
        owner = Person.fromJson(jsonDecode(json));
      } catch (e) {
        owner = null; // Handle decoding errors by setting `owner` to null
      }
    }
  }

  // Factory constructor to create a Vehicle from JSON
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? 0, // Default to -1 if id is missing
      regNumber: json['regNumber'] ?? '', // Default to empty string
      vehicleType: json['vehicleType'] ?? '', // Default to empty string
      owner: json['owner'] != null ? Person.fromJson(json['owner']) : null,
    );
  }

  // Convert a Vehicle object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'regNumber': regNumber,
      'vehicleType': vehicleType,
      'owner': owner?.toJson(), // Null check for owner
    };
  }

  // `copyWith` method to allow modification of specific fields
  Vehicle copyWith({
    int? id,
    String? regNumber,
    String? vehicleType,
    Person? owner,
  }) {
    return Vehicle(
      id: id ?? this.id,
      regNumber: regNumber ?? this.regNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      owner: owner ?? this.owner,
    );
  }

  @override
  List<Object?> get props => [id, regNumber, vehicleType, owner];
}
