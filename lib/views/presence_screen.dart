import 'package:flutter/material.dart';

class PresenceScreen extends StatefulWidget {
  const PresenceScreen({super.key});
  static const id = "/presence_screen";

  @override
  State<PresenceScreen> createState() => _PresenceScreenState();
}

class _PresenceScreenState extends State<PresenceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kehadiran",
          style: TextStyle(
            fontFamily: "StageGrotesk_Bold",
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF1E3A8A),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.blue),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Latitude : -8.297922",
                  style: TextStyle(
                    fontFamily: "StageGrotesk_Regular",
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Longtitude : 115.2232323",
                  style: TextStyle(
                    fontFamily: "StageGrotesk_Regular",
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              "Nama : Triana Julianingsih",
              style: TextStyle(fontFamily: "StageGrotesk_Medium", fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              "Status : Masuk",
              style: TextStyle(fontFamily: "StageGrotesk_Medium", fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 10),
            child: Text(
              "Alamat : ",
              style: TextStyle(
                fontFamily: "StageGrotesk_Regular",
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: Container(
              width: 370,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color.fromARGB(180, 202, 200, 200),
                ),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Keterangan Kehadiran",
                      style: TextStyle(
                        fontFamily: "StageGrotesk_Bold",
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text("Senin", style: TextStyle(fontFamily: "StageGrotesk_Regular", fontSize: 14),), Text("15 Sep 25", style: TextStyle(fontFamily: "StageGrotesk_Regular", fontSize: 14))],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text("Check In", style: TextStyle(fontFamily: "StageGrotesk_Regular", fontSize: 14)), Text("08:00", style: TextStyle(fontFamily: "StageGrotesk_Regular", fontSize: 14))],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text("Check Out", style: TextStyle(fontFamily: "StageGrotesk_Regular", fontSize: 14)), Text("15:00", style: TextStyle(fontFamily: "StageGrotesk_Regular", fontSize: 14))],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 40,),
          Center(
            child: SizedBox(
              width: 360,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                child: Text("Absen Sekarang", style: TextStyle(color: Colors.white, fontFamily: "StageGrotesk_Bold", fontSize: 16),),
                style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
              ),
              
            ),
          ),
        ],
      ),
    );
  }
}
