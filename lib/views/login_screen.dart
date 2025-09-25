import 'package:absensi_apps/api/register_user.dart';
import 'package:absensi_apps/extension/navigation.dart';
import 'package:absensi_apps/shared_preferences.dart/shared_preference.dart';
import 'package:absensi_apps/utils/copy_right_screen.dart';
import 'package:absensi_apps/views/buttom_nav.dart';
import 'package:absensi_apps/views/forgot_password_screen.dart';
import 'package:absensi_apps/views/register_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const id = "/login_screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isVisibility = false;
  String? errorMessage;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      try {
        final loginResponse = await AuthenticationAPI.loginUser(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        PreferenceHandler.saveToken(loginResponse.data?.token ?? '');
        context.pushReplacement(ButtomNav());
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login gagal: $e')));
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
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 221,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/foto ppkd.jpeg"),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 221,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(141, 0, 0, 0),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 90, left: 140),
                child: Text(
                  "KelasHadir",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontFamily: "Knicknack",
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "Selamat Datang",
            style: TextStyle(fontSize: 20, fontFamily: "StageGrotesk_Bold"),
          ),
          SizedBox(height: 30),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error message
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 10),

                Text(
                  "Email",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "StageGrotesk_Regular",
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 350,
                  height: 50,
                  child: TextFormField(
                    controller: emailController,
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
                      contentPadding: EdgeInsets.only(top: 10),
                      prefixIcon: Transform.translate(
                        offset: Offset(0, -1),
                        child: Icon(Icons.email),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "Email Anda",
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "Password",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "StageGrotesk_Regular",
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 350,
                  height: 50,
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: !isVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 10),
                      prefixIcon: Transform.translate(
                        offset: Offset(0, -1),
                        child: Icon(Icons.lock),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "Password Anda",
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isVisibility = !isVisibility;
                          });
                        },
                        icon: Icon(
                          isVisibility
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.pushNamed(ForgotPasswordScreen.id);
                  },
                  child: Text(
                    "Lupa password?",
                    style: TextStyle(
                      fontFamily: "StageGrotesk_Regular",
                      color: Color(0xFF1E3A8A),
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 56,
                  width: 350,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Masuk",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: "StageGrotesk_Bold",
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 100),
                  child: Text.rich(
                    TextSpan(
                      text: "Belum punya akun? ",
                      style: TextStyle(
                        color: const Color.fromARGB(182, 100, 100, 106),
                        fontFamily: "StageGrotesk_Regular",
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.push(RegisterScreen());
                            },
                          text: " Daftar",
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color.fromARGB(255, 11, 39, 164),
                            fontFamily: "StageGrotesk_Bold",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(CopyRightScreen.cc, height: 20, width: 20),
              SizedBox(width: 10),
              Text("By Triana Julianingsih"),
            ],
          ),
        ],
      ),
    );
  }
}
