class TowingEntryModel {
  final String plateNumber;
  final String? location;
  final String? towCompany;
  final String? reason;
  final String? notes;
  final DateTime? towDate;
  final String? attachedImage;
  final String? reportedBy;

  TowingEntryModel({
    required this.plateNumber,
    this.location,
    this.towCompany,
    this.reason,
    this.notes,
    this.towDate,
    this.attachedImage,
    this.reportedBy,
  });

  TowingEntryModel copyWith({
    String? plateNumber,
    String? location,
    String? towCompany,
    String? reason,
    String? notes,
    DateTime? towDate,
    String? attachedImage,
    String? reportedBy,
  }) {
    return TowingEntryModel(
      plateNumber: plateNumber ?? this.plateNumber,
      location: location ?? this.location,
      towCompany: towCompany ?? this.towCompany,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      towDate: towDate ?? this.towDate,
      attachedImage: attachedImage ?? this.attachedImage,
      reportedBy: reportedBy ?? this.reportedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plateNumber': plateNumber,
      'location': location,
      'towCompany': towCompany,
      'reason': reason,
      'notes': notes,
      'towDate': towDate?.toIso8601String(),
      'attachedImage': attachedImage,
      'reportedBy': reportedBy,
    };
  }

  factory TowingEntryModel.fromJson(Map<String, dynamic> json) {
    return TowingEntryModel(
      plateNumber: json['plateNumber'],
      location: json['location'],
      towCompany: json['towCompany'],
      reason: json['reason'],
      notes: json['notes'],
      towDate: json['towDate'] != null ? DateTime.parse(json['towDate']) : null,
      attachedImage: json['attachedImage'],
      reportedBy: json['reportedBy'],
    );
  }
}
