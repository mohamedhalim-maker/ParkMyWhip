import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:park_my_whip/src/core/helpers/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  SharedPrefHelper({
    SharedPreferences? sharedPreferences,
    FlutterSecureStorage? secureStorage,
  })  : _sharedPreferences = sharedPreferences,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  SharedPreferences? _sharedPreferences;
  final FlutterSecureStorage _secureStorage;

  Future<SharedPreferences> get _prefs async =>
      _sharedPreferences ??= await SharedPreferences.getInstance();

  Future<void> removeData(String key) async {
    AppLogger.storage('Data removed with key: $key');
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(key);
  }

  Future<void> clearAllData() async {
    AppLogger.storage('All SharedPreferences data cleared');
    final SharedPreferences prefs = await _prefs;
    await prefs.clear();
  }

  Future<void> setData({required String key, required dynamic value}) async {
    final SharedPreferences prefs = await _prefs;
    AppLogger.debug('Set data with key: $key', name: 'Storage');
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else {
      AppLogger.warning('Unsupported type for key: $key', name: 'Storage');
    }
  }

  Future<bool> getBool({required String key, bool defaultValue = false}) async {
    final SharedPreferences prefs = await _prefs;
    AppLogger.debug('Get bool with key: $key', name: 'Storage');
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<double> getDouble({
    required String key,
    double defaultValue = 0.0,
  }) async {
    final SharedPreferences prefs = await _prefs;
    AppLogger.debug('Get double with key: $key', name: 'Storage');
    return prefs.getDouble(key) ?? defaultValue;
  }

  Future<int> getInt({required String key, int defaultValue = 0}) async {
    final SharedPreferences prefs = await _prefs;
    AppLogger.debug('Get int with key: $key', name: 'Storage');
    return prefs.getInt(key) ?? defaultValue;
  }

  Future<String?> getString({required String key}) async {
    final SharedPreferences prefs = await _prefs;
    AppLogger.debug('Get string with key: $key', name: 'Storage');
    return prefs.getString(key);
  }

  Future<void> setSecuredString({
    required String key,
    required String value,
  }) async {
    AppLogger.debug('Set secured string with key: $key', name: 'Storage');
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecuredString({required String key}) async {
    AppLogger.debug('Get secured string with key: $key', name: 'Storage');
    return _secureStorage.read(key: key);
  }

  Future<void> clearAllSecuredData() async {
    AppLogger.storage('All secure storage data cleared');
    await _secureStorage.deleteAll();
  }
}
