import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Etos Kerja - Data Karyawan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const DataKaryawanPage(),
    );
  }
}

class DataKaryawanPage extends StatefulWidget {
  const DataKaryawanPage({super.key});

  @override
  State<DataKaryawanPage> createState() => _DataKaryawanPageState();
}

class _DataKaryawanPageState extends State<DataKaryawanPage> {
  List<Map<String, String>> dataKaryawan = [
    {
      "id": "001",
      "nama": "John Doe",
      "email": "john@example.com",
      "telepon": "08123456789",
      "role": "Karyawan",
      "status": "Aktif",
    },
    {
      "id": "002",
      "nama": "Jane Smith",
      "email": "jane@example.com",
      "telepon": "08987654321",
      "role": "Manager",
      "status": "Nonaktif",
    },
  ];

  void tambahKaryawan(Map<String, String> data) {
    setState(() => dataKaryawan.add(data));
  }

  void editKaryawan(int index, Map<String, String> dataBaru) {
    setState(() => dataKaryawan[index] = dataBaru);
  }

  void hapusKaryawan(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => dataKaryawan.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void showForm({Map<String, String>? dataAwal, int? editIndex}) {
    final isEdit = dataAwal != null;
    final formKey = GlobalKey<FormState>();
    final idController = TextEditingController(text: dataAwal?['id'] ?? '');
    final namaController = TextEditingController(text: dataAwal?['nama'] ?? '');
    final emailController = TextEditingController(text: dataAwal?['email'] ?? '');
    final teleponController = TextEditingController(text: dataAwal?['telepon'] ?? '');
    String? role = dataAwal?['role'];
    String? status = dataAwal?['status'];

    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEdit ? "Edit Data Karyawan" : "Tambah Data Karyawan",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: "ID Karyawan",
                    border: OutlineInputBorder(),
                  ),
                  readOnly: isEdit,
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: "Nama",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: teleponController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Telepon",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(
                    labelText: "Role",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Manager", child: Text("Manager")),
                    DropdownMenuItem(value: "Karyawan", child: Text("Karyawan")),
                  ],
                  onChanged: (val) => role = val,
                  validator: (v) => v == null ? "Pilih Role" : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Aktif", child: Text("Aktif")),
                    DropdownMenuItem(value: "Nonaktif", child: Text("Nonaktif")),
                  ],
                  onChanged: (val) => status = val,
                  validator: (v) => v == null ? "Pilih Status" : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(isEdit ? Icons.save : Icons.add),
                  label: Text(isEdit ? "Update" : "Simpan"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newData = {
                        "id": idController.text,
                        "nama": namaController.text,
                        "email": emailController.text,
                        "telepon": teleponController.text,
                        "role": role!,
                        "status": status!,
                      };
                      Navigator.pop(context);
                      if (isEdit && editIndex != null) {
                        editKaryawan(editIndex, newData);
                      } else {
                        tambahKaryawan(newData);
                      }
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget statusBadge(String status) {
    final bool aktif = status == "Aktif";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: aktif
              ? [Colors.greenAccent.shade100, Colors.green.shade300]
              : [Colors.redAccent.shade100, Colors.red.shade300],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f5f9),
      appBar: AppBar(
        title: const Text(
          "Data Karyawan",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showForm(),
        icon: const Icon(Icons.add),
        label: const Text("Tambah"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: dataKaryawan.isEmpty
            ? const Center(child: Text("Belum ada data karyawan"))
            : ListView.builder(
                itemCount: dataKaryawan.length,
                itemBuilder: (context, index) {
                  final k = dataKaryawan[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.blueAccent.withOpacity(0.03),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blueAccent.withOpacity(0.15),
                        child: Icon(
                          k["role"] == "Manager"
                              ? Icons.manage_accounts
                              : Icons.person_outline,
                          color: Colors.blueAccent,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        k["nama"] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(k["email"] ?? "",
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 13)),
                            Text("📞 ${k['telepon']}",
                                style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    k['role'] ?? "",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                statusBadge(k['status'] ?? ""),
                              ],
                            ),
                          ],
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == "edit") {
                            showForm(dataAwal: k, editIndex: index);
                          } else if (value == "hapus") {
                            hapusKaryawan(index);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: "edit", child: Text("Edit")),
                          PopupMenuItem(value: "hapus", child: Text("Hapus")),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}