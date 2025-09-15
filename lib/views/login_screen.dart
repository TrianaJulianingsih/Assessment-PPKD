import 'package:absensi_apps/extension/navigation.dart';
import 'package:absensi_apps/utils/copy_right_screen.dart';
import 'package:absensi_apps/views/buttom_nav.dart';
import 'package:absensi_apps/views/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

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
  // bool isPassword = false;
  bool isVisibility = false;
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
          SizedBox(height: 20,),
          Text("Selamat Datang", style: TextStyle(fontSize: 20, fontFamily: "StageGrotesk_Bold"),),
          SizedBox(height: 30),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Email", style: TextStyle(fontSize: 16, fontFamily: "StageGrotesk_Regular")),
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
                SizedBox(height: 30),
                Text("Password", style: TextStyle(fontSize: 16, fontFamily: "StageGrotesk_Regular")),
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
                            )
                    ),
                    
                  ),
                ),
                Text("Lupa password?", style: TextStyle(fontFamily: "StageGrotesk_Regular"),),
                SizedBox(height: 20),
                SizedBox(
                  height: 56,
                  width: 350,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pushReplacement(ButtomNav());
                    },
                    child: Text(
                      "Masuk",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: "StageGrotesk_Bold"),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
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
          SizedBox(height: 150,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(CopyRightScreen.cc, height: 20, width: 20,),
              SizedBox(width: 10,),
              Text("By Triana Julianingsih")
            ],
          )
        ],
      ),
    );
  }
}
