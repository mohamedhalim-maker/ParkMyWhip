import 'package:park_my_whip/src/core/helpers/app_logger.dart';
import 'package:park_my_whip/src/core/data/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Generic Supabase data source for CRUD operations
/// Provides reusable database operations with type safety
class SupabaseDataSource<T> {
  final SupabaseClient _client;
  final String tableName;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  SupabaseDataSource({
    required this.tableName,
    required this.fromJson,
    required this.toJson,
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  /// Fetch all records from table
  Future<Result<List<T>>> getAll() async {
    try {
      AppLogger.database('Fetching all records from $tableName');
      
      final response = await _client.from(tableName).select();
      
      final items = (response as List)
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();
      
      AppLogger.database('Fetched ${items.length} records from $tableName');
      return Success(items);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch from $tableName', 
          name: 'Database', error: e, stackTrace: stackTrace);
      return Failure('Failed to load data', e as Exception?);
    }
  }

  /// Fetch a single record by ID
  Future<Result<T>> getById(String id) async {
    try {
      AppLogger.database('Fetching record from $tableName with id: $id');
      
      final response = await _client
          .from(tableName)
          .select()
          .eq('id', id)
          .single();
      
      final item = fromJson(response as Map<String, dynamic>);
      return Success(item);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch record from $tableName', 
          name: 'Database', error: e, stackTrace: stackTrace);
      return Failure('Failed to load record', e as Exception?);
    }
  }

  /// Insert a new record
  Future<Result<void>> insert(T entity) async {
    try {
      AppLogger.database('Inserting record into $tableName');
      
      await _client.from(tableName).insert(toJson(entity));
      
      AppLogger.database('Successfully inserted record into $tableName');
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to insert into $tableName', 
          name: 'Database', error: e, stackTrace: stackTrace);
      return Failure('Failed to create record', e as Exception?);
    }
  }

  /// Update an existing record
  Future<Result<void>> update(String id, T entity) async {
    try {
      AppLogger.database('Updating record in $tableName with id: $id');
      
      await _client
          .from(tableName)
          .update(toJson(entity))
          .eq('id', id);
      
      AppLogger.database('Successfully updated record in $tableName');
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update $tableName', 
          name: 'Database', error: e, stackTrace: stackTrace);
      return Failure('Failed to update record', e as Exception?);
    }
  }

  /// Delete a record by ID
  Future<Result<void>> delete(String id) async {
    try {
      AppLogger.database('Deleting record from $tableName with id: $id');
      
      await _client
          .from(tableName)
          .delete()
          .eq('id', id);
      
      AppLogger.database('Successfully deleted record from $tableName');
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete from $tableName', 
          name: 'Database', error: e, stackTrace: stackTrace);
      return Failure('Failed to delete record', e as Exception?);
    }
  }

  /// Execute a custom query with filters
  Future<Result<List<T>>> query(
    Future<dynamic> Function(PostgrestFilterBuilder) buildQuery,
  ) async {
    try {
      AppLogger.database('Executing custom query on $tableName');
      
      final queryBuilder = _client.from(tableName).select();
      final response = await buildQuery(queryBuilder);
      
      final items = (response as List)
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();
      
      AppLogger.database('Query returned ${items.length} records from $tableName');
      return Success(items);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to execute query on $tableName', 
          name: 'Database', error: e, stackTrace: stackTrace);
      return Failure('Failed to load data', e as Exception?);
    }
  }
}
