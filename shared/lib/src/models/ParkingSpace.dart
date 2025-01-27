import 'package:objectbox/objectbox.dart';
import 'package:equatable/equatable.dart';

@Entity()
class ParkingSpace extends Equatable {
  @Id()
  int id;
  final String address;
  final int pricePerHour;

  ParkingSpace({
    required this.address,
    required this.pricePerHour,
    this.id = 0, // Default to -1 for unassigned ID
  });

  // Factory constructor to create a ParkingSpace from JSON
  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json['id'] ?? 0, // Default to -1 if id is missing
      address: json['address'] ??
          '', // Default to empty string if address is missing
      pricePerHour:
          json['pricePerHour'] ?? 0, // Default to 0 if pricePerHour is missing
    );
  }

  // Convert a ParkingSpace object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'pricePerHour': pricePerHour,
    };
  }

  @override
  List<Object?> get props => [id, address, pricePerHour];
}
