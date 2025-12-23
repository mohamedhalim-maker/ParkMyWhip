# Supabase Integration Documentation

## Overview
ParkMyWhip uses **Supabase** as its backend-as-a-service (BaaS) for authentication, database, and storage. This document covers the complete integration setup, database schema, and usage patterns.

---

## Setup & Configuration

### 1. Dependencies

**pubspec.yaml**:
```yaml
dependencies:
  supabase_flutter: ^2.0.0  # Supabase Flutter SDK
  shared_preferences: ^2.2.3  # Local caching
```

### 2. Initialization

**Location**: `lib/supabase/supabase_config.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce, // Secure flow
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
```

**Main.dart Integration**:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  // Setup dependency injection
  setupDependencyInjection();
  
  runApp(const ParkMyWhipApp());
}
```

---

## Database Schema

### Tables Overview

```
users                  # User profiles
├── id (UUID, PK)
├── email (TEXT)
├── full_name (TEXT)
├── avatar_url (TEXT, nullable)
├── phone (TEXT, nullable)
├── role (TEXT)
├── is_active (BOOLEAN)
├── metadata (JSONB)
├── created_at (TIMESTAMPTZ)
└── updated_at (TIMESTAMPTZ)

locations              # Patrol locations
├── id (UUID, PK)
├── location_name (TEXT)
├── address (TEXT)
├── latitude (DOUBLE)
├── longitude (DOUBLE)
├── created_at (TIMESTAMPTZ)
└── updated_at (TIMESTAMPTZ)

permits                # Parking permits
├── id (UUID, PK)
├── permit_number (TEXT)
├── plate_number (TEXT)
├── expiry_date (TIMESTAMPTZ)
├── location (TEXT)
├── holder_name (TEXT)
├── is_active (BOOLEAN)
├── created_at (TIMESTAMPTZ)
└── updated_at (TIMESTAMPTZ)

active_reports         # Current violation reports
├── id (UUID, PK)
├── admin_role (TEXT)
├── plate_number (TEXT)
├── reported_by (UUID, FK → users.id)
├── additional_notes (TEXT)
├── attached_image (TEXT)
├── submit_time (TIMESTAMPTZ)
└── car_details (TEXT)

history_reports        # Archived reports
├── id (UUID, PK)
├── admin_role (TEXT)
├── plate_number (TEXT)
├── reported_by (UUID, FK → users.id)
├── additional_notes (TEXT)
├── attached_image (TEXT)
├── tow_date (TIMESTAMPTZ)
├── car_details (TEXT)
└── status (TEXT)

towing_entries         # Towing history
├── id (UUID, PK)
├── plate_number (TEXT)
├── violation_type (TEXT)
├── tow_date (TIMESTAMPTZ)
├── location (TEXT)
├── towed_by (UUID, FK → users.id)
├── additional_notes (TEXT)
└── image_path (TEXT)
```

---

## SQL Migrations

### Migration File: `lib/supabase/supabase_tables.sql`

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends auth.users)
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
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

-- Auto-update updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE PROCEDURE update_updated_at_column();

-- Locations table
CREATE TABLE locations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  location_name TEXT NOT NULL,
  address TEXT NOT NULL,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TRIGGER update_locations_updated_at
  BEFORE UPDATE ON locations
  FOR EACH ROW
  EXECUTE PROCEDURE update_updated_at_column();

-- Permits table
CREATE TABLE permits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  permit_number TEXT UNIQUE NOT NULL,
  plate_number TEXT NOT NULL,
  expiry_date TIMESTAMPTZ NOT NULL,
  location TEXT NOT NULL,
  holder_name TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TRIGGER update_permits_updated_at
  BEFORE UPDATE ON permits
  FOR EACH ROW
  EXECUTE PROCEDURE update_updated_at_column();

-- Active reports table
CREATE TABLE active_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_role TEXT NOT NULL,
  plate_number TEXT NOT NULL,
  reported_by UUID REFERENCES users(id) ON DELETE SET NULL,
  additional_notes TEXT,
  attached_image TEXT,
  submit_time TIMESTAMPTZ DEFAULT now(),
  car_details TEXT NOT NULL
);

-- History reports table
CREATE TABLE history_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_role TEXT NOT NULL,
  plate_number TEXT NOT NULL,
  reported_by UUID REFERENCES users(id) ON DELETE SET NULL,
  additional_notes TEXT,
  attached_image TEXT,
  tow_date TIMESTAMPTZ DEFAULT now(),
  car_details TEXT NOT NULL,
  status TEXT DEFAULT 'completed'
);

-- Towing entries table
CREATE TABLE towing_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  plate_number TEXT NOT NULL,
  violation_type TEXT NOT NULL,
  tow_date TIMESTAMPTZ DEFAULT now(),
  location TEXT NOT NULL,
  towed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  additional_notes TEXT,
  image_path TEXT
);

-- Create indexes for performance
CREATE INDEX idx_active_reports_plate_number ON active_reports(plate_number);
CREATE INDEX idx_active_reports_submit_time ON active_reports(submit_time DESC);
CREATE INDEX idx_history_reports_plate_number ON history_reports(plate_number);
CREATE INDEX idx_history_reports_tow_date ON history_reports(tow_date DESC);
CREATE INDEX idx_towing_entries_plate_number ON towing_entries(plate_number);
CREATE INDEX idx_towing_entries_tow_date ON towing_entries(tow_date DESC);
```

