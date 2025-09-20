import 'dart:async';
import 'dart:math';
import 'package:absensi_apps/api/attendance.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:absensi_apps/models/absen_today.dart';

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
  String? _checkIn;
  String? _checkOut;
  DateTime _today = DateTime.now();
  bool _loading = true;

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
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentLatLng = LatLng(pos.latitude, pos.longitude);
    final todayData = await AttendanceAPI.getToday();
    if (todayData != null && todayData.data != null) {
      setState(() {
        _status = todayData.data!.status;
        _checkIn = todayData.data!.checkInTime;
        _checkOut = todayData.data!.checkOutTime;
      });
    }

    setState(() => _loading = false);
  }

  final Random _rand = Random();
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Apa Ibu Kota Indonesia?',
      'options': ['Jakarta', 'Batavia', 'Bandung'],
    },
    {
      'question': 'Gunung tertinggi di Indonesia?',
      'options': ['Puncak Jaya', 'Semeru', 'Rinjani'],
    },
    {
      'question': 'Lambang negara Indonesia adalah?',
      'options': ['Garuda Pancasila', 'Banteng', 'Merpati'],
    },
  ];

  Future<String?> _askQuestion() async {
    final q = _questions[_rand.nextInt(_questions.length)];
    String? jawaban = q['options'][0];

    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(q['question']),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final opt in q['options'])
                    RadioListTile<String>(
                      title: Text(opt),
                      value: opt,
                      groupValue: jawaban,
                      onChanged: (val) => setStateDialog(() => jawaban = val),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (jawaban != null) Navigator.pop(context, jawaban);
                  },
                  child: Text("Lanjut"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleCheckIn() async {
    if (_currentLatLng == null) return;
    final jawaban = await _askQuestion();
    if (jawaban == null) return;

    final now = DateTime.now();
    final model = await AttendanceAPI.checkIn(
      attendanceDate: DateFormat('yyyy-MM-dd').format(now),
      checkIn: DateFormat('HH:mm').format(now),
      lat: _currentLatLng!.latitude,
      lng: _currentLatLng!.longitude,
      address: "Lokasi saya",
    );

    if (model != null) {
      setState(() {
        _status = model.data?.status;
        _checkIn = model.data?.checkInTime;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Check-In berhasil. Jawaban: $jawaban")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal Check-In")));
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
      address: "Lokasi saya",
    );

    if (model != null) {
      setState(() {
        _status = model.data?.status;
        _checkOut = model.data?.checkOutTime;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Check-Out berhasil")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal Check-Out")));
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
            // ✅ Google Map
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
              padding: EdgeInsets.only(left: 15, top: 5),
              child: Text(
                "Status : ${_status ?? 'Belum absen'}",
                style: TextStyle(fontFamily: "StageGrotesk_Regular"),
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
                    _infoColumn("Check-In", _checkIn ?? "-"),
                    _infoColumn("Check-Out", _checkOut ?? "-"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildButton(
              label: "Check-In",
              color: Color(0xFF10B981),
              onPressed: _handleCheckIn,
            ),
            SizedBox(height: 20),
            _buildButton(
              label: "Check-Out",
              color: Colors.amber,
              onPressed: _handleCheckOut,
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
  }) {
    return Center(
      child: SizedBox(
        width: 350,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onPressed,
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
