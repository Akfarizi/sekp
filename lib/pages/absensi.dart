import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final absensiRef = FirebaseFirestore.instance.collection('absensi');
  final usersRef = FirebaseFirestore.instance.collection('users');

  String roleUser = "";

  @override
  void initState() {
    super.initState();
    _loadRole();
    print("ROLE USER LOGIN: $roleUser");
  }

  Future<void> _loadRole() async {
    final doc = await usersRef.doc(user.uid).get();
    roleUser = doc.data()?['role'] ?? "Karyawan";
    setState(() {});
  }

  /// ================= STREAM =================
  Stream<QuerySnapshot> streamAbsensi() {
    if (roleUser == "Admin") {
      return FirebaseFirestore.instance.collection('absensi').snapshots();
    }

    return FirebaseFirestore.instance
        .collection('absensi')
        .where('uid', isEqualTo: user.uid)
        .snapshots();
  }

  /// ================= ABSEN =================
  Future<void> absen(String status) async {
    final now = DateTime.now();

    await absensiRef.add({
      "uid": user.uid,
      "email": user.email,
      "status": status,
      "tanggal": DateFormat('yyyy-MM-dd').format(now),
      "waktu": DateFormat('HH:mm').format(now),
      "createdAt": Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (roleUser.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(roleUser == "Admin" ? "Absensi Karyawan" : "Absensi Saya"),
        backgroundColor: const Color(0xFF00ABB6),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: streamAbsensi(),
        builder: (context, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!s.hasData || s.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada data absensi"));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: s.data!.docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: Icon(
                    d['status'] == "Masuk" ? Icons.login : Icons.logout,
                    color: d['status'] == "Masuk" ? Colors.green : Colors.red,
                  ),
                  title: Text(d['email'] ?? "-"),
                  subtitle: Text("${d['tanggal']} • ${d['waktu']}"),
                  trailing: Text(
                    d['status'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),

      /// 🔒 BUTTON HANYA UNTUK KARYAWAN
      bottomNavigationBar: roleUser == "Admin"
          ? null
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => absen("Masuk"),
                    icon: const Icon(Icons.login),
                    label: const Text("Masuk"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => absen("Keluar"),
                    icon: const Icon(Icons.logout),
                    label: const Text("Keluar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
