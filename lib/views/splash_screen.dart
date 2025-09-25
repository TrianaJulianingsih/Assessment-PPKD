import 'package:absensi_apps/shared_preferences.dart/shared_preference.dart';
import 'package:absensi_apps/views/buttom_nav.dart';
import 'package:flutter/material.dart';

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
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final bool isLogin = await PreferenceHandler.getLogin();
    final String? token = await PreferenceHandler.getToken();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      (isLogin && token != null) ? SplashScreen.id : ButtomNav.id,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
