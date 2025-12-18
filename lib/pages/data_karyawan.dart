import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import '../widgets/navbar.dart';

class DataKaryawanPage extends StatefulWidget {
  const DataKaryawanPage({super.key});

  @override
  State<DataKaryawanPage> createState() => _DataKaryawanPageState();
}

class _DataKaryawanPageState extends State<DataKaryawanPage> {
  final TextEditingController searchController = TextEditingController();
  final CollectionReference karyawanRef =
      FirebaseFirestore.instance.collection('karyawan');

  String searchQuery = "";

  // ================= ADD & EDIT =================
  void _showForm({DocumentSnapshot? doc}) {
    final formKey = GlobalKey<FormState>();
    final idC = TextEditingController(text: doc?['id']);
    final namaC = TextEditingController(text: doc?['nama']);
    final emailC = TextEditingController(text: doc?['email']);
    final telpC = TextEditingController(text: doc?['telepon']);
    String? role = doc?['role'];
    String? status = doc?['status'];

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
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
                doc == null ? "Tambah Karyawan" : "Edit Karyawan",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00ABB6),
                ),
              ),
              const SizedBox(height: 12),
              _field(idC, "ID"),
              _field(namaC, "Nama"),
              _field(emailC, "Email",
                  type: TextInputType.emailAddress),
              _field(telpC, "Telepon",
                  type: TextInputType.phone),
              _dropdown("Role", role, ["Manager", "Karyawan"],
                  (v) => role = v),
              _dropdown("Status", status, ["Aktif", "Nonaktif"],
                  (v) => status = v),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00ABB6),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text("Simpan"),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final data = {
                      "id": idC.text,
                      "nama": namaC.text,
                      "email": emailC.text,
                      "telepon": telpC.text,
                      "role": role,
                      "status": status,
                    };

                    if (doc == null) {
                      await karyawanRef.add(data);
                    } else {
                      await karyawanRef.doc(doc.id).update(data);
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
        title: const Text("Hapus Data"),
        content: const Text("Yakin ingin menghapus karyawan ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await karyawanRef.doc(id).delete();
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
        title: const Text("Data Karyawan"),
        backgroundColor: const Color(0xFF00ABB6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showForm(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Cari nama...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) =>
                  setState(() => searchQuery = v.toLowerCase()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: karyawanRef.snapshots(),
                builder: (c, s) {
                  if (s.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final data = s.data!.docs.where((d) =>
                      d['nama']
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery));

                  if (data.isEmpty) {
                    return const Center(
                        child: Text("Data kosong"));
                  }

                  return ListView(
                    children: data.map((doc) {
                      return Card(
                        child: ListTile(
                          title: Text(doc['nama']),
                          subtitle: Text(doc['email']),
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
                                  child: Text("Edit")),
                              PopupMenuItem(
                                  value: "hapus",
                                  child: Text("Hapus")),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

    );
  }

  // ================= WIDGET HELPER =================
  Widget _field(TextEditingController c, String label,
          {TextInputType? type}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextFormField(
          controller: c,
          keyboardType: type,
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
}
