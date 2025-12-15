import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
    log('SharedPrefHelper : data with key : $key has been removed');
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(key);
  }

  Future<void> clearAllData() async {
    log('SharedPrefHelper : all data has been cleared');
    final SharedPreferences prefs = await _prefs;
    await prefs.clear();
  }

  Future<void> setData({required String key, required dynamic value}) async {
    final SharedPreferences prefs = await _prefs;
    log('SharedPrefHelper : setData with key : $key and value : $value');
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else {
      log('SharedPrefHelper : Unsupported type for key : $key');
    }
  }

  Future<bool> getBool({required String key, bool defaultValue = false}) async {
    final SharedPreferences prefs = await _prefs;
    log('SharedPrefHelper : getBool with key : $key');
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<double> getDouble({
    required String key,
    double defaultValue = 0.0,
  }) async {
    final SharedPreferences prefs = await _prefs;
    log('SharedPrefHelper : getDouble with key : $key');
    return prefs.getDouble(key) ?? defaultValue;
  }

  Future<int> getInt({required String key, int defaultValue = 0}) async {
    final SharedPreferences prefs = await _prefs;
    log('SharedPrefHelper : getInt with key : $key');
    return prefs.getInt(key) ?? defaultValue;
  }

  Future<String?> getString({required String key}) async {
    final SharedPreferences prefs = await _prefs;
    log('SharedPrefHelper : getString with key : $key');
    return prefs.getString(key);
  }

  Future<void> setSecuredString({
    required String key,
    required String value,
  }) async {
    log('FlutterSecureStorage : setSecuredString with key : $key and value : $value');
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecuredString({required String key}) async {
    log('FlutterSecureStorage : getSecuredString with key : $key');
    return _secureStorage.read(key: key);
  }

  Future<void> clearAllSecuredData() async {
    log('FlutterSecureStorage : all data has been cleared');
    await _secureStorage.deleteAll();
  }
}
