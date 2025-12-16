class ActiveReportModel {
  final String id;
  final String adminRole;
  final String plateNumber;
  final String reportedBy;
  final String additionalNotes;
  final String attachedImage;
  final DateTime submitTime;
  final String carDetails;

  ActiveReportModel({
    required this.id,
    required this.adminRole,
    required this.plateNumber,
    required this.reportedBy,
    required this.additionalNotes,
    required this.attachedImage,
    required this.submitTime,
    required this.carDetails,
  });

  factory ActiveReportModel.fromJson(Map<String, dynamic> json) {
    return ActiveReportModel(
      id: json['id'] ?? '',
      adminRole: json['admin_role'] ?? json['adminRole'] ?? '',
      plateNumber: json['plate_number'] ?? json['plateNumber'] ?? '',
      reportedBy: json['reported_by'] ?? json['reportedBy'] ?? '',
      additionalNotes: json['additional_notes'] ?? json['additionalNotes'] ?? '',
      attachedImage: json['attached_image'] ?? json['attachedImage'] ?? '',
      carDetails: json['car_details'] ?? json['carDetails'] ?? '',
      submitTime: json['submit_time'] != null 
        ? DateTime.parse(json['submit_time']) 
        : (json['submitTime'] != null ? DateTime.parse(json['submitTime']) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'admin_role': adminRole,
    'plate_number': plateNumber,
    'reported_by': reportedBy,
    'additional_notes': additionalNotes,
    'attached_image': attachedImage,
    'car_details': carDetails,
    'submit_time': submitTime.toIso8601String(),
  };
}
