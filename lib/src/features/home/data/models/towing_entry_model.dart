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
      'plate_number': plateNumber,
      'location': location,
      'tow_company': towCompany,
      'reason': reason,
      'notes': notes,
      'tow_date': towDate?.toIso8601String(),
      'attached_image': attachedImage,
      'reported_by': reportedBy,
    };
  }

  factory TowingEntryModel.fromJson(Map<String, dynamic> json) {
    return TowingEntryModel(
      plateNumber: json['plate_number'] ?? json['plateNumber'] ?? '',
      location: json['location'],
      towCompany: json['tow_company'] ?? json['towCompany'],
      reason: json['reason'],
      notes: json['notes'],
      towDate: json['tow_date'] != null 
        ? DateTime.parse(json['tow_date']) 
        : (json['towDate'] != null ? DateTime.parse(json['towDate']) : null),
      attachedImage: json['attached_image'] ?? json['attachedImage'],
      reportedBy: json['reported_by'] ?? json['reportedBy'],
    );
  }
}
