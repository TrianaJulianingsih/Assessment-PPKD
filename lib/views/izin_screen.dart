import 'package:flutter/material.dart';

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
            "Leave",
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
              Tab(text: 'Pengajuan Cuti'),
              Tab(text: 'Riwayat Cuti'),
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
            dialogBackgroundColor: Colors.white, 
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFF1E3A8A)),
              ),
              suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),

          SizedBox(height: 24),
          Text(
            "Alasan Izin",
            style: TextStyle(
              fontSize: 16,
              fontFamily: "StageGrotesk_Bold",
            ),
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
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFF1E3A8A)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            maxLines: 4, // Multi-line untuk alasan yang panjang
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),

          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_dateController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Harap pilih tanggal cuti')),
                  );
                  return;
                }
                if (_reasonController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Harap isi alasan izin')),
                  );
                  return;
                }
                print('Tanggal: ${_dateController.text}');
                print('Alasan: ${_reasonController.text}');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pengajuan cuti berhasil dikirim')),
                );
                _dateController.clear();
                _reasonController.clear();
                _selectedDate = null;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E3A8A),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
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

class LeaveHistoryList extends StatelessWidget {
  const LeaveHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, index) => Card(
        margin: EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Icon(Icons.event_note, color: Color(0xFF1E3A8A)),
          title: Text(
            'Cuti ke-${index + 1}',
            style: TextStyle(
              fontFamily: "StageGrotesk_Bold",
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '27/11/2023',
                style: TextStyle(
                  fontFamily: "StageGrotesk_Regular",
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Alasan: Perlu menghadiri acara keluarga',
                style: TextStyle(
                  fontFamily: "StageGrotesk_Regular",
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}