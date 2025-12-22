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

  String search = "";
  String roleUser = "";

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final doc = await usersRef.doc(user.uid).get();

    if (doc.exists && doc.data() != null) {
      roleUser = doc.data()!['role'] ?? 'Karyawan';
    } else {
      roleUser = 'Karyawan';
    }

    setState(() {});
  }

  // ================= EDIT USER (ADMIN ONLY) =================
  void _editUser(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final namaC = TextEditingController(
      text: data['nama'] ?? '',
    );

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
                DropdownMenuItem(
                  value: "Aktif",
                  child: Text("Aktif"),
                ),
                DropdownMenuItem(
                  value: "Nonaktif",
                  child: Text("Nonaktif"),
                ),
              ],
              onChanged: (v) {
                if (v != null) status = v;
              },
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
              onChanged: (v) {
                setState(() {
                  search = v.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Belum ada data user"),
                  );
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>;
                  final nama =
                      (data['nama'] ?? '').toString().toLowerCase();
                  return nama.contains(search);
                });

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: docs.map((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        title: Text(data['nama'] ?? '-'),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(data['email'] ?? '-'),
                            Text("Role: ${data['role'] ?? '-'}"),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text("Status: "),
                                _statusBadge(
                                  data['status'] ?? 'Aktif',
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: roleUser == "Admin"
                            ? IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _editUser(doc),
                              )
                            : null,
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

// ================= STATUS BADGE =================
Widget _statusBadge(String status) {
  final isActive = status == "Aktif";

  return Container(
    padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: isActive ? Colors.green[100] : Colors.red[100],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: isActive
            ? Colors.green[800]
            : Colors.red[800],
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}
