class PickUp {
  final double lat;
  final double lng;
  final String? id;

  PickUp({required this.lat, required this.lng, this.id});

  factory PickUp.fromJson(Map<String, dynamic> json) {
    return PickUp(
      lat: json['lat'],
      lng: json['lng'],
      id: json['_id'],
    );
  }
  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng, 'id': id};
  }
}

class DropOff {
  final double lat;
  final double lng;
  final String? id;

  DropOff({required this.lat, required this.lng, this.id});

  factory DropOff.fromJson(Map<String, dynamic> json) {
    return DropOff(lat: json['lat'], lng: json['lng'], id: json['_id']);
  }
  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng, 'id': id};
  }
}
