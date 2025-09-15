import 'package:absensi_apps/extension/navigation.dart';
import 'package:absensi_apps/shared_preferences.dart/shared_preference.dart';
import 'package:absensi_apps/utils/app_image.dart';
import 'package:absensi_apps/views/buttom_nav.dart';
import 'package:absensi_apps/views/login_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const id = "/splash_screen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState(){
    super.initState();
    isLogin();
  }

  void isLogin()async{
    bool? isLogin = await PreferenceHandler.getLogin();

    Future.delayed(Duration(seconds: 3)).then((value) async{
      print(isLogin);
      if(isLogin == true){
        context.pushReplacementNamed(ButtomNav.id);
      } else{
        context.push(LoginScreen());
      }
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 800,
              width: 400,
              child: Lottie.asset(AppImage.logo),
            )
          ],
        ),
      ),
    );
  }
}