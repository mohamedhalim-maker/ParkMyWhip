# Data Layer Documentation

## Overview
The data layer manages all data models, serialization, and backend integration with Supabase. It follows clean architecture principles with clear separation between data sources, models, and repositories.

---

## Architecture Pattern

```
Data Layer
├── Models (Data structures)
│   ├── fromJson() - Deserialize from Supabase
│   ├── toJson() - Serialize for Supabase
│   └── copyWith() - Immutable updates
├── Data Sources (Backend integration)
│   ├── Remote - Supabase API calls
│   └── Local - SharedPreferences caching
└── Repositories (Future: Business logic layer)
    └── Aggregate multiple data sources
```

---

## Data Models

### Model Structure Pattern

All models follow this pattern:

```dart
class ExampleModel {
  // 1. Immutable fields
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 2. Constructor
  const ExampleModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  // 3. fromJson (Supabase deserialization)
  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // 4. toJson (Supabase serialization)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  // 5. copyWith (optional - for immutable updates)
  ExampleModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExampleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

---

## Core Models

### 1. SupabaseUserModel

**Purpose**: Represents user profile from Supabase `users` table.

**Location**: `lib/src/core/models/supabase_user_model.dart`

**Schema**:
```dart
class SupabaseUserModel {
  final String id;                    // UUID from auth.users
  final String email;
  final String fullName;              // Maps to full_name column
  final bool emailVerified;
  final String? avatarUrl;            // Optional avatar_url
  final String? phoneNumber;          // Optional phone
  final Map<String, dynamic> metadata; // JSON metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupabaseUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.emailVerified = false,
    this.avatarUrl,
    this.phoneNumber,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupabaseUserModel.fromJson(Map<String, dynamic> json) {
    return SupabaseUserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? 'User',
      emailVerified: json['email_verified'] ?? false,
      avatarUrl: json['avatar_url'],
      phoneNumber: json['phone'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'email_verified': emailVerified,
    'avatar_url': avatarUrl,
    'phone': phoneNumber,
    'metadata': metadata,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
```

**Supabase Table Schema**:
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  avatar_url TEXT,
  phone TEXT,
  role TEXT DEFAULT 'user',
  is_active BOOLEAN DEFAULT true,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

---

### 2. LocationModel

**Purpose**: Represents patrol locations.

**Location**: `lib/src/features/home/data/models/location_model.dart`

**Schema**:
```dart
class LocationModel {
  final String id;
  final String locationName;    // Maps to location_name
  final String address;
  final double? latitude;       // Optional GPS coordinates
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? '',
      locationName: json['location_name'] ?? json['locationName'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'location_name': locationName,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
```

**Supabase Table**:
```sql
CREATE TABLE locations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  location_name TEXT NOT NULL,
  address TEXT NOT NULL,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

---

### 3. ActiveReportModel

**Purpose**: Represents active violation reports.

**Location**: `lib/src/features/home/data/models/active_reports_model.dart`

**Schema**:
```dart
class ActiveReportModel {
  final String id;
  final String adminRole;         // Maps to admin_role
  final String plateNumber;       // Maps to plate_number
  final String reportedBy;        // Maps to reported_by (user ID)
  final String additionalNotes;   // Maps to additional_notes
  final String attachedImage;     // Maps to attached_image (URL)
  final DateTime submitTime;      // Maps to submit_time
  final String carDetails;        // Maps to car_details (violation type)

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
```

**Key Pattern**: Supports both snake_case (Supabase) and camelCase (legacy) for backwards compatibility.

**Supabase Table**:
```sql
CREATE TABLE active_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_role TEXT NOT NULL,
  plate_number TEXT NOT NULL,
  reported_by UUID REFERENCES users(id),
  additional_notes TEXT,
  attached_image TEXT,
  submit_time TIMESTAMPTZ DEFAULT now(),
  car_details TEXT NOT NULL
);
```

---

### 4. HistoryReportModel

**Purpose**: Represents archived/completed reports.

**Schema**:
```dart
class HistoryReportModel {
  final String id;
  final String adminRole;
  final String plateNumber;
  final String reportedBy;
  final String additionalNotes;
  final String attachedImage;
  final DateTime towDate;         // Maps to tow_date
  final String carDetails;
  final String status;            // 'completed', 'cancelled'

  factory HistoryReportModel.fromJson(Map<String, dynamic> json) {
    return HistoryReportModel(
      id: json['id'] ?? '',
      adminRole: json['admin_role'] ?? json['adminRole'] ?? '',
      plateNumber: json['plate_number'] ?? json['plateNumber'] ?? '',
      reportedBy: json['reported_by'] ?? json['reportedBy'] ?? '',
      additionalNotes: json['additional_notes'] ?? json['additionalNotes'] ?? '',
      attachedImage: json['attached_image'] ?? json['attachedImage'] ?? '',
      carDetails: json['car_details'] ?? json['carDetails'] ?? '',
      status: json['status'] ?? 'completed',
      towDate: json['tow_date'] != null 
        ? DateTime.parse(json['tow_date']) 
        : DateTime.now(),
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
    'status': status,
    'tow_date': towDate.toIso8601String(),
  };
}
```

**Supabase Table**:
```sql
CREATE TABLE history_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_role TEXT NOT NULL,
  plate_number TEXT NOT NULL,
  reported_by UUID REFERENCES users(id),
  additional_notes TEXT,
  attached_image TEXT,
  tow_date TIMESTAMPTZ DEFAULT now(),
  car_details TEXT NOT NULL,
  status TEXT DEFAULT 'completed'
);
```

---

### 5. TowingEntryModel

**Purpose**: Represents individual towing history entries.

**Schema**:
```dart
class TowingEntryModel {
  final String id;
  final String plateNumber;       // Maps to plate_number
  final String violationType;     // Maps to violation_type
  final DateTime towDate;         // Maps to tow_date
  final String location;
  final String towedBy;           // Maps to towed_by (user ID)
  final String additionalNotes;   // Maps to additional_notes
  final String? imagePath;        // Maps to image_path

  factory TowingEntryModel.fromJson(Map<String, dynamic> json) {
    return TowingEntryModel(
      id: json['id'] ?? '',
      plateNumber: json['plate_number'] ?? json['plateNumber'] ?? '',
      violationType: json['violation_type'] ?? json['violationType'] ?? '',
      towDate: json['tow_date'] != null 
        ? DateTime.parse(json['tow_date']) 
        : DateTime.now(),
      location: json['location'] ?? '',
      towedBy: json['towed_by'] ?? json['towedBy'] ?? '',
      additionalNotes: json['additional_notes'] ?? json['additionalNotes'] ?? '',
      imagePath: json['image_path'] ?? json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'plate_number': plateNumber,
    'violation_type': violationType,
    'tow_date': towDate.toIso8601String(),
    'location': location,
    'towed_by': towedBy,
    'additional_notes': additionalNotes,
    'image_path': imagePath,
  };
}
```

**Supabase Table**:
```sql
CREATE TABLE towing_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  plate_number TEXT NOT NULL,
  violation_type TEXT NOT NULL,
  tow_date TIMESTAMPTZ DEFAULT now(),
  location TEXT NOT NULL,
  towed_by UUID REFERENCES users(id),
  additional_notes TEXT,
  image_path TEXT
);
```

---

### 6. PermitDataModel

**Purpose**: Represents parking permits.

**Schema**:
```dart
class PermitDataModel {
  final String id;
  final String permitNumber;      // Maps to permit_number
  final String plateNumber;       // Maps to plate_number
  final DateTime expiryDate;      // Maps to expiry_date
  final String location;
  final String holderName;        // Maps to holder_name
  final bool isActive;            // Maps to is_active

  factory PermitDataModel.fromJson(Map<String, dynamic> json) {
    return PermitDataModel(
      id: json['id'] ?? '',
      permitNumber: json['permit_number'] ?? json['permitNumber'] ?? '',
      plateNumber: json['plate_number'] ?? json['plateNumber'] ?? '',
      expiryDate: json['expiry_date'] != null 
        ? DateTime.parse(json['expiry_date']) 
        : DateTime.now(),
      location: json['location'] ?? '',
      holderName: json['holder_name'] ?? json['holderName'] ?? '',
      isActive: json['is_active'] ?? json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'permit_number': permitNumber,
    'plate_number': plateNumber,
    'expiry_date': expiryDate.toIso8601String(),
    'location': location,
    'holder_name': holderName,
    'is_active': isActive,
  };
}
```

---

### 7. ReportFilterCriteria

**Purpose**: Represents filter state for reports/history.

**Schema**:
```dart
class ReportFilterCriteria {
  final String? timeRange;      // 'last_week', 'last_month', 'last_year', null (all)
  final String? violationType;  // 'unauthorized', 'expired_permit', 'blocking', null (all)

  const ReportFilterCriteria({
    this.timeRange,
    this.violationType,
  });

  ReportFilterCriteria copyWith({
    String? timeRange,
    String? violationType,
  }) {
    return ReportFilterCriteria(
      timeRange: timeRange ?? this.timeRange,
      violationType: violationType ?? this.violationType,
    );
  }

  bool get hasActiveFilters => timeRange != null || violationType != null;

  void clearFilters() {
    return const ReportFilterCriteria();
  }
}
```

---

## Data Sources

### Abstract Interface Pattern

**Purpose**: Define contracts for data operations (allows swapping implementations).

```dart
abstract class AuthRemoteDataSource {
  Future<SupabaseUserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  Future<bool> signOut();
  // ... other methods
}
```

### Supabase Implementation

**Pattern**:
```dart
class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  SupabaseAuthRemoteDataSource({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<SupabaseUserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Supabase auth operation
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Fetch profile from database
      final userProfile = await _supabaseClient
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();

      return SupabaseUserModel.fromJson(userProfile);
    } catch (e) {
      log('Login error: $e', name: 'SupabaseAuthRemoteDataSource', level: 900, error: e);
      rethrow;
    }
  }
}
```

---

## Supabase Integration

### Query Patterns

#### 1. Select (Read)
```dart
// Get all records
final response = await Supabase.instance.client
    .from('locations')
    .select();

final locations = response.map((json) => LocationModel.fromJson(json)).toList();

// Get single record
final response = await Supabase.instance.client
    .from('users')
    .select()
    .eq('id', userId)
    .single();

final user = SupabaseUserModel.fromJson(response);

// With filters
final response = await Supabase.instance.client
    .from('active_reports')
    .select()
    .eq('reported_by', userId)
    .gte('submit_time', startDate.toIso8601String())
    .order('submit_time', ascending: false)
    .limit(50);
```

#### 2. Insert (Create)
```dart
await Supabase.instance.client.from('active_reports').insert({
  'plate_number': plateNumber,
  'car_details': violationType,
  'reported_by': userId,
  'additional_notes': notes,
  'attached_image': imageUrl,
  'admin_role': 'Officer',
});
```

#### 3. Update
```dart
await Supabase.instance.client
    .from('users')
    .update({'full_name': newName})
    .eq('id', userId);
```

#### 4. Delete
```dart
await Supabase.instance.client
    .from('active_reports')
    .delete()
    .eq('id', reportId);
```

---

## Serialization Best Practices

### 1. Handle Null Values
```dart
factory Model.fromJson(Map<String, dynamic> json) {
  return Model(
    id: json['id'] ?? '',                    // Default to empty string
    count: json['count'] ?? 0,                // Default to 0
    isActive: json['is_active'] ?? false,     // Default to false
    optionalField: json['optional_field'],    // Keep as null
  );
}
```

### 2. DateTime Handling
```dart
// Parse from ISO string
final date = DateTime.parse(json['created_at']);

// Serialize to ISO string
'created_at': createdAt.toIso8601String()

// Handle null with fallback
final date = json['date'] != null 
  ? DateTime.parse(json['date']) 
  : DateTime.now();
```

### 3. Map/List Handling
```dart
// Parse JSON object to Map
metadata: Map<String, dynamic>.from(json['metadata'] ?? {})

// Parse JSON array to List
tags: List<String>.from(json['tags'] ?? [])

// Model list
final reports = (json['reports'] as List?)
    ?.map((item) => ReportModel.fromJson(item))
    .toList() ?? [];
```

### 4. Enum Handling
```dart
enum Status { active, inactive, pending }

// Parse from string
Status status = Status.values.firstWhere(
  (e) => e.toString().split('.').last == json['status'],
  orElse: () => Status.pending,
);

// Serialize to string
'status': status.toString().split('.').last
```

---

## Error Handling

### NetworkExceptions Utility

**Location**: `lib/src/core/networking/network_exceptions.dart`

**Purpose**: Translate backend exceptions into user-friendly messages.

```dart
class NetworkExceptions {
  static String getSupabaseExceptionMessage(dynamic exception) {
    if (exception is AuthException) {
      switch (exception.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password';
        case 'User already registered':
          return 'An account with this email already exists';
        case 'Email not confirmed':
          return 'Please verify your email first';
        default:
          return exception.message ?? 'Authentication error';
      }
    }
    
    if (exception is PostgrestException) {
      return 'Database error: ${exception.message}';
    }
    
    return 'An unexpected error occurred';
  }
}
```

**Usage in Data Source**:
```dart
try {
  final response = await _supabaseClient.auth.signInWithPassword(...);
  return SupabaseUserModel.fromJson(response);
} catch (e) {
  log('Login error: $e', name: 'DataSource', level: 900, error: e);
  rethrow; // Let cubit handle with NetworkExceptions.getSupabaseExceptionMessage()
}
```

**Usage in Cubit**:
```dart
try {
  await authRemoteDataSource.login(...);
} catch (e) {
  final errorMessage = NetworkExceptions.getSupabaseExceptionMessage(e);
  emit(state.copyWith(errorMessage: errorMessage));
}
```

---

## Testing Data Models

### Unit Test Pattern
```dart
void main() {
  group('ActiveReportModel', () {
    test('fromJson creates correct model', () {
      final json = {
        'id': '123',
        'plate_number': 'ABC-123',
        'admin_role': 'Officer',
        'submit_time': '2025-03-07T10:00:00Z',
      };

      final model = ActiveReportModel.fromJson(json);

      expect(model.id, '123');
      expect(model.plateNumber, 'ABC-123');
      expect(model.adminRole, 'Officer');
    });

    test('toJson creates correct map', () {
      final model = ActiveReportModel(
        id: '123',
        plateNumber: 'ABC-123',
        adminRole: 'Officer',
        submitTime: DateTime.parse('2025-03-07T10:00:00Z'),
      );

      final json = model.toJson();

      expect(json['id'], '123');
      expect(json['plate_number'], 'ABC-123');
      expect(json['admin_role'], 'Officer');
    });

    test('handles missing fields gracefully', () {
      final json = {'id': '123'}; // Missing required fields

      final model = ActiveReportModel.fromJson(json);

      expect(model.id, '123');
      expect(model.plateNumber, ''); // Default value
    });
  });
}
```

---

## Summary

The data layer provides:
- **Immutable data models** with clear structure
- **Supabase integration** with proper serialization
- **snake_case ↔ camelCase** compatibility
- **Null-safe parsing** with defaults
- **Error handling** with user-friendly messages
- **Type-safe queries** using models
- **Testable code** with clear contracts
- **Clean separation** between data sources and business logic
