import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final etosRef = FirebaseFirestore.instance.collection('etos_kerja');
  final user = FirebaseAuth.instance.currentUser!;

  double _avg(Map<String, dynamic> d) {
    return ((d['disiplin'] +
                d['inisiatif'] +
                d['kerjasama'] +
                d['tanggungjawab']) /
            4)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Kinerja"),
        backgroundColor: const Color(0xFF00ABB6),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: etosRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Belum ada data penilaian etos"),
            );
          }

          // ================= HITUNG DATA =================
          final data = snapshot.data!.docs.map((e) {
            final d = e.data() as Map<String, dynamic>;
            return {
              ...d,
              "avg": _avg(d),
            };
          }).toList();

          data.sort((a, b) => b['avg'].compareTo(a['avg']));

          final top3 = data.take(3).toList();
          final myData =
              data.where((e) => e['uid'] == user.uid).toList();

          // ================= UI =================
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // ================= TOP KARYAWAN =================
              const Text(
                "🏆 Karyawan Terbaik",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: top3.map((d) {
                  return Expanded(
                    child: _topCard(
                      d['nama'],
                      d['avg'],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ================= POSISI SAYA =================
              if (myData.isNotEmpty) ...[
                const Text(
                  "📊 Performa Saya",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _myPerformance(myData.first, data),
              ],

              const SizedBox(height: 20),

              // ================= RANKING =================
              const Text(
                "📋 Ranking Karyawan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              ...data.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF00ABB6),
                      child: Text("${i + 1}"),
                    ),
                    title: Text(d['nama']),
                    trailing: Text(
                      d['avg'].toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  // ================= TOP CARD =================
  Widget _topCard(String nama, double avg) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 30),
            const SizedBox(height: 6),
            Text(
              nama,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text("${avg.toStringAsFixed(1)} / 5"),
          ],
        ),
      ),
    );
  }

  // ================= PERFORMA SAYA =================
  Widget _myPerformance(Map<String, dynamic> d, List all) {
    final rank =
        all.indexWhere((e) => e['uid'] == d['uid']) + 1;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              d['nama'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text("Rata-rata Etos Kerja: ${d['avg'].toStringAsFixed(1)}"),
            Text("Peringkat: #$rank dari ${all.length}"),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: d['avg'] / 5,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              valueColor: const AlwaysStoppedAnimation(
                Color(0xFF00ABB6),
              ),
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}
