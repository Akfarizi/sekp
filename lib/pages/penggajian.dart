import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataPenggajianPage extends StatefulWidget {
  const DataPenggajianPage({super.key});

  @override
  State<DataPenggajianPage> createState() => _DataPenggajianPageState();
}

class _DataPenggajianPageState extends State<DataPenggajianPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final penggajianRef = FirebaseFirestore.instance.collection('penggajian');
  final usersRef = FirebaseFirestore.instance.collection('users');

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

  // ================= FORM =================
  void _showForm({DocumentSnapshot? doc}) async {
    final formKey = GlobalKey<FormState>();

    String? selectedUid = doc?['uid'];
    String nama = doc?['nama'] ?? '';
    final gajiC =
        TextEditingController(text: doc?['gaji_pokok']?.toString() ?? '');
    final tanggalC =
        TextEditingController(text: doc?['tanggal'] ?? '');

    final usersSnap = await usersRef.get();

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
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  doc == null ? "Tambah Penggajian" : "Edit Penggajian",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00ABB6),
                  ),
                ),
                const SizedBox(height: 16),

                /// SELECT KARYAWAN
                DropdownButtonFormField<String>(
                  value: selectedUid,
                  items: usersSnap.docs.map((u) {
                    final d = u.data();
                    return DropdownMenuItem(
                      value: u.id,
                      child: Text(d['nama'] ?? '-'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    selectedUid = v;
                    final u = usersSnap.docs
                        .firstWhere((e) => e.id == v);
                    nama = u['nama'];
                  },
                  decoration: const InputDecoration(
                    labelText: "Karyawan",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null ? "Pilih karyawan" : null,
                ),

                const SizedBox(height: 10),

                /// TANGGAL
                TextFormField(
                  controller: tanggalC,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Tanggal",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final now = DateTime.now();
                    final pick = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (pick != null) {
                      tanggalC.text =
                          "${pick.year}-${pick.month.toString().padLeft(2, '0')}-${pick.day.toString().padLeft(2, '0')}";
                    }
                  },
                  validator: (v) =>
                      v!.isEmpty ? "Tanggal wajib" : null,
                ),

                const SizedBox(height: 10),

                /// GAJI
                TextFormField(
                  controller: gajiC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Gaji Pokok",
                    border: OutlineInputBorder(),
                    prefixText: "Rp ",
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "Gaji wajib" : null,
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00ABB6),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final data = {
                      "uid": selectedUid,
                      "nama": nama,
                      "tanggal": tanggalC.text,
                      "gaji_pokok": gajiC.text,
                    };

                    if (doc == null) {
                      await penggajianRef.add(data);
                    } else {
                      await penggajianRef.doc(doc.id).update(data);
                    }

                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                ),
              ],
            ),
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
        title: const Text("Hapus"),
        content: const Text("Yakin hapus data ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await penggajianRef.doc(id).delete();
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

    final stream = roleUser == "Admin"
        ? penggajianRef.snapshots()
        : penggajianRef
            .where('uid', isEqualTo: user.uid)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Penggajian"),
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Cari nama karyawan",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  setState(() => search = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (_, s) {
                if (!s.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs = s.data!.docs.where((d) {
                  final nama =
                      (d['nama'] ?? '').toString().toLowerCase();
                  return nama.contains(search);
                });

                if (docs.isEmpty) {
                  return const Center(
                      child: Text("Belum ada data"));
                }

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: docs.map((doc) {
                    return Card(
                      child: ListTile(
                        title: Text(doc['nama']),
                        subtitle: Text(
                          "Tanggal: ${doc['tanggal']}\nGaji: Rp ${doc['gaji_pokok']}",
                        ),
                        trailing: roleUser == "Admin"
                            ? PopupMenuButton(
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
                                    child: Text(
                                      "Hapus",
                                      style:
                                          TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
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
