import 'package:absensi_apps/shared_preferences.dart/shared_preference.dart';
import 'package:absensi_apps/utils/app_image.dart';
import 'package:absensi_apps/views/buttom_nav.dart';
import 'package:absensi_apps/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const id = "/splash_screen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    isLogin();
  }

  void isLogin() async {
    final isLogin = await PreferenceHandler.getLogin();

    final token = await PreferenceHandler.getToken();

    await Future.delayed(const Duration(seconds: 5));

    if (isLogin == true && token != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ButtomNav()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Lottie.asset(AppImage.logo)],
        ),
      ),
    );
  }
}
