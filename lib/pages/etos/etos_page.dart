import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'etos_form_page.dart';

class EtosPage extends StatelessWidget {
  final String roleUser;
  const EtosPage({super.key, required this.roleUser});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    // 🔑 FILTER QUERY SESUAI ROLE
    final query = roleUser == "Admin"
    ? FirebaseFirestore.instance.collection('etos_kerja')
    : FirebaseFirestore.instance
        .collection('etos_kerja')
        .where('uid', isEqualTo: user.uid);


    return Scaffold(
      appBar: AppBar(
        title: const Text("Penilaian Etos Kerja"),
        backgroundColor: const Color(0xFF00ABB6),
        foregroundColor: Colors.white,
        actions: roleUser == "Admin"
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EtosFormPage(),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Belum ada data penilaian etos"),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: snapshot.data!.docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;

              return _etosCard(
                context: context,
                docId: doc.id,
                data: d,
                isAdmin: roleUser == "Admin",
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ================= CARD UI =================
  Widget _etosCard({
    required BuildContext context,
    required String docId,
    required Map<String, dynamic> data,
    required bool isAdmin,
  }) {
    final avg = ((data['disiplin'] +
                data['inisiatif'] +
                data['kerjasama'] +
                data['tanggungjawab']) /
            4)
        .toStringAsFixed(1);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['nama'] ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text("Avg $avg"),
                  backgroundColor: const Color(0xFF00ABB6).withOpacity(0.15),
                  labelStyle: const TextStyle(
                    color: Color(0xFF00ABB6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            _row("Disiplin", data['disiplin']),
            _row("Inisiatif", data['inisiatif']),
            _row("Kerja Sama", data['kerjasama']),
            _row("Tanggung Jawab", data['tanggungjawab']),

            if ((data['catatan'] ?? '').toString().isNotEmpty) ...[
              const Divider(),
              Text(
                "Catatan:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(data['catatan']),
            ],

            if (isAdmin) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("Edit"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EtosFormPage(
                            docId: docId,
                            existingData: data,
                          ),
                        ),
                      );
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    label: const Text(
                      "Hapus",
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () => _confirmDelete(context, docId),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Penilaian"),
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('etos_kerja')
                  .doc(docId)
                  .delete();
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}
