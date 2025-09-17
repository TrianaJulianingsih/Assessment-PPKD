import 'package:absensi_apps/views/login_screen.dart';
import 'package:absensi_apps/views/presence_screen.dart';
import 'package:absensi_apps/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi Apps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'StageGrotesk_Regular',
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('id', 'ID'), // Indonesian
      ],
      home: SplashScreen(),
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        PresenceScreen.id: (context) => PresenceScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
