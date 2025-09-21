import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:absensi_apps/api/attendance.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:absensi_apps/models/absen_today.dart';
import 'package:geocoding/geocoding.dart';

class PresenceScreen extends StatefulWidget {
  const PresenceScreen({super.key});
  static const id = "/presence_screen";

  @override
  State<PresenceScreen> createState() => _PresenceScreenState();
}

class _PresenceScreenState extends State<PresenceScreen> {
  Completer<GoogleMapController> _mapController = Completer();
  LatLng? _currentLatLng;
  String? _status;
  String? _currentAddress;
  DateTime _today = DateTime.now();
  bool _loading = true;
  AbsenTodayModel? _todayModel;
  bool _isLate = false; // Tambahkan variabel untuk status telat

  @override
  void initState() {
    super.initState();
    _initLocationAndData();
  }

  Future<void> _initLocationAndData() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _loading = false);
      return;
    }

    // Get current position
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Get address from coordinates
    await _getAddressFromLatLng(pos.latitude, pos.longitude);

    setState(() {
      _currentLatLng = LatLng(pos.latitude, pos.longitude);
    });

    // Load today's attendance data
    await _loadTodayData();
    setState(() => _loading = false);
  }

  // Fungsi untuk mendapatkan alamat dari koordinat
  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      Placemark place = placemarks[0];

      String address =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}';

      setState(() {
        _currentAddress = address;
      });
    } catch (e) {
      print("Error getting address: $e");
      setState(() {
        _currentAddress = "Alamat tidak dapat ditemukan";
      });
    }
  }

  // Fungsi untuk memeriksa apakah check-in telat (setelah jam 8 pagi)
  bool _checkIsLate(String checkInTime) {
    try {
      if (checkInTime.isEmpty) return false;
      
      // Parse waktu check-in
      List<String> timeParts = checkInTime.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      
      // Jika check-in setelah jam 8:00, dianggap telat
      return hour > 8 || (hour == 8 && minute > 0);
    } catch (e) {
      print("Error parsing check-in time: $e");
      return false;
    }
  }

  Future<void> _loadTodayData() async {
    final todayData = await AttendanceAPI.getToday();
    if (!mounted) return;

    setState(() {
      _todayModel = todayData;
      if (_todayModel != null && _todayModel!.data != null) {
        _status = _todayModel!.data!.status;
        
        // Periksa apakah check-in telat
        if (_todayModel!.data!.checkInTime != null) {
          _isLate = _checkIsLate(_todayModel!.data!.checkInTime!);
          
          // Jika telat, update status
          if (_isLate && _status != 'izin' && _status != 'sakit') {
            _status = 'telat';
          }
        }
      }
    });
  }

  final Random _rand = Random();
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Apa Ibu Kota Indonesia?',
      'options': ['Jakarta', 'Batavia', 'Bandung'],
      'correct': 'Jakarta',
    },
    {
      'question': 'Gunung tertinggi di Indonesia?',
      'options': ['Puncak Jaya', 'Semeru', 'Rinjani'],
      'correct': 'Puncak Jaya',
    },
    {
      'question': 'Lambang negara Indonesia adalah?',
      'options': ['Garuda Pancasila', 'Banteng', 'Merpati'],
      'correct': 'Garuda Pancasila',
    },
  ];

  Future<bool> _askQuestion() async {
    final q = _questions[_rand.nextInt(_questions.length)];
    String? selectedAnswer = q['options'][0];

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Pertanyaan Keamanan"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    q['question'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  for (final opt in q['options'])
                    RadioListTile<String>(
                      title: Text(opt),
                      value: opt,
                      groupValue: selectedAnswer,
                      onChanged: (val) =>
                          setStateDialog(() => selectedAnswer = val),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedAnswer != null) {
                      bool isCorrect = selectedAnswer == q['correct'];
                      Navigator.pop(context, isCorrect);
                    }
                  },
                  child: Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );

    return result ?? false;
  }

  Future<void> _handleCheckIn() async {
    if (_currentLatLng == null) return;

    final isCorrect = await _askQuestion();
    if (!isCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Jawaban salah, silakan coba lagi")),
      );
      return;
    }

    final now = DateTime.now();
    final checkInTime = DateFormat('HH:mm').format(now);
    
    bool isLate = _checkIsLate(checkInTime);
    
    final model = await AttendanceAPI.checkIn(
      attendanceDate: DateFormat('yyyy-MM-dd').format(now),
      checkIn: checkInTime,
      lat: _currentLatLng!.latitude,
      lng: _currentLatLng!.longitude,
      address: _currentAddress ?? "Lokasi saya",
    );

    if (model != null) {
      await _loadTodayData();
      
      if (isLate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Check-In berhasil (Status: Telat)")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Check-In berhasil")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal Check-In")),
      );
    }
  }

  Future<void> _handleCheckOut() async {
    if (_currentLatLng == null) return;

    final now = DateTime.now();
    final model = await AttendanceAPI.checkOut(
      attendanceDate: DateFormat('yyyy-MM-dd').format(now),
      checkOut: DateFormat('HH:mm').format(now),
      lat: _currentLatLng!.latitude,
      lng: _currentLatLng!.longitude,
      address: _currentAddress ?? "Lokasi saya",
    );

    if (model != null) {
      await _loadTodayData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Check-Out berhasil")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal Check-Out")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kehadiran",
          style: TextStyle(
            fontFamily: "StageGrotesk_Bold",
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 400,
              child: _currentLatLng == null
                  ? Center(child: Text("Lokasi tidak tersedia"))
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentLatLng!,
                        zoom: 16,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      onMapCreated: (controller) =>
                          _mapController.complete(controller),
                      markers: {
                        Marker(
                          markerId: MarkerId("me"),
                          position: _currentLatLng!,
                          infoWindow: InfoWindow(title: "Lokasi Saya"),
                        ),
                      },
                    ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Latitude: ${_currentLatLng?.latitude.toStringAsFixed(5) ?? '-'}",
                    style: TextStyle(fontFamily: "StageGrotesk_Regular"),
                  ),
                  Text(
                    "Longitude: ${_currentLatLng?.longitude.toStringAsFixed(5) ?? '-'}",
                    style: TextStyle(fontFamily: "StageGrotesk_Regular"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 270, top: 5),
              child: Text(
                "Status : ${_status ?? 'Belum absen'}",
                style: TextStyle(
                  fontFamily: "StageGrotesk_Regular",
                  color: _isLate ? Colors.red : Colors.black, // Warna merah jika telat
                ),
              ),
            ),
            // Tambahkan indikator telat jika perlu
            if (_isLate)
              Padding(
                padding: EdgeInsets.only(right: 270, top: 5),
                child: Text(
                  "⚠️ Check-in terlambat",
                  style: TextStyle(
                    fontFamily: "StageGrotesk_Regular",
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 5),
              child: Text(
                "Lokasi : ${_currentAddress ?? 'Mendapatkan lokasi...'}",
                style: TextStyle(fontFamily: "StageGrotesk_Regular"),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(height: 20),
            Center(
              child: Container(
                width: 350,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(4, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoColumn(
                      "Tanggal",
                      DateFormat('dd MMM yyyy').format(_today),
                    ),
                    _infoColumn(
                      "Check-In",
                      _todayModel?.data?.checkInTime ?? "-",
                    ),
                    _infoColumn(
                      "Check-Out",
                      _todayModel?.data?.checkOutTime ?? "-",
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildButton(
              label: "Check-In",
              color: Color(0xFF10B981),
              onPressed: _handleCheckIn,
              // Disable button if already checked in
              disabled: _todayModel?.data?.checkInTime != null,
            ),
            SizedBox(height: 20),
            _buildButton(
              label: "Check-Out",
              color: Colors.amber,
              onPressed: _handleCheckOut,
              // Disable button if not checked in yet or already checked out
              disabled:
                  _todayModel?.data?.checkInTime == null ||
                  _todayModel?.data?.checkOutTime != null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontFamily: "StageGrotesk_Medium", fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontFamily: "StageGrotesk_Regular", fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool disabled = false,
  }) {
    return Center(
      child: SizedBox(
        width: 350,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: disabled ? Colors.grey : color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: disabled ? null : onPressed,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: "StageGrotesk_Bold",
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}