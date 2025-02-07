// import 'package:equatable/equatable.dart';
// import 'package:uuid/uuid.dart';

// class Person extends Equatable {
//   final String
//       id; // Default to 0, the expected value for unassigned IDs in ObjectBox
//   final String name;
//   final String personNumber;

//   Person({
//     String? id,
//     required this.name,
//     required this.personNumber,
//   }) : id = id ?? const Uuid().v4(); // Default to a new UUID for unassigned ID

//   // Factory constructor to create a Person from JSON
//   factory Person.fromJson(Map<String, dynamic> json) {
//     return Person(
//       id: json['id'] ?? '', // Default to 0 if ID is missing
//       name: json['name'] ?? '',
//       personNumber: json['personNumber'] ?? '',
//     );
//   }

//   // Convert a Person object to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "name": name,
//       "personNumber": personNumber,
//     };
//   }

//   @override
//   List<Object?> get props => [id, name, personNumber];
// }

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Person extends Equatable {
  final String id;
  final String name;
  final String personNumber;

  Person({
    String? id,
    required this.name,
    required this.personNumber,
  }) : id = id ?? const Uuid().v4(); // Use a UUID if no ID is provided

  // Factory constructor to create a Person from JSON
  factory Person.fromJson(Map<String, dynamic> json) {
    // Use UUID if id is not provided in the JSON
    final id = json['id'] ?? const Uuid().v4();

    // Throw error if name or personNumber is missing (or empty)
    if (json['name'] == null || json['name'].isEmpty) {
      throw ArgumentError('Name is required');
    }
    if (json['personNumber'] == null || json['personNumber'].isEmpty) {
      throw ArgumentError('Person number is required');
    }

    return Person(
      id: id,
      name: json['name'],
      personNumber: json['personNumber'],
    );
  }

  // Convert a Person object to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "personNumber": personNumber,
    };
  }

  @override
  List<Object?> get props => [id, name, personNumber];
}
