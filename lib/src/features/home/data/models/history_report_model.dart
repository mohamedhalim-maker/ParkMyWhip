class HistoryReportModel {
  final String id;
  final String adminRole;
  final String plateNumber;
  final String reportedBy;
  final String expiredReason;
  final DateTime submitTime;
  final String carDetails;

  HistoryReportModel({
    required this.id,
    required this.adminRole,
    required this.plateNumber,
    required this.reportedBy,
    required this.expiredReason,
    required this.submitTime,
    required this.carDetails,
  });

  factory HistoryReportModel.fromJson(Map<String, dynamic> json) {
    return HistoryReportModel(
      id: json['id'] ?? '',
      adminRole: json['admin_role'] ?? json['adminRole'] ?? '',
      plateNumber: json['plate_number'] ?? json['plateNumber'] ?? '',
      reportedBy: json['reported_by'] ?? json['reportedBy'] ?? '',
      carDetails: json['car_details'] ?? json['carDetails'] ?? '',
      expiredReason: json['expired_reason'] ?? json['expiredReason'] ?? '',
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
    'car_details': carDetails,
    'expired_reason': expiredReason,
    'submit_time': submitTime.toIso8601String(),
  };
}
