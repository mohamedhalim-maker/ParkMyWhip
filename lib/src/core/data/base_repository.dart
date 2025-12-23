import 'package:park_my_whip/src/core/data/result.dart';

/// Base repository interface for common CRUD operations
/// Provides a consistent API across all repositories
abstract class BaseRepository<T> {
  /// Fetch all entities
  Future<Result<List<T>>> getAll();
  
  /// Fetch a single entity by ID
  Future<Result<T>> getById(String id);
  
  /// Create a new entity
  Future<Result<void>> create(T entity);
  
  /// Update an existing entity
  Future<Result<void>> update(T entity);
  
  /// Delete an entity by ID
  Future<Result<void>> delete(String id);
}

/// Extended repository with filtering capabilities
abstract class FilterableRepository<T, F> extends BaseRepository<T> {
  /// Fetch entities with filters applied
  Future<Result<List<T>>> getFiltered(F filter);
}
