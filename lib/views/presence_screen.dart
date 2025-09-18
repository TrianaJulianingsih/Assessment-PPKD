import 'package:absensi_apps/api/attendance.dart';
import 'package:absensi_apps/api/profile.dart';
import 'package:absensi_apps/models/get_profile_model.dart';
import 'package:absensi_apps/shared_preferences.dart/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class PresenceScreen extends StatefulWidget {
  const PresenceScreen({super.key});
  static const id = "/presence_screen";

  @override
  State<PresenceScreen> createState() => _PresenceScreenState();
}

class _PresenceScreenState extends State<PresenceScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  String _latitude = "Loading...";
  String _longitude = "Loading...";
  String _address = "Loading...";
  String _status = "Belum Absen";
  GetProfileModel? _userProfile;
  bool _isLoading = true;
  bool _isCheckingLocation = false;
  String _locationError = "";

  String _checkInTime = "-";
  String _checkOutTime = "-";
  bool _hasCheckedIn = false;

  // Daftar pertanyaan dan jawaban untuk validasi absensi
  final List<Map<String, dynamic>> _attendanceQuestions = [
    {
      'question': 'Berapa hasil dari 7 + 5?',
      'answer': '12',
      'options': ['10', '12', '14', '16'],
    },
    {
      'question': 'Apa ibukota Indonesia?',
      'answer': 'Jakarta',
      'options': ['Jakarta', 'Bandung', 'Surabaya', 'Medan'],
    },
    {
      'question': 'Bulan ke berapa setelah April?',
      'answer': 'Mei',
      'options': ['Maret', 'Mei', 'Juni', 'Juli'],
    },
    {
      'question': 'Warna campuran merah dan biru?',
      'answer': 'Ungu',
      'options': ['Hijau', 'Kuning', 'Ungu', 'Oranye'],
    },
    {
      'question': 'Hewan yang dikenal sebagai raja hutan?',
      'answer': 'Singa',
      'options': ['Harimau', 'Singa', 'Gajah', 'Jerapah'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCheckInData();
    _loadUserData();
    _getCurrentLocation();
  }

  // Memuat data check-in dari shared preferences
  void _loadCheckInData() async {
    try {
      final checkInTime = await PreferenceHandler.getCheckInTime();
      final hasCheckedIn = await PreferenceHandler.getCheckInStatus();

      setState(() {
        _checkInTime = checkInTime ?? "-";
        _hasCheckedIn = hasCheckedIn;
        _status = _hasCheckedIn ? "Sudah Check-In" : "Belum Absen";
      });
    } catch (e) {
      print("Error loading check-in data: $e");
    }
  }

  void _loadUserData() async {
    try {
      final userData = await ProfileAPI.getProfile();
      setState(() {
        _userProfile = userData;
      });
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  void _getCurrentLocation() async {
    setState(() {
      _isCheckingLocation = true;
      _locationError = "";
    });
    try {
      bool serviceEnabled;
      LocationPermission permission;

      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } catch (e) {
        print("Geolocator not available: $e");
        setState(() {
          _locationError = "Layanan lokasi tidak tersedia";
          _isCheckingLocation = false;
          _isLoading = false;
        });
        return;
      }

      if (!serviceEnabled) {
        setState(() {
          _locationError = "Layanan lokasi dimatikan. Silakan aktifkan GPS.";
          _isCheckingLocation = false;
          _isLoading = false;
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = "Izin lokasi ditolak";
            _isCheckingLocation = false;
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = "Izin lokasi ditolak secara permanen";
          _isCheckingLocation = false;
          _isLoading = false;
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Dapatkan alamat yang lebih detail
      String address = await _getDetailedAddress(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _latitude = position.latitude.toStringAsFixed(6);
        _longitude = position.longitude.toStringAsFixed(6);
        _address = address;
        _isCheckingLocation = false;
        _isLoading = false;
      });

      if (_mapController != null && _currentPosition != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition!, 15),
        );
      }
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        _locationError = "Gagal mendapatkan lokasi: $e";
        _isCheckingLocation = false;
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk mendapatkan alamat yang lebih detail
  Future<String> _getDetailedAddress(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Format alamat yang lebih baik
        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }

        return addressParts.isNotEmpty
            ? addressParts.join(", ")
            : "Alamat tidak tersedia";
      }
      return "Alamat tidak tersedia";
    } catch (e) {
      print("Error getting detailed address: $e");
      return "Koordinat: $lat, $lng";
    }
  }

  Future<void> _doCheckIn() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Tidak dapat mendapatkan lokasi")));
      return;
    }

    setState(() => _isCheckingLocation = true);

    try {
      final response = await AttendanceAPI.checkIn(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        address: _address,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? "Check-in berhasil")),
      );

      final checkInTime = DateFormat('HH:mm', 'id_ID').format(DateTime.now());

      // Simpan data check-in ke shared preferences
      await PreferenceHandler.setCheckInTime(checkInTime);
      await PreferenceHandler.setCheckInStatus(true);

      setState(() {
        _checkInTime = checkInTime;
        _status = "Sudah Check-In";
        _hasCheckedIn = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal melakukan check-in: $e")));
    } finally {
      setState(() => _isCheckingLocation = false);
    }
  }

  Future<void> _doCheckOut() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Tidak dapat mendapatkan lokasi")));
      return;
    }

    setState(() => _isCheckingLocation = true);

    try {
      final response = await AttendanceAPI.checkOut(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        address: _address,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? "Check-out berhasil")),
      );

      final checkOutTime = DateFormat('HH:mm', 'id_ID').format(DateTime.now());

      // Hapus data check-in dari shared preferences setelah check-out
      await PreferenceHandler.clearCheckInData();

      setState(() {
        _checkOutTime = checkOutTime;
        _status = "Sudah Check-Out";
        _hasCheckedIn = false;
        _checkInTime = "-"; // Reset check-in time
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal melakukan check-out: $e")));
    } finally {
      setState(() => _isCheckingLocation = false);
    }
  }

  // Fungsi untuk menampilkan dialog pertanyaan random
  void _showRandomQuestionDialog(String type) {
    // Pilih pertanyaan random
    final randomIndex =
        DateTime.now().millisecondsSinceEpoch % _attendanceQuestions.length;
    final question = _attendanceQuestions[randomIndex];

    String selectedAnswer = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Verifikasi Absensi"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question['question'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ...(question['options'] as List<String>).map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: selectedAnswer,
                      onChanged: (value) {
                        setState(() {
                          selectedAnswer = value!;
                        });
                      },
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: selectedAnswer.isEmpty
                      ? null
                      : () {
                          if (selectedAnswer == question['answer']) {
                            Navigator.pop(context);
                            if (type == 'checkin') {
                              _doCheckIn();
                            } else {
                              _doCheckOut();
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Jawaban salah, coba lagi!"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            Navigator.pop(context);
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
  }

  Widget _buildMap() {
    if (_currentPosition != null) {
      return GoogleMap(
        onMapCreated: (controller) {
          setState(() => _mapController = controller);
        },
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId('current_location'),
            position: _currentPosition!,
            infoWindow: InfoWindow(title: 'Lokasi Anda', snippet: _address),
          ),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      );
    } else if (_locationError.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              _locationError,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: Text("Coba Lagi"),
            ),
          ],
        ),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: _buildMap(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Latitude : $_latitude",
                          style: TextStyle(
                            fontFamily: "StageGrotesk_Regular",
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Longitude : $_longitude",
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
                      "Nama : ${_userProfile?.data?.name ?? 'Loading...'}",
                      style: TextStyle(
                        fontFamily: "StageGrotesk_Medium",
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      "Status : $_status",
                      style: TextStyle(
                        fontFamily: "StageGrotesk_Medium",
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      top: 10,
                      right: 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Alamat :",
                          style: TextStyle(
                            fontFamily: "StageGrotesk_Regular",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _address,
                          style: TextStyle(
                            fontFamily: "StageGrotesk_Regular",
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.left,
                          softWrap: true,
                        ),
                      ],
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
                              "Keterangan Kehadiran Hari Ini",
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
                                  children: [
                                    Text(
                                      DateFormat(
                                        'EEEE',
                                        'id_ID',
                                      ).format(DateTime.now()),
                                      style: TextStyle(
                                        fontFamily: "StageGrotesk_Regular",
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'dd MMM yy',
                                        'id_ID',
                                      ).format(DateTime.now()),
                                      style: TextStyle(
                                        fontFamily: "StageGrotesk_Regular",
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Check In",
                                      style: TextStyle(
                                        fontFamily: "StageGrotesk_Regular",
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      _checkInTime,
                                      style: TextStyle(
                                        fontFamily: "StageGrotesk_Regular",
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _checkInTime != "-"
                                            ? Colors.green
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Check Out",
                                      style: TextStyle(
                                        fontFamily: "StageGrotesk_Regular",
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      _checkOutTime,
                                      style: TextStyle(
                                        fontFamily: "StageGrotesk_Regular",
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _checkOutTime != "-"
                                            ? Colors.green
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Tombol Check-In
                  Center(
                    child: SizedBox(
                      width: 360,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isCheckingLocation || _hasCheckedIn
                            ? null
                            : () => _showRandomQuestionDialog('checkin'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isCheckingLocation
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Check-In Sekarang",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "StageGrotesk_Bold",
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Tombol Check-Out
                  Center(
                    child: SizedBox(
                      width: 360,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isCheckingLocation || !_hasCheckedIn
                            ? null
                            : () => _showRandomQuestionDialog('checkout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isCheckingLocation
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Check-Out Sekarang",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "StageGrotesk_Bold",
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
