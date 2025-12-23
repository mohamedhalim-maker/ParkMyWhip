/// Result type for handling success and failure states
/// Provides type-safe error handling without throwing exceptions
sealed class Result<T> {
  const Result();
}

/// Represents a successful operation with data
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Represents a failed operation with error details
class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;
  
  const Failure(this.message, [this.exception]);
}

/// Extension methods for easier result handling
extension ResultExtensions<T> on Result<T> {
  /// Check if result is success
  bool get isSuccess => this is Success<T>;
  
  /// Check if result is failure
  bool get isFailure => this is Failure<T>;
  
  /// Get data if success, null otherwise
  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;
  
  /// Get error message if failure, null otherwise
  String? get errorOrNull => this is Failure<T> ? (this as Failure<T>).message : null;
  
  /// Execute callback if success
  void ifSuccess(void Function(T data) callback) {
    if (this is Success<T>) {
      callback((this as Success<T>).data);
    }
  }
  
  /// Execute callback if failure
  void ifFailure(void Function(String message) callback) {
    if (this is Failure<T>) {
      callback((this as Failure<T>).message);
    }
  }
  
  /// Transform success data
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(:final data) => Success(transform(data)),
      Failure<T>(:final message, :final exception) => Failure(message, exception),
    };
  }
}
