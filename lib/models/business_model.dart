import 'package:momentum/models/location_model.dart';
class BusinessWithLocations {
  final String id;
  final String name;
  final List<ILocation> locations; 
  final bool isDeleted;

  BusinessWithLocations({
    required this.id,
    required this.name,
    required this.locations,
    required this.isDeleted,
  });

  factory BusinessWithLocations.fromJson(Map<String, dynamic> json) {
    return BusinessWithLocations(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      locations: (json['location'] as List<dynamic>?)
              ?.map((e) => ILocation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'location': locations.map((loc) => loc.toJson()).toList(),
      'isDeleted': isDeleted,
    };
  }
}
