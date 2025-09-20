import 'dart:async';

import 'package:absensi_apps/api/history.dart';
import 'package:absensi_apps/api/profile.dart';
import 'package:absensi_apps/models/get_profile_model.dart';
import 'package:absensi_apps/models/history_absen_model.dart';
import 'package:absensi_apps/shared_preferences.dart/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const id = "/home_screen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: Container(
              height: 100,
              width: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              AssetImage("assets/images/foto ppkd.jpeg")
                                  as ImageProvider,
                          radius: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Selamat ${_getGreeting()}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "StageGrotesk_Regular",
                                ),
                              ),
                              Text(
                                "Triana Julianingsih",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "StageGrotesk_Bold",
                                ),
                              ),
                              Text(
                                "Mobile Programming",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "StageGrotesk_Medium",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20),
            child: Row(
              children: [
                Container(
                  height: 100,
                  width: 170,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Column(
                      children: [
                        Text(
                          "Check In",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "StageGrotesk_Bold",
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "08:00",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "StageGrotesk_Regular",
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  height: 100,
                  width: 170,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          "Check Out",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "StageGrotesk_Bold",
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "15:00",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "StageGrotesk_Regular",
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              height: 200,
              width: 350,
              decoration: BoxDecoration(
                color: Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 40),
                        child: Image.asset(
                          "assets/images/maps.png",
                          height: 20,
                          width: 20,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 40,
                            left: 10,
                            right: 10,
                          ),
                          child: Text(
                            "Jalan Poncol, Ciracas",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "StageGrotesk_Regular",
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Divider(color: Colors.white),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/man-walking.png",
                          width: 30,
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Jarak Lokasi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "StageGrotesk_Regular",
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "450.0 m",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "StageGrotesk_Regular",
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 275, top: 20),
            child: Column(
              children: [
                Text(
                  "Riwayat",
                  style: TextStyle(
                    fontFamily: "StageGrotesk_Bold",
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Pagi';
    } else if (hour < 15) {
      return 'Siang';
    } else if (hour < 19) {
      return 'Sore';
    } else {
      return 'Malam';
    }
  }
}
