class Endpoint{
  static const String baseURL = "https://appabsensi.mobileprojp.com/";
  static const String register = "$baseURL/api/register";
  static const String login = "$baseURL/api/login";
  static const String checkIn = "$baseURL/api/absen/check-in";
  static const String checkOut = "$baseURL/api/absen/check-out";
  static const String izin = "$baseURL/api/izin";
  static const String deviceToken = "$baseURL/api/device-token";
  static const String absenToday = "$baseURL/api/absen/today?attendance_date";
  static const String absenStats = "$baseURL/api/absen/today?stats?";
  static const String deleteAbsen = "$baseURL/api/absen/today?attendance_date";
  static const String profile = "$baseURL/api/profile";
  static const String training = "$baseURL/api/trainings";
}