---

## Row Level Security (RLS)

### Policy File: `lib/supabase/supabase_policies.sql`

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE permits ENABLE ROW LEVEL SECURITY;
ALTER TABLE active_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE history_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE towing_entries ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view all profiles"
  ON users FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Allow insert during signup"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Locations policies (public read, authenticated write)
CREATE POLICY "Public can view locations"
  ON locations FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert locations"
  ON locations FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update locations"
  ON locations FOR UPDATE
  USING (auth.role() = 'authenticated');

-- Permits policies
CREATE POLICY "Authenticated users can view permits"
  ON permits FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert permits"
  ON permits FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Active reports policies
CREATE POLICY "Authenticated users can view active reports"
  ON active_reports FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can create reports"
  ON active_reports FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update own reports"
  ON active_reports FOR UPDATE
  USING (reported_by = auth.uid());

CREATE POLICY "Users can delete own reports"
  ON active_reports FOR DELETE
  USING (reported_by = auth.uid());

-- History reports policies
CREATE POLICY "Authenticated users can view history"
  ON history_reports FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert history"
  ON history_reports FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Towing entries policies
CREATE POLICY "Authenticated users can view towing entries"
  ON towing_entries FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can create towing entries"
  ON towing_entries FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update own towing entries"
  ON towing_entries FOR UPDATE
  USING (towed_by = auth.uid());
```

---

## Authentication

### Auth Flow

**1. Sign Up**:
```dart
// Create auth user
final response = await Supabase.instance.client.auth.signUp(
  email: email,
  password: password,
  data: {'full_name': fullName}, // User metadata
);

// Create profile in users table
await Supabase.instance.client.from('users').insert({
  'id': response.user!.id,
  'email': email,
  'full_name': fullName,
  'role': 'user',
  'is_active': true,
  'metadata': {},
});
```

**2. Login**:
```dart
final response = await Supabase.instance.client.auth.signInWithPassword(
  email: email,
  password: password,
);

// Fetch user profile
final userProfile = await Supabase.instance.client
    .from('users')
    .select()
    .eq('id', response.user!.id)
    .single();
```

**3. OTP Verification**:
```dart
// Send OTP
await Supabase.instance.client.auth.signInWithOtp(email: email);

// Verify OTP
await Supabase.instance.client.auth.verifyOTP(
  email: email,
  token: otp,
  type: OtpType.email,
);
```

**4. Password Reset**:
```dart
// Send reset email with deep link
await Supabase.instance.client.auth.resetPasswordForEmail(
  email,
  redirectTo: 'parkmywhip://reset-password',
);

// Update password (after deep link opens app)
await Supabase.instance.client.auth.updateUser(
  UserAttributes(password: newPassword),
);
```

**5. Logout**:
```dart
await Supabase.instance.client.auth.signOut();
```

**6. Check Session**:
```dart
final session = Supabase.instance.client.auth.currentSession;
if (session != null) {
  // User is logged in
  final userId = session.user.id;
}
```

---

## Database Operations

### Query Patterns

**1. Select All**:
```dart
final response = await Supabase.instance.client
    .from('locations')
    .select();

final locations = response.map((json) => LocationModel.fromJson(json)).toList();
```

**2. Select Single**:
```dart
final response = await Supabase.instance.client
    .from('users')
    .select()
    .eq('id', userId)
    .single();

final user = SupabaseUserModel.fromJson(response);
```

**3. Select with Filters**:
```dart
final response = await Supabase.instance.client
    .from('active_reports')
    .select()
    .eq('reported_by', userId)
    .gte('submit_time', DateTime.now().subtract(Duration(days: 7)).toIso8601String())
    .order('submit_time', ascending: false)
    .limit(50);
```

**4. Insert**:
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

**5. Update**:
```dart
await Supabase.instance.client
    .from('users')
    .update({'full_name': newName, 'updated_at': DateTime.now().toIso8601String()})
    .eq('id', userId);
```

**6. Delete**:
```dart
await Supabase.instance.client
    .from('active_reports')
    .delete()
    .eq('id', reportId);
```

**7. Count**:
```dart
final response = await Supabase.instance.client
    .from('active_reports')
    .select('*', const FetchOptions(count: CountOption.exact));

