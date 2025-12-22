import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User user = FirebaseAuth.instance.currentUser!;
  final CollectionReference absensiRef =
      FirebaseFirestore.instance.collection('absensi');

  /// ================= TAMBAH ABSENSI =================
  Future<void> _tambahAbsensi(String status) async {
    try {
      final now = DateTime.now();

      await absensiRef.add({
        "uid": user.uid,
        "email": user.email ?? "-",
        "tanggal": DateFormat('yyyy-MM-dd').format(now),
        "waktu": DateFormat('HH:mm').format(now),
        "status": status,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Absen $status berhasil")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal absen: $e")),
      );
    }
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: const Color(0xFF00ABB6),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          /// ================= BUTTON ABSENSI =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _tambahAbsensi("Masuk"),
                  icon: const Icon(Icons.login),
                  label: const Text("Masuk"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(140, 48),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _tambahAbsensi("Keluar"),
                  icon: const Icon(Icons.logout),
                  label: const Text("Keluar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(140, 48),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// ================= LIST ABSENSI =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: absensiRef
                  .where('uid', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("Belum ada data absensi"));
                }

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: snapshot.data!.docs.map((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          data['status'] == 'Masuk'
                              ? Icons.login
                              : Icons.logout,
                          color: data['status'] == 'Masuk'
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text(data['email'] ?? '-'),
                        subtitle: Text(
                          "${data['tanggal']} • ${data['waktu']}",
                        ),
                        trailing: Text(
                          data['status'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
