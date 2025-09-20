// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:absensi_apps/api/endpoint/endpoint.dart';
import 'package:absensi_apps/models/absen_check_out_model.dart';
import 'package:absensi_apps/models/absen_masuk_model.dart';
import 'package:absensi_apps/models/absen_today.dart';
import 'package:absensi_apps/shared_preferences.dart/shared_preference.dart';
import 'package:http/http.dart' as http;

class AttendanceAPI {
  static Future<AbsenCheckInModel?> checkIn({
    required String attendanceDate,
    required String checkIn,
    required double lat,
    required double lng,
    required String address,
  }) async {
    final token = await PreferenceHandler.getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse(Endpoint.checkIn),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "attendance_date": attendanceDate,
        "check_in": checkIn,
        "check_in_lat": lat,
        "check_in_lng": lng,
        "check_in_location": "$lat,$lng",
        "check_in_address": address,
      }),
    );

    print("CheckIn response: ${response.statusCode} ${response.body}");

    if (response.statusCode == 200) {
      return absenCheckInModelFromJson(response.body);
    }
    return null;
  }

  static Future<AbsenCheckOutModel?> checkOut({
    required String attendanceDate,
    required String checkOut,
    required double lat,
    required double lng,
    required String address,
  }) async {
    final token = await PreferenceHandler.getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse(Endpoint.checkOut),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "attendance_date": attendanceDate,
        "check_out": checkOut,
        "check_out_lat": lat,
        "check_out_lng": lng,
        "check_out_location": "$lat,$lng",
        "check_out_address": address,
      }),
    );

    print("CheckOut response: ${response.statusCode} ${response.body}");

    if (response.statusCode == 200) {
      return absenCheckOutModelFromJson(response.body);
    }
    return null;
  }

  static Future<AbsenTodayModel?> getToday() async {
    final token = await PreferenceHandler.getToken();

    if (token == null) {
      print("Token tidak tersedia");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(Endpoint.absenToday),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("getToday status: ${response.statusCode}");
      print("getToday body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);

        if (jsonMap['data'] == null) {
          print("Data absen hari ini null");
          return null;
        }

        return AbsenTodayModel.fromJson(jsonMap);
      } else if (response.statusCode == 401) {
        print("Unauthorized. Token kemungkinan kadaluarsa atau salah");
      } else if (response.statusCode == 403) {
        print("Forbidden. Anda tidak memiliki akses ke endpoint ini");
      } else if (response.statusCode >= 500) {
        print("Server error (${response.statusCode})");
      } else {
        print("Error tidak terduga: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception saat memanggil getToday: $e");
    }

    return null;
  }
}