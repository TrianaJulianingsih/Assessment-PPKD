import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
      body: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, index) => Card(
        margin: EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Container(
            height: 80,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white
            ),
            child: Column(
              children: [
                
              ],
            ),
          ),
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
    ),
    );
  }
}