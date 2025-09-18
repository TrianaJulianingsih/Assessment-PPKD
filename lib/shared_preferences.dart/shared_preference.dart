import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String tokenKey = "token";
  static const String userIdKey = "user_id";
  static const String userEmailKey = "user_email";
  static const String userNameKey = "user_name";
  static const String batchKey = "batch";
  static const String loginKey = "login";

  static Future<void> saveUserData(
    String token,
    int userId,
    String email,
    String name,
    String batch,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setInt(userIdKey, userId);
    await prefs.setString(userEmailKey, email);
    await prefs.setString(userNameKey, name);
    await prefs.setString(batchKey, batch);
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

  static Future<void> setUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userNameKey, userName);
  }

  static Future<String?> getBatch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(batchKey);
  }

  static Future<void> setBatch(String batch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(batchKey, batch);
  }

  // Di file PreferenceHandler.dart tambahkan method berikut:

  static Future<void> setCheckInTime(String checkInTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('check_in_time', checkInTime);
  }

  static Future<String?> getCheckInTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('check_in_time');
  }

  static Future<void> setCheckInStatus(bool hasCheckedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_checked_in', hasCheckedIn);
  }

  static Future<bool> getCheckInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_checked_in') ?? false;
  }

  static Future<void> clearCheckInData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('check_in_time');
    await prefs.remove('has_checked_in');
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
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove(tokenKey);
    // await prefs.remove(userIdKey);
    // await prefs.remove(userEmailKey);
    // await prefs.remove(userNameKey);
    // await prefs.setBool(loginKey, false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.setBool('login', false);
  }
}
