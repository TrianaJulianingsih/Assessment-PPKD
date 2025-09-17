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
  GetProfileModel? user;
  GetHistoryModel? history;
  String? errorMessage;
  bool isLoading = true;
  bool isLoadingHistory = true;
  String userName = "";
  String batch = "";
  String trainingTitle = "";
  String profilePhotoUrl = "";
  String currentTime = DateFormat('HH:mm').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadHistoryData();

    Timer.periodic(Duration(minutes: 1), (Timer t) {
      setState(() {
        currentTime = DateFormat('HH:mm').format(DateTime.now());
      });
    });
  }

  void _loadUserData() async {
    setState(() => isLoading = true);

    try {
      final userData = await ProfileAPI.getProfile();
      setState(() {
        user = userData;
        userName = userData.data?.name ?? "";
        batch = userData.data?.batchKe ?? "";
        trainingTitle = userData.data?.trainingTitle ?? "";
        profilePhotoUrl = userData.data?.profilePhotoUrl ?? "";
      });
      await PreferenceHandler.setUserName(userName);
      await PreferenceHandler.setBatch(batch);
    } catch (e) {
      setState(() => errorMessage = e.toString());
      print("Error loading user data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _loadHistoryData() async {
    setState(() => isLoadingHistory = true);

    try {
      final historyData = await HistoryAPI.getHistory();
      setState(() => history = historyData);
    } catch (e) {
      print("Error loading history data: $e");
    } finally {
      setState(() => isLoadingHistory = false);
    }
  }

  Datum? getTodayAttendance() {
    if (history == null || history!.data == null) return null;

    final today = DateTime.now();
    final todayFormatted = DateFormat('yyyy-MM-dd').format(today);

    return history!.data!.firstWhere((attendance) {
      if (attendance.attendanceDate == null) return false;
      final attendanceDate = DateFormat(
        'yyyy-MM-dd',
      ).format(attendance.attendanceDate!);
      return attendanceDate == todayFormatted;
    }, orElse: () => Datum());
  }

  @override
  Widget build(BuildContext context) {
    final todayAttendance = getTodayAttendance();
    final checkInTime = todayAttendance?.checkInTime ?? "-";
    final checkOutTime = todayAttendance?.checkOutTime ?? "-";

    return RefreshIndicator(
      onRefresh: () async {
        _loadUserData();
        _loadHistoryData();
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
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
                                  backgroundImage: profilePhotoUrl.isNotEmpty
                                      ? NetworkImage(profilePhotoUrl)
                                      : AssetImage(
                                              "assets/images/foto ppkd.jpeg",
                                            )
                                            as ImageProvider,
                                  radius: 30,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Selamat ${_getGreeting()}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: "StageGrotesk_Regular",
                                        ),
                                      ),
                                      Text(
                                        userName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: "StageGrotesk_Bold",
                                        ),
                                      ),
                                      Text(
                                        trainingTitle,
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
                            checkInTime is String ? checkInTime : "-",
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
                          checkOutTime is String ? checkOutTime : "-",
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
                              todayAttendance?.checkInAddress ??
                                  "Lokasi tidak tersedia",
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
            isLoadingHistory
                ? Center(child: CircularProgressIndicator())
                : history == null ||
                      history!.data == null ||
                      history!.data!.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("Tidak ada riwayat absensi"),
                  )
                : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: history!.data!.length > 5
                        ? 5
                        : history!.data!.length,
                    itemBuilder: (context, index) {
                      final attendance = history!.data![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(
                              attendance.status == "izin"
                                  ? Icons.event_busy
                                  : Icons.event_available,
                              color: attendance.status == "izin"
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            title: Text(
                              attendance.attendanceDate != null
                                  ? DateFormat(
                                      'EEEE, d MMMM y',
                                      'id_ID',
                                    ).format(attendance.attendanceDate!)
                                  : "Tanggal tidak tersedia",
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Check In: ${attendance.checkInTime ?? "-"}",
                                ),
                                Text(
                                  "Check Out: ${attendance.checkOutTime ?? "-"}",
                                ),
                                if (attendance.status == "izin" &&
                                    attendance.alasanIzin != null)
                                  Text("Alasan: ${attendance.alasanIzin}"),
                              ],
                            ),
                            trailing: Text(
                              attendance.status == "izin" ? "Izin" : "Hadir",
                              style: TextStyle(
                                color: attendance.status == "izin"
                                    ? Colors.orange
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
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
