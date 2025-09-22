// forgot_password_screen.dart
import 'package:absensi_apps/api/forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:absensi_apps/views/reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  static const id = "/forgot_password_screen";

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  Future<void> _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = null;
        successMessage = null;
      });

      try {
        final response = await ForgotPasswordAPI.sendOtp(
          email: emailController.text.trim(),
        );
        
        setState(() {
          successMessage = response?.message ?? "OTP berhasil dikirim ke email Anda";
        });
        
        // Navigate to reset password screen after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                email: emailController.text.trim(),
              ),
            ),
          );
        });
        
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim OTP: $e')),
        );
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
        title: const Text("Lupa Password"),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Masukkan email Anda untuk menerima kode OTP",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "StageGrotesk_Regular",
                ),
              ),
              const SizedBox(height: 30),
              
              // Error message
              if (errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              
              // Success message
              if (successMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    successMessage!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              const Text(
                "Email",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "StageGrotesk_Bold",
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@')) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "Email Anda",
                ),
              ),
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Kirim OTP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "StageGrotesk_Bold",
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Kembali ke Login",
                  style: TextStyle(
                    fontFamily: "StageGrotesk_Regular", 
                    color: Color(0xFF1E3A8A), 
                    fontSize: 14
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}