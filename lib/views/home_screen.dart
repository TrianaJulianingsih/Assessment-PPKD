import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const id = "/home_screen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50),
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
                          backgroundImage: AssetImage(
                            "assets/images/foto ppkd.jpeg",
                          ),
                          radius: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Selamat Pagi"),
                              Text("Triana Julianingsih"),
                              Text("Mobile Programming"),
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
                          "12:30",
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
                        "12:30",
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
                      Padding(
                        padding: const EdgeInsets.only(top: 40, left: 10),
                        child: Text(
                          "Jalan Nusa Indah, Ciracas, Jakarta Timur",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "StageGrotesk_Regular",
                            fontSize: 16,
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
                                "450.0",
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
}
