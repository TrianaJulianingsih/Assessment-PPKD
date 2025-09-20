import 'package:absensi_apps/api/history.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:absensi_apps/models/history_absen_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<HistoryModel> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = HistoryAPI.getHistory();
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _futureHistory = HistoryAPI.getHistory();
    });
    await _futureHistory;
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'masuk':
        return Colors.lightBlue;
      case 'telat':
        return Colors.red;
      case 'izin':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Riwayat",
          style: TextStyle(
            fontFamily: "StageGrotesk_Bold",
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1E3A8A),
      ),
      body: FutureBuilder<HistoryModel>(
        future: _futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _refreshHistory,
              child: ListView(
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Gagal memuat data: ${snapshot.error}',
                        style: TextStyle(fontFamily: "StageGrotesk_Regular"),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data?.data ?? [];
          if (data.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshHistory,
              child: ListView(
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Belum ada riwayat absen',
                        style: TextStyle(fontFamily: "StageGrotesk_Regular"),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshHistory,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (_, index) {
                final item = data[index];
                final dateStr = item.attendanceDate != null
                    ? DateFormat('dd/MM/yyyy').format(item.attendanceDate!)
                    : '-';
                final status = item.status ?? '-';
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      height: 80,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[100],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat(
                              'dd',
                            ).format(item.attendanceDate ?? DateTime.now()),
                            style: TextStyle(
                              fontFamily: "StageGrotesk_Bold",
                              fontSize: 20,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          Text(
                            DateFormat(
                              'MMM',
                            ).format(item.attendanceDate ?? DateTime.now()),
                            style: TextStyle(
                              fontFamily: "StageGrotesk_Regular",
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.checkInTime != null)
                          Text(
                            'Check-in: ${item.checkInTime}',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: "StageGrotesk_Medium",
                            ),
                          ),
                        if (item.checkOutTime != null)
                          Text(
                            'Check-out: ${item.checkOutTime}',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: "StageGrotesk_Medium",
                            ),
                          ),
                      ],
                    ),
                    trailing: Text(
                      status,
                      style: TextStyle(
                        fontFamily: "StageGrotesk_Bold",
                        color: getStatusColor(item.status),
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
