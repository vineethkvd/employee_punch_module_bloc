import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences prefs;
  LocalStorage(this.prefs);

  Future<void> saveTokens(String access, String refresh) async {
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  String? getAccessToken() => prefs.getString('access_token');
  
  Future<void> clearTokens() async {
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
}
