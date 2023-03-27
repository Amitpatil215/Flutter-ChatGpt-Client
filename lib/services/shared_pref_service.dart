import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static final SharedPrefService _instance = SharedPrefService._internal();

  factory SharedPrefService() {
    return _instance;
  }

  SharedPrefService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setValue(String key, dynamic value) async {
    if (_prefs == null) {
      await init();
    }
    if (value is int) {
      _prefs!.setInt(key, value);
    } else if (value is double) {
      _prefs!.setDouble(key, value);
    } else if (value is bool) {
      _prefs!.setBool(key, value);
    } else if (value is String) {
      _prefs!.setString(key, value);
    } else if (value is List<String>) {
      _prefs!.setStringList(key, value);
    } else {
      throw Exception('Unsupported value type');
    }
  }

  dynamic getValue(String key) {
    if (_prefs == null) {
      throw Exception('Shared preferences not initialized');
    }
    return _prefs!.get(key);
  }
}
