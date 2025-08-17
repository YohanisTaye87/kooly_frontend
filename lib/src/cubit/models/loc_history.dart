import 'package:latlong2/latlong.dart';

class LocationHistory {
  final String name;
  final LatLng location;
  final String? streetName;
  final String? city;

  LocationHistory(
      {required this.name, required this.location, this.streetName, this.city});

  factory LocationHistory.fromJson(Map<String, dynamic> json) {
    return LocationHistory(
        name: json['name'],
        location: LatLng.fromJson(json['location']),
        streetName: json['streetName'],
        city: json['city']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location.toJson(),
      'streetName': streetName,
      'city': city
    };
  }
}
