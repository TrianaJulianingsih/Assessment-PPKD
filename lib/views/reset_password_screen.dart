// reset_password_screen.dart
import 'package:absensi_apps/api/reset_password.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});
  static const id = "/reset_password_screen";

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  String? errorMessage;
  String? successMessage;

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = null;
        successMessage = null;
      });

      try {
        final response = await ResetPasswordAPI.resetPassword(
          email: widget.email,
          otp: otpController.text.trim(),
          password: newPasswordController.text.trim(),
        );

        setState(() {
          successMessage = response?.message ?? "Password berhasil direset";
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage!)));
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/login_screen",
            (Route<dynamic> route) => false,
          );
        });
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal reset password: $e')));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset Password"),
        backgroundColor: Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  "Reset password untuk: ${widget.email}",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "StageGrotesk_Regular",
                  ),
                ),
                SizedBox(height: 30),
                if (errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                if (successMessage != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      successMessage!,
                      style: TextStyle(color: Colors.green),
                    ),
                  ),

                SizedBox(height: 20),
                Text(
                  "Kode OTP",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "StageGrotesk_Bold",
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kode OTP tidak boleh kosong';
                    }
                    if (value.length < 4) {
                      return 'Kode OTP minimal 4 digit';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_clock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Masukkan kode OTP",
                    hintStyle: TextStyle(fontFamily: "StageGrotesk_Regular"),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Password Baru",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "StageGrotesk_Bold",
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: !isNewPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password baru tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Masukkan password baru",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isNewPasswordVisible = !isNewPasswordVisible;
                        });
                      },
                      icon: Icon(
                        isNewPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  "Konfirmasi Password Baru",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "StageGrotesk_Bold",
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !isConfirmPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password tidak boleh kosong';
                    }
                    if (value != newPasswordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Konfirmasi password baru",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                      icon: Icon(
                        isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Reset Password",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: "StageGrotesk_Bold",
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Kembali",
                    style: TextStyle(
                      fontFamily: "StageGrotesk_Regular",
                      color: Color(0xFF1E3A8A),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
