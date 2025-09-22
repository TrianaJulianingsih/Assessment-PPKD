// lib/api/absen_stats_api.dart
// ignore_for_file: avoid_print

import 'package:absensi_apps/api/endpoint/endpoint.dart';
import 'package:absensi_apps/models/absen_stats_model.dart';
import 'package:absensi_apps/shared_preferences.dart/shared_preference.dart';
import 'package:http/http.dart' as http;

class StatistikAPI {
  static Future<AbsenStatsModel> getStats() async {
    final token = await PreferenceHandler.getToken();
    if (token == null) {
      return AbsenStatsModel(); 
    }

    final response = await http.get(
      Uri.parse(Endpoint.absenStats),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("Stats response: ${response.statusCode} ${response.body}");

    if (response.statusCode == 200) {
      return absenStatsModelFromJson(response.body);
    }
    return AbsenStatsModel(); 
  }
}
