import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized logging utility for the app.
/// Uses dart:developer log function for better debugging experience.
/// 
/// Log Levels:
/// - DEBUG (500): Detailed debugging information
/// - INFO (800): General informational messages
/// - WARNING (900): Warning messages
/// - ERROR (1000): Error messages with stack traces
/// - SUCCESS (1000): Successful operations
class AppLogger {
  AppLogger._();

  static const int _debugLevel = 500;
  static const int _infoLevel = 800;
  static const int _warningLevel = 900;
  static const int _errorLevel = 1000;
  static const int _successLevel = 1000;

  /// Log a debug message (only in debug mode)
  static void debug(String message, {String? name}) {
    if (kDebugMode) {
      developer.log(message, name: name ?? 'DEBUG', level: _debugLevel);
    }
  }

  /// Log an informational message
  static void info(String message, {String? name}) {
    developer.log(message, name: name ?? 'INFO', level: _infoLevel);
  }

  /// Log a success message
  static void success(String message, {String? name}) {
    developer.log(message, name: name ?? 'SUCCESS', level: _successLevel);
  }

  /// Log a warning message
  static void warning(String message, {String? name}) {
    developer.log(message, name: name ?? 'WARNING', level: _warningLevel);
  }

  /// Log an error message with optional error and stack trace
  static void error(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: name ?? 'ERROR',
      level: _errorLevel,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // ========== Domain-Specific Loggers ==========

  /// Log authentication related messages
  static void auth(String message, {bool isError = false}) {
    developer.log(
      message,
      name: 'Auth',
      level: isError ? _errorLevel : _infoLevel,
    );
  }

  /// Log database/Supabase related messages
  static void database(String message, {bool isError = false}) {
    developer.log(
      message,
      name: 'Database',
      level: isError ? _errorLevel : _infoLevel,
    );
  }

  /// Log network/API related messages
  static void network(String message, {bool isError = false}) {
    developer.log(
      message,
      name: 'Network',
      level: isError ? _errorLevel : _infoLevel,
    );
  }

  /// Log storage (SharedPreferences, cache) related messages
  static void storage(String message, {bool isError = false}) {
    developer.log(
      message,
      name: 'Storage',
      level: isError ? _errorLevel : _infoLevel,
    );
  }

  /// Log navigation related messages
  static void navigation(String message) {
    developer.log(message, name: 'Navigation', level: _infoLevel);
  }

  /// Log deep link related messages
  static void deepLink(String message) {
    developer.log(message, name: 'DeepLink', level: _infoLevel);
  }

  /// Log state management (Cubit) related messages
  static void cubit(String message, {String? cubitName}) {
    developer.log(
      message,
      name: cubitName ?? 'Cubit',
      level: _infoLevel,
    );
  }
}