final count = response.count;
```

---

## Real-time Subscriptions (Future Feature)

```dart
// Listen to new active reports
final subscription = Supabase.instance.client
    .from('active_reports')
    .stream(primaryKey: ['id'])
    .listen((List<Map<String, dynamic>> data) {
      final reports = data.map((json) => ActiveReportModel.fromJson(json)).toList();
      // Update UI
    });

// Cancel subscription
await subscription.cancel();
```

---

## Storage (Future Feature)

```dart
// Upload image
final file = File(imagePath);
final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

await Supabase.instance.client.storage
    .from('violation-images')
    .upload('public/$fileName', file);

// Get public URL
final imageUrl = Supabase.instance.client.storage
    .from('violation-images')
    .getPublicUrl('public/$fileName');
```

---

## Error Handling

### Common Supabase Errors

```dart
try {
  await Supabase.instance.client.auth.signInWithPassword(...);
} catch (e) {
  if (e is AuthException) {
    switch (e.message) {
      case 'Invalid login credentials':
        // Show "Invalid email or password"
        break;
      case 'Email not confirmed':
        // Show "Please verify your email"
        break;
      case 'User already registered':
        // Show "Account already exists"
        break;
      default:
        // Show e.message
    }
  } else if (e is PostgrestException) {
    // Database error
    log('Database error: ${e.message}', level: 900);
  } else {
    // Network or other error
    log('Unexpected error: $e', level: 900);
  }
}
```

---

## Testing with Supabase

### Mock Supabase Client

```dart
class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient mockClient;
  late SupabaseAuthRemoteDataSource dataSource;

  setUp(() {
    mockClient = MockSupabaseClient();
    dataSource = SupabaseAuthRemoteDataSource(supabaseClient: mockClient);
  });

  test('login success', () async {
    // Arrange
    when(() => mockClient.auth.signInWithPassword(...))
        .thenAnswer((_) async => AuthResponse(...));

    // Act
    final user = await dataSource.loginWithEmailAndPassword(...);

    // Assert
    expect(user.email, 'test@example.com');
  });
}
```

---

## Security Best Practices

### 1. Never Expose Service Role Key
- Only use `anon` key in Flutter app
- Service role key should only be used in backend/server-side code

### 2. Use RLS Policies
- Always enable RLS on tables
- Define precise policies for each operation
- Test policies thoroughly

### 3. Validate on Backend
- Don't trust client-side validation alone
- Use database constraints and triggers
- Implement server-side validation in Edge Functions (future)

### 4. Secure File Uploads
- Validate file types and sizes
- Use secure bucket policies
- Scan uploads for malware (future)

### 5. Rate Limiting
- Implement rate limiting on auth endpoints
- Use Supabase's built-in rate limiting features

---

## Performance Optimization

### 1. Indexing
```sql
-- Create indexes on frequently queried columns
CREATE INDEX idx_active_reports_plate_number ON active_reports(plate_number);
CREATE INDEX idx_active_reports_submit_time ON active_reports(submit_time DESC);
```

### 2. Query Optimization
```dart
// ✅ Good - Select only needed columns
.select('id, plate_number, submit_time')

// ❌ Bad - Select all columns unnecessarily
.select('*')

// ✅ Good - Use pagination
.range(0, 49)  // First 50 records

// ✅ Good - Use proper ordering
.order('submit_time', ascending: false)
```

### 3. Caching
```dart
// Cache frequently accessed data locally
final cachedUser = await SharedPreferences.getInstance().getString('user_data');
if (cachedUser != null) {
  return SupabaseUserModel.fromJson(jsonDecode(cachedUser));
}

// Fetch from Supabase if not cached
final user = await _fetchFromSupabase();
await SharedPreferences.getInstance().setString('user_data', jsonEncode(user.toJson()));
```

---

## Troubleshooting

### Common Issues

**1. "Failed to fetch" error**:
- Check Supabase URL and anon key
- Verify network connection
- Check CORS settings in Supabase dashboard

**2. "Row Level Security policy violation"**:
- Verify RLS policies are correct
- Check if user is authenticated
- Test policies with different user roles

**3. "Invalid JWT" error**:
- Session expired - re-authenticate user
- Check if token is properly stored
- Verify auth flow is correct

**4. Deep link not opening app**:
- Verify deep link configuration in Android/iOS
- Check `redirectTo` URL format
- Test deep link with Android Studio/Xcode

---

## Summary

Supabase provides:
- **Authentication** with email/password and OTP
- **PostgreSQL database** with type-safe queries
- **Row Level Security** for data protection
- **Real-time subscriptions** (future)
- **File storage** (future)
- **Deep linking** for password reset
- **Automatic timestamps** with triggers
- **Comprehensive error handling**
- **Performance optimization** with indexes

The integration is production-ready and follows security best practices.
