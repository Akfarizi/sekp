import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobdeskPage extends StatefulWidget {
  const JobdeskPage({super.key});

  @override
  State<JobdeskPage> createState() => _JobdeskPageState();
}

class _JobdeskPageState extends State<JobdeskPage> {
  final jobdeskRef = FirebaseFirestore.instance.collection('jobdesk');
  final usersRef = FirebaseFirestore.instance.collection('users');
  final user = FirebaseAuth.instance.currentUser!;

  String roleUser = "";
  String search = "";

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

  // ================= ADD & EDIT =================
  void _showForm({DocumentSnapshot? doc}) {
    final formKey = GlobalKey<FormState>();

    final judulC =
        TextEditingController(text: doc == null ? "" : doc['judul']);
    final deskC =
        TextEditingController(text: doc == null ? "" : doc['deskripsi']);
    final deadlineC =
        TextEditingController(text: doc == null ? "" : doc['deadline']);

    String? status = doc == null ? "Belum Selesai" : doc['status'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Text(
                        doc == null
                            ? "Tambah Jobdesk"
                            : "Edit Jobdesk",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00ABB6),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _field(judulC, "Judul Jobdesk",
                          enabled: roleUser == "Admin"),
                      _field(deskC, "Deskripsi",
                          enabled: roleUser == "Admin"),

                      _buildDateField(
                        deadlineC,
                        "Deadline",
                        enabled: roleUser == "Admin",
                      ),

                      _dropdown(
                        "Status",
                        status,
                        ["Belum Selesai", "Proses", "Selesai"],
                        (v) => status = v,
                      ),

                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF00ABB6),
                          minimumSize:
                              const Size(double.infinity, 48),
                        ),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          Map<String, dynamic> data = {
                            "status": status,
                          };

                          if (roleUser == "Admin") {
                            data.addAll({
                              "judul": judulC.text,
                              "deskripsi": deskC.text,
                              "deadline": deadlineC.text,
                            });
                          }

                          if (doc == null) {
                            await jobdeskRef.add(data);
                          } else {
                            await jobdeskRef.doc(doc.id).update(data);
                          }

                          Navigator.pop(context);
                        },
                        child: const Text("Simpan"),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= DELETE =================
  void _hapus(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Jobdesk"),
        content: const Text("Yakin ingin menghapus jobdesk ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await jobdeskRef.doc(id).delete();
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
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
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("Jobdesk"),
        backgroundColor: const Color(0xFF00ABB6),
        foregroundColor: Colors.white,
        actions: [
          if (roleUser == "Admin")
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showForm(),
            ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Cari judul jobdesk",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  setState(() => search = v.toLowerCase()),
            ),
          ),

          // LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: jobdeskRef.snapshots(),
              builder: (context, s) {
                if (s.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!s.hasData || s.data!.docs.isEmpty) {
                  return const Center(child: Text("Belum ada jobdesk"));
                }

                final docs = s.data!.docs.where((d) {
                  final judul =
                      (d['judul'] ?? '').toString().toLowerCase();
                  return judul.contains(search);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("Data tidak ditemukan"));
                }

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: docs.map((doc) {
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        title: Text(
                          doc['judul'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc['deskripsi']),
                            const SizedBox(height: 4),
                            Text("Deadline: ${doc['deadline']}"),
                            const SizedBox(height: 4),
                            _statusBadge(doc['status']),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          onSelected: (v) {
                            if (v == "edit") {
                              _showForm(doc: doc);
                            } else if (v == "hapus") {
                              _hapus(doc.id);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: "edit",
                              child: Text("Edit"),
                            ),
                            if (roleUser == "Admin")
                              const PopupMenuItem(
                                value: "hapus",
                                child: Text(
                                  "Hapus",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
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

  // ================= HELPER =================
  Widget _field(
    TextEditingController c,
    String label, {
    bool enabled = true,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextFormField(
          controller: c,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
        ),
      );

  Widget _buildDateField(
    TextEditingController c,
    String label, {
    bool enabled = true,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: c,
          readOnly: true,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          onTap: !enabled
              ? null
              : () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    c.text =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  }
                },
          validator: (v) => v!.isEmpty ? "Tanggal wajib diisi" : null,
        ),
      );

  Widget _dropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: DropdownButtonFormField(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: items
              .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? "Pilih $label" : null,
        ),
      );

  Widget _statusBadge(String status) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: status == "Selesai"
              ? Colors.green[100]
              : Colors.orange[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: status == "Selesai"
                ? Colors.green[800]
                : Colors.orange[800],
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
