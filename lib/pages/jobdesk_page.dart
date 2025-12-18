import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobdeskPage extends StatefulWidget {
  const JobdeskPage({super.key});

  @override
  State<JobdeskPage> createState() => _JobdeskPageState();
}

class _JobdeskPageState extends State<JobdeskPage> {
  final CollectionReference jobdeskRef =
      FirebaseFirestore.instance.collection('jobdesk');

  // ================= ADD & EDIT =================
  void _showForm({DocumentSnapshot? doc}) {
    final formKey = GlobalKey<FormState>();
    final judulC = TextEditingController(text: doc?['judul']);
    final deskC = TextEditingController(text: doc?['deskripsi']);
    final deadlineC = TextEditingController(text: doc?['deadline']);
    String? status = doc?['status'];

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                doc == null ? "Tambah Jobdesk" : "Edit Jobdesk",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00ABB6),
                ),
              ),
              const SizedBox(height: 12),
              _field(judulC, "Judul Jobdesk"),
              _field(deskC, "Deskripsi"),
              _field(deadlineC, "Deadline (YYYY-MM-DD)"),
              _dropdown(
                "Status",
                status,
                ["Belum Selesai", "Proses", "Selesai"],
                (v) => status = v,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: Icon(doc == null ? Icons.add : Icons.save),
                label: const Text("Simpan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00ABB6),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final data = {
                      "judul": judulC.text,
                      "deskripsi": deskC.text,
                      "deadline": deadlineC.text,
                      "status": status,
                    };

                    if (doc == null) {
                      await jobdeskRef.add(data);
                    } else {
                      await jobdeskRef.doc(doc.id).update(data);
                    }

                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
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
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("Jobdesk"),
        backgroundColor: const Color(0xFF00ABB6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showForm(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: jobdeskRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada jobdesk"));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: snapshot.data!.docs.map((doc) {
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
                      } else {
                        _hapus(doc.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: "edit",
                        child: Text("Edit"),
                      ),
                      PopupMenuItem(
                        value: "hapus",
                        child: Text("Hapus"),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked
    );
  }

  // ================= HELPER =================
  Widget _field(TextEditingController c, String label) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextFormField(
          controller: c,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          validator: (v) =>
              v!.isEmpty ? "Wajib diisi" : null,
        ),
      );

  Widget _dropdown(String label, String? value,
          List<String> items, Function(String?) onChanged) =>
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
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
