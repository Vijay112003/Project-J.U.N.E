import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static Future<bool> hasAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> setAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<void> deleteAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}
