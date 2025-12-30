import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EtosFormPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;

  const EtosFormPage({super.key, this.docId, this.existingData});

  @override
  State<EtosFormPage> createState() => _EtosFormPageState();
}

class _EtosFormPageState extends State<EtosFormPage> {
  String? selectedUid;
  String? selectedNama;

  int disiplin = 3;
  int inisiatif = 3;
  int kerjasama = 3;
  int tanggungjawab = 3;

  final catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      final d = widget.existingData!;
      selectedUid = d['uid'];
      selectedNama = d['nama'];
      disiplin = d['disiplin'];
      inisiatif = d['inisiatif'];
      kerjasama = d['kerjasama'];
      tanggungjawab = d['tanggungjawab'];
      catatanController.text = d['catatan'] ?? '';
    }
  }

  Future<void> _submit() async {
    if (selectedUid == null || selectedNama == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih karyawan terlebih dahulu")),
      );
      return;
    }

    final data = {
      "uid": selectedUid, // 🔑 FIX
      "nama": selectedNama,
      "disiplin": disiplin,
      "inisiatif": inisiatif,
      "kerjasama": kerjasama,
      "tanggungjawab": tanggungjawab,
      "catatan": catatanController.text,
      "periode": DateTime.now().toString().substring(0, 7),
      "createdAt": Timestamp.now(),
    };

    final ref = FirebaseFirestore.instance.collection('etos_kerja');

    if (widget.docId == null) {
      await ref.add(data);
    } else {
      await ref.doc(widget.docId).update(data);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docId == null ? "Tambah Etos" : "Edit Etos"),
        backgroundColor: const Color(0xFF00ABB6),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SELECT KARYAWAN (DISABLE SAAT EDIT)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'Karyawan')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                return DropdownButtonFormField<String>(
                  value: selectedUid,
                  hint: const Text("Pilih Karyawan"),
                  items: snapshot.data!.docs.map((doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(d['nama'] ?? d['email']),
                    );
                  }).toList(),
                  onChanged: widget.docId != null
                      ? null
                      : (val) {
                          final d =
                              snapshot.data!.docs
                                      .firstWhere((e) => e.id == val)
                                      .data()
                                  as Map<String, dynamic>;

                          setState(() {
                            selectedUid = val;
                            selectedNama = d['nama'];
                          });
                        },
                );
              },
            ),

            const SizedBox(height: 12),
            _slider("Disiplin", disiplin, (v) => setState(() => disiplin = v)),
            _slider(
              "Inisiatif",
              inisiatif,
              (v) => setState(() => inisiatif = v),
            ),
            _slider(
              "Kerja Sama",
              kerjasama,
              (v) => setState(() => kerjasama = v),
            ),
            _slider(
              "Tanggung Jawab",
              tanggungjawab,
              (v) => setState(() => tanggungjawab = v),
            ),

            TextField(
              controller: catatanController,
              decoration: const InputDecoration(labelText: "Catatan"),
            ),

            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: const Text("Simpan")),
          ],
        ),
      ),
    );
  }

  Widget _slider(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $value"),
        Slider(
          min: 1,
          max: 5,
          divisions: 4,
          value: value.toDouble(),
          onChanged: (v) => onChanged(v.toInt()),
        ),
      ],
    );
  }
}
