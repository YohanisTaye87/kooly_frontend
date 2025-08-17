class CarType {
  final String id;
  final String vehicleType;
  final num percentageCut;
  final num pricePerKm;
  final num startingPrice;
  final String? image;
  final String driverCarType;

  CarType({
    required this.id,
    required this.vehicleType,
    required this.percentageCut,
    required this.pricePerKm,
    required this.startingPrice,
    required this.image,
    required this.driverCarType,
  });

  factory CarType.fromJson(Map<String, dynamic> json) {
    return CarType(
      id: json['_id'],
      vehicleType: json['vehicleType'],
      percentageCut: json['percentageCut'],
      pricePerKm: json['pricePerKm'],
      startingPrice: json['startingPrice'],
      image: json['image'],
      driverCarType: json["vehicleType"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      //  id: json['_id'],
      'vehicleType': vehicleType,
      'percentageCut': percentageCut,
      'pricePerKm': pricePerKm,
      'startingPrice': startingPrice,
      'image': image,
      'driverCarType': vehicleType,
    };
  }
}
