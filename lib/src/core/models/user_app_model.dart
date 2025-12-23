import 'package:park_my_whip/src/core/helpers/app_logger.dart';

/// Model for the `user_apps` junction table
class UserAppModel {
  final String id;
  final String userId;
  final String appId;
  final String role;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserAppModel({
    required this.id,
    required this.userId,
    required this.appId,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const <String, dynamic>{},
  });

  factory UserAppModel.fromJson(Map<String, dynamic> json) {
    return UserAppModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      appId: json['app_id'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      isActive: json['is_active'] as bool? ?? true,
      metadata: _safeMetadata(json['metadata']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'app_id': appId,
        'role': role,
        'is_active': isActive,
        'metadata': metadata,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  UserAppModel copyWith({
    String? id,
    String? userId,
    String? appId,
    String? role,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      UserAppModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        appId: appId ?? this.appId,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
        metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    AppLogger.warning('Invalid date "$value", defaulting to now',
        name: 'UserAppModel');
    return DateTime.now();
  }

  static Map<String, dynamic> _safeMetadata(dynamic data) {
    if (data is Map<String, dynamic>) return Map<String, dynamic>.from(data);
    if (data is Map) return Map<String, dynamic>.from(data.cast<String, dynamic>());
    return const <String, dynamic>{};
  }
}
