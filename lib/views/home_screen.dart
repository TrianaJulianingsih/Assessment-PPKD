import 'package:absensi_apps/api/attendance.dart';
import 'package:absensi_apps/api/history.dart';
import 'package:absensi_apps/api/profile.dart';
import 'package:absensi_apps/api/statistik.dart';
import 'package:absensi_apps/models/absen_stats_model.dart'; // Import model stats
import 'package:absensi_apps/models/absen_today.dart';
import 'package:absensi_apps/models/get_profile_model.dart';
import 'package:absensi_apps/models/history_absen_model.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const id = "/home_screen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<GetProfileModel> _profileFuture;
  late Future<AbsenTodayModel?> _todayFuture;
  late Future<HistoryModel> _historyFuture;
  late Future<AbsenStatsModel> _statsFuture;
  String? _currentAddress;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _todayFuture = AttendanceAPI.getToday(date: today);
    _profileFuture = ProfileAPI.getProfile();
    _todayFuture = AttendanceAPI.getToday();
    _historyFuture = HistoryAPI.getHistory();
    _statsFuture = StatistikAPI.getStats();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _currentAddress = "Izin lokasi tidak diberikan";
          _loadingLocation = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _getAddressFromLatLng(pos.latitude, pos.longitude);
    } catch (e) {
      setState(() {
        _currentAddress = "Gagal mendapatkan lokasi";
        _loadingLocation = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      Placemark place = placemarks[0];

      String address =
          '${place.street}, ${place.subLocality}, ${place.locality}';

      setState(() {
        _currentAddress = address;
        _loadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _currentAddress = "Alamat tidak dapat ditemukan";
        _loadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _profileFuture = ProfileAPI.getProfile();
          _todayFuture = AttendanceAPI.getToday();
          _historyFuture = HistoryAPI.getHistory();
          _statsFuture = StatistikAPI.getStats();
          _loadingLocation = true;
          _getCurrentLocation();
        });
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 20),
            _buildProfileCard(),
            SizedBox(height: 20),
            _buildStatsCard(),
            SizedBox(height: 20),
            _buildTodayCard(),
            SizedBox(height: 20),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: FutureBuilder<GetProfileModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          final profile = snapshot.data!.data!;
          return Container(
            height: 120,
            width: 350,
            decoration: _boxWhite(),
            child: Row(
              children: [
                SizedBox(width: 20),
                CircleAvatar(
                  radius: 30,
                  backgroundImage: profile.profilePhotoUrl != null
                      ? NetworkImage(profile.profilePhotoUrl!)
                      : AssetImage("assets/images/foto ppkd.jpeg")
                            as ImageProvider,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        profile.name ?? "-",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "StageGrotesk_Bold",
                        ),
                      ),
                      Text(
                        profile.training?.title ?? "No Training",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "StageGrotesk_Regular",
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard() {
    return FutureBuilder<AbsenStatsModel>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data?.data == null) {
          return Container(
            width: 350,
            padding: EdgeInsets.all(16),
            decoration: _boxWhite(),
            child: Text(
              "Tidak ada data statistik",
              style: TextStyle(fontFamily: "StageGrotesk_Regular"),
            ),
          );
        }

        final stats = snapshot.data!.data!;
        final totalAbsen = stats.totalAbsen ?? 0;
        final totalMasuk = stats.totalMasuk ?? 0;
        final totalIzin = stats.totalIzin ?? 0;

        return Container(
          width: 350,
          padding: EdgeInsets.all(16),
          decoration: _boxWhite(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Statistik Absen",
                style: TextStyle(fontSize: 16, fontFamily: "StageGrotesk_Bold"),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem("Total", totalAbsen, Colors.blue),
                  _statItem("Masuk", totalMasuk, Color(0xFF10B981)),
                  _statItem("Izin", totalIzin, Colors.orange),
                ],
              ),
              SizedBox(height: 10),
              if (totalAbsen > 0) ...[
                LinearProgressIndicator(
                  value: totalMasuk / totalAbsen,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                SizedBox(height: 5),
                Text(
                  "Kehadiran: $totalMasuk/$totalAbsen "
                  "(${(totalMasuk / totalAbsen * 100).toStringAsFixed(1)}%)",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "StageGrotesk_Regular",
                  ),
                ),
              ],
              SizedBox(height: 5),
              Text(
                "Status Hari Ini: ${stats.sudahAbsenHariIni == true ? 'Sudah Absen' : 'Belum Absen'}",
                style: TextStyle(
                  fontSize: 14,
                  color: stats.sudahAbsenHariIni == true
                      ? Color(0xFF10B981)
                      : Colors.orange,
                  fontFamily: "StageGrotesk_Bold",
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statItem(String title, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16,
                fontFamily: "StageGrotesk_Regular",
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(title, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildTodayCard() {
    return FutureBuilder<AbsenTodayModel?>(
      future: _todayFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data?.data == null) {
          return Container(
            width: 350,
            padding: EdgeInsets.all(16),
            decoration: _boxWhite(),
            child: Text(
              "Belum ada data absen hari ini",
              style: TextStyle(fontFamily: "StageGrotesk_Medium"),
            ),
          );
        }

        final today = snapshot.data!.data!;
        final status = today.status ?? "Belum Absen";

        return Column(
          children: [
            Text(
              DateFormat("EEEE, dd MMM yyyy", "id_ID").format(DateTime.now()),
              style: TextStyle(
                color: Color(0xFF1E3A8A),
                fontSize: 20,
                fontFamily: "StageGrotesk_Bold",
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _timeBox("Check In", today.checkInTime ?? "-"),
                SizedBox(width: 10),
                _timeBox("Check Out", today.checkOutTime ?? "-"),
              ],
            ),
            SizedBox(height: 10),
            Container(
              width: 350,
              padding: EdgeInsets.all(16),
              decoration: _boxBlue(),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentAddress ?? "Lokasi tidak tersedia",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: "StageGrotesk_Regular",
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryList() {
    return FutureBuilder<HistoryModel>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.data == null) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Text("Tidak ada riwayat absen"),
          );
        }
        final items = snapshot.data!.data!;
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Riwayat Absen",
                style: TextStyle(fontSize: 18, fontFamily: "StageGrotesk_Bold"),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final h = items[i];
                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(Icons.calendar_today_rounded, size: 20),
                      title: Text(
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(h.attendanceDate ?? DateTime.now()),
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "StageGrotesk_Medium",
                        ),
                      ),
                      subtitle: Text(
                        "In: ${h.checkInTime ?? '-'} | Out: ${h.checkOutTime ?? '-'}",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "StageGrotesk_Medium",
                        ),
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(h.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          h.status ?? "-",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontFamily: "StageGrotesk_Regular",
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'masuk':
        return Color(0xFF10B981);
      case 'telat':
        return Colors.red;
      case 'izin':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _timeBox(String title, String time) {
    return Container(
      height: 80,
      width: 160,
      padding: EdgeInsets.all(8),
      decoration: _boxBlue(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: "StageGrotesk_Medium",
            ),
          ),
          SizedBox(height: 5),
          Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: "StageGrotesk_Bold",
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxBlue() => BoxDecoration(
    color: Color(0xFF1E3A8A),
    borderRadius: BorderRadius.circular(8),
  );

  BoxDecoration _boxWhite() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        spreadRadius: 1,
        blurRadius: 5,
        offset: Offset(2, 2),
      ),
    ],
  );

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Pagi';
    if (hour < 15) return 'Siang';
    if (hour < 19) return 'Sore';
    return 'Malam';
  }
}
