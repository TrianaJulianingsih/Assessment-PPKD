import 'package:absensi_apps/api/history.dart';
import 'package:absensi_apps/api/izin.dart';
import 'package:absensi_apps/models/history_absen_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IzinScreen extends StatefulWidget {
  const IzinScreen({super.key});
  static const id = "/leave_screen";

  @override
  State<IzinScreen> createState() => _IzinScreenState();
}

class _IzinScreenState extends State<IzinScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Izin",
            style: TextStyle(
              fontFamily: "StageGrotesk_Bold",
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF1E3A8A),
          bottom: TabBar(
            labelStyle: TextStyle(
              fontSize: 16,
              fontFamily: "StageGrotesk_Bold",
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 16,
              fontFamily: "StageGrotesk_Regular",
            ),
            labelColor: Color(0xFF10B981),
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.teal,
            tabs: [
              Tab(text: 'Pengajuan Izin'),
              Tab(text: 'Riwayat Izin'),
            ],
          ),
        ),
        body: TabBarView(children: [LeaveRequestForm(), LeaveHistoryList()]),
      ),
    );
  }
}

class LeaveRequestForm extends StatefulWidget {
  const LeaveRequestForm({super.key});

  @override
  State<LeaveRequestForm> createState() => _LeaveRequestFormState();
}

class _LeaveRequestFormState extends State<LeaveRequestForm> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Harap pilih tanggal cuti')));
      return;
    }
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Harap isi alasan izin')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      final result = await IzinAPI.postIzin(
        date: apiDate,
        alasan: _reasonController.text,
      );

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Pengajuan cuti berhasil')),
        );
        _dateController.clear();
        _reasonController.clear();
        _selectedDate = null;
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengajukan cuti')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tanggal Izin",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: "StageGrotesk_Bold",
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _dateController,
            decoration: InputDecoration(
              labelText: 'Tanggal Cuti',
              labelStyle: TextStyle(
                fontFamily: "StageGrotesk_Regular",
                color: Colors.grey[600],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Color(0xFF1E3A8A)),
              ),
              suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          SizedBox(height: 24),
          Text(
            "Alasan Izin",
            style: TextStyle(fontSize: 16, fontFamily: "StageGrotesk_Bold"),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _reasonController,
            decoration: InputDecoration(
              labelText: 'Masukkan alasan izin',
              labelStyle: TextStyle(
                fontFamily: "StageGrotesk_Regular",
                color: Colors.grey[600],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Color(0xFF1E3A8A)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E3A8A),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Ajukan Cuti',
                      style: TextStyle(
                        fontFamily: "StageGrotesk_Bold",
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}

class LeaveHistoryList extends StatefulWidget {
  const LeaveHistoryList({super.key});

  @override
  State<LeaveHistoryList> createState() => _LeaveHistoryListState();
}

class _LeaveHistoryListState extends State<LeaveHistoryList> {
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
      case 'izin':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HistoryModel>(
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
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
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
        final allData = snapshot.data?.data ?? [];
        final izinData = allData
            .where((d) => (d.status ?? '').toLowerCase() == 'izin')
            .toList();

        if (izinData.isEmpty) {
          return Center(
            child: Text(
              'Belum ada riwayat izin',
              style: TextStyle(fontFamily: "StageGrotesk_Regular"),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshHistory,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: izinData.length,
            itemBuilder: (_, index) {
              final item = izinData[index];
              final dateStr = item.attendanceDate != null
                  ? DateFormat('dd/MM/yyyy').format(item.attendanceDate!)
                  : '-';

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
                      if (item.alasanIzin != null &&
                          item.alasanIzin!.isNotEmpty)
                        Text(
                          'Alasan: ${item.alasanIzin}',
                          style: TextStyle(
                            fontFamily: "StageGrotesk_Regular",
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                  trailing: Text(
                    item.status ?? '-',
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
    );
  }
}
