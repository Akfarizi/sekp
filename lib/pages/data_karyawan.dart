import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataKaryawanPage extends StatefulWidget {
  const DataKaryawanPage({super.key});

  @override
  State<DataKaryawanPage> createState() => _DataKaryawanPageState();
}

class _DataKaryawanPageState extends State<DataKaryawanPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final usersRef = FirebaseFirestore.instance.collection('users');
  final etosRef = FirebaseFirestore.instance.collection('etos_kerja');

  String search = "";
  String roleUser = "";

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final doc = await usersRef.doc(user.uid).get();
    roleUser = doc.data()?['role'] ?? 'Karyawan';
    setState(() {});
  }

  // ================= EDIT USER =================
  void _editUser(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final namaC = TextEditingController(text: data['nama'] ?? '');
    String status = data['status'] ?? 'Aktif';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Karyawan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaC,
              decoration: const InputDecoration(labelText: "Nama"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(labelText: "Status"),
              items: const [
                DropdownMenuItem(value: "Aktif", child: Text("Aktif")),
                DropdownMenuItem(value: "Nonaktif", child: Text("Nonaktif")),
              ],
              onChanged: (v) => status = v ?? status,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await usersRef.doc(doc.id).update({
                "nama": namaC.text,
                "status": status,
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (roleUser.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Karyawan"),
        backgroundColor: const Color(0xFF00ABB6),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Cari nama karyawan",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() {
                search = v.toLowerCase();
              }),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final nama =
                      (doc['nama'] ?? '').toString().toLowerCase();
                  return nama.contains(search);
                });

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ================= HEADER =================
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  data['nama'] ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (roleUser == "Admin")
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editUser(doc),
                                  ),
                              ],
                            ),

                            Text(data['email'] ?? '-'),
                            Text("Role: ${data['role'] ?? '-'}"),

                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Text("Status: "),
                                _statusBadge(data['status'] ?? 'Aktif'),
                              ],
                            ),

                            const Divider(),

                            // ================= INDIKATOR ETOS =================
                            _etosIndicator(doc.id),
                          ],
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

  // ================= ETOS INDICATOR =================
  Widget _etosIndicator(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: etosRef.where('uid', isEqualTo: uid).limit(1).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text(
            "Etos Kerja: Belum Dinilai",
            style: TextStyle(color: Colors.grey),
          );
        }

        final d = snapshot.data!.docs.first.data() as Map<String, dynamic>;

        final avg = ((d['disiplin'] +
                    d['inisiatif'] +
                    d['kerjasama'] +
                    d['tanggungjawab']) /
                4)
            .toDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Etos Kerja (Avg ${avg.toStringAsFixed(1)}/5)",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: avg / 5,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation(
                Color(0xFF00ABB6),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ================= STATUS BADGE =================
Widget _statusBadge(String status) {
  final isActive = status == "Aktif";

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: isActive ? Colors.green[100] : Colors.red[100],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: isActive ? Colors.green[800] : Colors.red[800],
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}
