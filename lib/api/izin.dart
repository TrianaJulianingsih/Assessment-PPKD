// lib/api/izin_api.dart
// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:absensi_apps/api/endpoint/endpoint.dart';
import 'package:absensi_apps/models/izin_model.dart';
import 'package:absensi_apps/shared_preferences.dart/shared_preference.dart';
import 'package:http/http.dart' as http;

class IzinAPI {
  static Future<IzinModel?> postIzin({
    required String date,
    required String alasan,
  }) async {
    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) {
        print("Token tidak ada");
        return null;
      }

      final response = await http.post(
        Uri.parse(Endpoint.izin), 
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"date": date, "alasan_izin": alasan}),
      );

      print("Response Izin: ${response.body}");

      if (response.statusCode == 200) {
        return izinModelFromJson(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Error postIzin: $e");
      return null;
    }
  }
}