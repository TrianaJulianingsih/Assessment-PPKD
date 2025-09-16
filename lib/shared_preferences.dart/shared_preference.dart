import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String tokenKey = "token";
  static const String userIdKey = "user_id";
  static const String userEmailKey = "user_email";
  static const String userNameKey = "user_name";
  static const String loginKey = "login";

  static Future<void> saveUserData(
    String token,
    int userId,
    String email,
    String name,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setInt(userIdKey, userId);
    await prefs.setString(userEmailKey, email);
    await prefs.setString(userNameKey, name);
    await prefs.setBool(loginKey, true);
  }

  static void saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(userIdKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  static Future<bool?> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginKey);
  }

  static Future<bool?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userIdKey);
    await prefs.remove(userEmailKey);
    await prefs.remove(userNameKey);
    await prefs.setBool(loginKey, false);
  }
}
