import 'package:absensi_apps/api/register_user.dart';
import 'package:absensi_apps/extension/navigation.dart';
import 'package:absensi_apps/models/get_list_training_model.dart';
import 'package:absensi_apps/views/buttom_nav.dart';
import 'package:absensi_apps/views/login_screen.dart';
import 'package:absensi_apps/views/register_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const id = "/login_screen";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // bool isPassword = false;
  bool isVisibility = false;
  String? dropdownSelect;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40),
            Text(
              "Daftar Akun",
              style: TextStyle(fontSize: 20, fontFamily: "StageGrotesk_Bold"),
            ),
            SizedBox(height: 20),
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: const Color.fromARGB(55, 0, 0, 0),
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(image: AssetImage("assets/images/ikon kamera.png",))
              ),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 10),
                        prefixIcon: Transform.translate(
                          offset: Offset(0, -1),
                          child: Icon(Icons.email),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hint: Text("Email Anda"),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
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
                    child: TextField(
                      controller: passwordController,
                      obscureText: !isVisibility,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 10),
                        prefixIcon: Transform.translate(
                          offset: Offset(0, -1),
                          child: Icon(Icons.lock),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hint: Text("Password Anda"),
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
                  SizedBox(height: 10,),
                  Text("Training", style: TextStyle(
                      fontSize: 16,
                      fontFamily: "StageGrotesk_Regular",
                    ),),
                  SizedBox(
                    width: 350,
                    height: 60,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      value: dropdownSelect,
                      hint: Text("Training", style: TextStyle(fontFamily: "StageGrotesk_Regular"),),
                      items: ["Elektronik", "Pakaian", "Makanan", "Lainnya"].map((
                        String value,
                      ) {
                        return DropdownMenuItem(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          dropdownSelect = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text("Batch", style: TextStyle(
                      fontSize: 16,
                      fontFamily: "StageGrotesk_Regular",
                    ),),
                  SizedBox(
                    width: 350,
                    height: 60,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      value: dropdownSelect,
                      hint: Text("Batch", style: TextStyle(fontFamily: "StageGrotesk_Regular")),
                      items: ["Elektronik", "Pakaian", "Makanan", "Lainnya"].map((
                        String value,
                      ) {
                        return DropdownMenuItem(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          dropdownSelect = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 56,
                    width: 350,
                    child: ElevatedButton(
                      onPressed: () {
                        context.pushReplacement(LoginScreen());
                      },
                      child: Text(
                        "Daftar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: "StageGrotesk_Bold",
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1E3A8A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 100),
                    child: Text.rich(
                      TextSpan(
                        text: "Sudah punya akun? ",
                        style: TextStyle(
                          color: const Color.fromARGB(182, 100, 100, 106),
                          fontFamily: "StageGrotesk_Regular",
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.push(LoginScreen());
                              },
                            text: " Masuk",
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
          ],
        ),
      ),
    );
  }
}
