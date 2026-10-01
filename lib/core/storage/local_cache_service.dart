import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  static LocalCacheService? _instance;
  static SharedPreferences? _prefs;

  LocalCacheService._();

  static Future<LocalCacheService> getInstance() async {
    _instance ??= LocalCacheService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> saveJson(String key, dynamic jsonMap) async {
    await _prefs?.setString(key, jsonEncode(jsonMap));
  }

  dynamic getJson(String key) {
    final str = _prefs?.getString(key);
    if (str == null) return null;
    try {
      return jsonDecode(str);
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
