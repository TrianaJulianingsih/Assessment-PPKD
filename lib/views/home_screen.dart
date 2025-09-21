import 'package:absensi_apps/api/statistik.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:absensi_apps/api/profile.dart';
import 'package:absensi_apps/api/attendance.dart';
import 'package:absensi_apps/api/history.dart';
import 'package:absensi_apps/models/get_profile_model.dart';
import 'package:absensi_apps/models/absen_today.dart';
import 'package:absensi_apps/models/history_absen_model.dart';
import 'package:absensi_apps/models/absen_stats_model.dart'; // Import model stats
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
    _profileFuture = ProfileAPI.getProfile();
    _todayFuture = AttendanceAPI.getToday();
    _historyFuture = HistoryAPI.getHistory();
    _statsFuture =
        StatistikAPI.getStats(); // Pastikan method ini sudah ada di AttendanceAPI
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
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileCard(),
            const SizedBox(height: 20),
            _buildStatsCard(),
            const SizedBox(height: 20),
            _buildTodayCard(),
            const SizedBox(height: 20),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  // === Profile Card ===
  Widget _buildProfileCard() {
    return FutureBuilder<GetProfileModel>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final profile = snapshot.data!.data!;
        return Container(
          height: 120,
          width: 350,
          decoration: _boxWhite(),
          child: Row(
            children: [
              const SizedBox(width: 20),
              CircleAvatar(
                radius: 30,
                backgroundImage: profile.profilePhotoUrl != null
                    ? NetworkImage(profile.profilePhotoUrl!)
                    : const AssetImage("assets/images/foto ppkd.jpeg")
                          as ImageProvider,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selamat ${_getGreeting()}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      profile.name ?? "-",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      profile.training?.title ?? "No Training",
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    // _buildLocationInfo(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCard() {
    return FutureBuilder<AbsenStatsModel>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data?.data == null) {
          return Container(
            width: 350,
            padding: const EdgeInsets.all(16),
            decoration: _boxWhite(),
            child: const Text("Tidak ada data statistik"),
          );
        }

        final stats = snapshot.data!.data!;
        final totalAbsen = stats.totalAbsen ?? 0;
        final totalMasuk = stats.totalMasuk ?? 0;
        final totalIzin = stats.totalIzin ?? 0;

        return Container(
          width: 350,
          padding: const EdgeInsets.all(16),
          decoration: _boxWhite(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Statistik Absen",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem("Total", totalAbsen, Colors.blue),
                  _statItem("Masuk", totalMasuk, Color(0xFF10B981)),
                  _statItem("Izin", totalIzin, Colors.orange),
                ],
              ),
              const SizedBox(height: 10),
              if (totalAbsen > 0) ...[
                LinearProgressIndicator(
                  value: totalMasuk / totalAbsen,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 5),
                Text(
                  "Kehadiran: $totalMasuk/$totalAbsen "
                  "(${(totalMasuk / totalAbsen * 100).toStringAsFixed(1)}%)",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              const SizedBox(height: 5),
              Text(
                "Status Hari Ini: ${stats.sudahAbsenHariIni == true ? 'Sudah Absen' : 'Belum Absen'}",
                style: TextStyle(
                  fontSize: 12,
                  color: stats.sudahAbsenHariIni == true
                      ? Color(0xFF10B981)
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  // === Absen Hari Ini ===
  Widget _buildTodayCard() {
    return FutureBuilder<AbsenTodayModel?>(
      future: _todayFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data?.data == null) {
          return Container(
            width: 350,
            padding: const EdgeInsets.all(16),
            decoration: _boxWhite(),
            child: const Text("Belum ada data absen hari ini"),
          );
        }
        final today = snapshot.data!.data!;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _timeBox("Check In", today.checkInTime ?? "-"),
                const SizedBox(width: 10),
                _timeBox("Check Out", today.checkOutTime ?? "-"),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: 350,
              padding: const EdgeInsets.all(16),
              decoration: _boxBlue(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentAddress ?? "Lokasi tidak tersedia",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontFamily: "StageGrotesk_Regular"
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // === Riwayat Absen ===
  Widget _buildHistoryList() {
    return FutureBuilder<HistoryModel>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.data == null) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: const Text("Tidak ada riwayat absen"),
          );
        }
        final items = snapshot.data!.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Riwayat Absen",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final h = items[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today, size: 20),
                      title: Text(
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(h.attendanceDate ?? DateTime.now()),
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        "In: ${h.checkInTime ?? '-'} | Out: ${h.checkOutTime ?? '-'}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(h.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          h.status ?? "-",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
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

  // === Helper Widget ===
  Widget _timeBox(String title, String time) {
    return Container(
      height: 80,
      width: 160,
      padding: const EdgeInsets.all(8),
      decoration: _boxBlue(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxBlue() => BoxDecoration(
    color: const Color(0xFF1E3A8A),
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
        offset: const Offset(2, 2),
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
