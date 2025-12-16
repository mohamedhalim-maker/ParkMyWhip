class PermitModel {
  final String id;
  final String permitType; // e.g. 'Yearly'
  final DateTime expiryDate;
  final VehicleInfo vehicleInfo;
  final PlateSpotInfo plateSpotInfo;

  PermitModel({
    required this.id,
    required this.permitType,
    required this.expiryDate,
    required this.vehicleInfo,
    required this.plateSpotInfo,
  });

  factory PermitModel.fromJson(Map<String, dynamic> json) {
    return PermitModel(
      id: json['id'] ?? '',
      permitType: json['permit_type'] ?? json['permitType'] ?? '',
      expiryDate: json['expiry_date'] != null 
        ? DateTime.parse(json['expiry_date']) 
        : (json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : DateTime.now()),
      vehicleInfo: VehicleInfo(
        model: json['vehicle_model'] ?? json['vehicleInfo']?['model'] ?? '',
        year: json['vehicle_year'] ?? json['vehicleInfo']?['year'] ?? '',
        color: json['vehicle_color'] ?? json['vehicleInfo']?['color'] ?? '',
      ),
      plateSpotInfo: PlateSpotInfo(
        plateNumber: json['plate_number'] ?? json['plateSpotInfo']?['plateNumber'] ?? '',
        spotNumber: json['spot_number'] ?? json['plateSpotInfo']?['spotNumber'] ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'permit_type': permitType,
      'expiry_date': expiryDate.toIso8601String(),
      'vehicle_model': vehicleInfo.model,
      'vehicle_year': vehicleInfo.year,
      'vehicle_color': vehicleInfo.color,
      'plate_number': plateSpotInfo.plateNumber,
      'spot_number': plateSpotInfo.spotNumber,
    };
  }
}

class VehicleInfo {
  final String model; // Chevrolet-Silverado
  final String year; // 2024
  final String color; // Black

  VehicleInfo({required this.model, required this.year, required this.color});

  Map<String, dynamic> toJson() {
    return {'model': model, 'year': year, 'color': color};
  }

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      model: json['model'],
      year: json['year'],
      color: json['color'],
    );
  }
}

class PlateSpotInfo {
  final String plateNumber; // ABC 123
  final String spotNumber; // 3 A

  PlateSpotInfo({required this.plateNumber, required this.spotNumber});

  Map<String, dynamic> toJson() {
    return {'plateNumber': plateNumber, 'spotNumber': spotNumber};
  }

  factory PlateSpotInfo.fromJson(Map<String, dynamic> json) {
    return PlateSpotInfo(
      plateNumber: json['plateNumber'],
      spotNumber: json['spotNumber'],
    );
  }
}
