import 'package:absensi_apps/utils/copy_right_screen.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  static const id = "/about_screen";

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(178, 97, 199, 247),
      appBar: AppBar(
        title: Text(
          "Tentang Aplikasi",
          style: TextStyle(
            fontFamily: "StageGrotesk_Bold",
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(
                      "assets/images/Kelas Hadir Logo.png",
                    ),
                    radius: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Kelas",
                        style: TextStyle(
                          fontFamily: "StageGrotesk_Medium",
                          color: Color(0xFF1E3A8A),
                          fontSize: 30,
                        ),
                      ),
                      Text(
                        "Hadir",
                        style: TextStyle(
                          fontFamily: "StageGrotesk_Medium",
                          color: Color(0xFF10B981),
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Text(
                      "Kelas Hadir adalah aplikasi absensi kehadiran yang memudahkan guru dan siswa mencatat serta memantau kehadiran secara real time. Dengan Kelas Hadir, proses pencatatan absensi menjadi lebih cepat dan akurat melalui fitur check-in digital, laporan kehadiran otomatis, dan notifikasi pengingat. Aplikasi Kelas Hadir dirancang sebagai solusi manajemen kehadiran yang efisien, memungkinkan institusi pendidikan mengelola data presensi secara terintegrasi dan aman. Tak perlu repot lagi absen manual! Kelas Hadir membantu mencatat kehadiran siswa dan guru hanya dengan satu sentuhan.",
                      style: TextStyle(fontFamily: "StageGrotesk_Regular", fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 120,),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
