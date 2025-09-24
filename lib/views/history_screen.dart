import 'package:absensi_apps/api/history.dart';
import 'package:absensi_apps/models/history_absen_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                  color: Colors.white,
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(Icons.calendar_today_rounded, size: 20),
                    title: Text(
                      DateFormat(
                        'dd MMM yyyy',
                      ).format(item.attendanceDate ?? DateTime.now()),
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "StageGrotesk_Medium",
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.checkInTime != null)
                          Text(
                            'In: ${item.checkInTime} | Out: ${item.checkOutTime}',
                            style: TextStyle(
                              fontSize: 14,
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
