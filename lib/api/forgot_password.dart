// forgot_password_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:absensi_apps/api/endpoint/endpoint.dart';
import 'package:absensi_apps/models/forgot_password_model.dart';

class ForgotPasswordAPI {
  static Future<ForgotPasswordModel?> sendOtp({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Endpoint.forgotPassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        return ForgotPasswordModel.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Gagal mengirim OTP: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
}