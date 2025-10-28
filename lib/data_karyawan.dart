import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sistem Etos Kerja - Data Karyawan',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00ABB6)),
      useMaterial3: true,
    ),
    home: const DataKaryawanPage(),
  );
}

class DataKaryawanPage extends StatefulWidget {
  const DataKaryawanPage({super.key});
  @override
  State<DataKaryawanPage> createState() => _DataKaryawanPageState();
}

class _DataKaryawanPageState extends State<DataKaryawanPage> {
  final TextEditingController searchController = TextEditingController();
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
  List<Map<String, String>> filteredKaryawan = [];

  @override
  void initState() {
    super.initState();
    filteredKaryawan = List.from(dataKaryawan);
    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      setState(() {
        filteredKaryawan = dataKaryawan
            .where((k) => k["nama"]!.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  void _saveKaryawan({
    Map<String, String>? awal,
    int? index,
    required Map<String, String> data,
  }) {
    setState(() {
      if (awal != null && index != null) {
        dataKaryawan[index] = data;
      } else {
        dataKaryawan.add(data);
      }
      filteredKaryawan = List.from(dataKaryawan);
    });
  }

  void _hapusKaryawan(int index) {
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
              filteredKaryawan = List.from(dataKaryawan);
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: "Ketik nama karyawan...",
            prefixIcon: Icon(Icons.search, color: Colors.black),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      );

  void _showForm({Map<String, String>? dataAwal, int? editIndex}) {
    final isEdit = dataAwal != null;
    final formKey = GlobalKey<FormState>();
    final controller = {
      "id": TextEditingController(text: dataAwal?['id'] ?? ''),
      "nama": TextEditingController(text: dataAwal?['nama'] ?? ''),
      "email": TextEditingController(text: dataAwal?['email'] ?? ''),
      "telepon": TextEditingController(text: dataAwal?['telepon'] ?? ''),
    };
    String? role = dataAwal?['role'], status = dataAwal?['status'];

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                isEdit ? "Edit Data Karyawan" : "Tambah Data Karyawan",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00ABB6),
                ),
              ),
              const SizedBox(height: 15),
              _buildField(controller["id"]!, "ID Karyawan", readOnly: isEdit),
              _buildField(controller["nama"]!, "Nama"),
              _buildField(
                controller["email"]!,
                "Email",
                type: TextInputType.emailAddress,
              ),
              _buildField(
                controller["telepon"]!,
                "Telepon",
                type: TextInputType.phone,
              ),
              _buildDropdown("Role", role, [
                "Manager",
                "Karyawan",
              ], (v) => role = v),
              _buildDropdown("Status", status, [
                "Aktif",
                "Nonaktif",
              ], (v) => status = v),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(isEdit ? Icons.save : Icons.add),
                label: Text(isEdit ? "Update" : "Simpan"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF00ABB6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    _saveKaryawan(
                      awal: dataAwal,
                      index: editIndex,
                      data: {
                        "id": controller["id"]!.text,
                        "nama": controller["nama"]!.text,
                        "email": controller["email"]!.text,
                        "telepon": controller["telepon"]!.text,
                        "role": role!,
                        "status": status!,
                      },
                    );
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController c,
    String label, {
    bool readOnly = false,
    TextInputType? type,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: c,
      readOnly: readOnly,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
    ),
  );

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: DropdownButtonFormField(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? "Pilih $label" : null,
    ),
  );

  Widget _statusBadge(String status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: status == "Aktif" ? Colors.green[100] : Colors.red[100],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: status == "Aktif" ? Colors.green[800] : Colors.red[800],
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfff5f7fa),
    appBar: AppBar(
      title: const Text(
        "Data Karyawan",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: const Color(0xFF00ABB6),
      foregroundColor: Colors.white,
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _showForm,
      icon: const Icon(Icons.add),
      label: const Text("Tambah"),
      backgroundColor: const Color(0xFF00ABB6),
      foregroundColor: Colors.white,
    ),
    body: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cari Data Karyawan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00ABB6),
            ),
          ),
          const SizedBox(height: 8),
          _searchBox(),
          const SizedBox(height: 16),
          const Text(
            "Data Karyawan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00ABB6),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: filteredKaryawan.isEmpty
                ? const Center(child: Text("Tidak ada hasil ditemukan"))
                : ListView.builder(
                    itemCount: filteredKaryawan.length,
                    itemBuilder: (_, i) {
                      final k = filteredKaryawan[i];
                      return Card(
                        color: Colors.white,
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.blueAccent.withOpacity(0.1),
                            child: Icon(
                              k["role"] == "Manager"
                                  ? Icons.manage_accounts
                                  : Icons.person,
                              color: Colors.blueAccent,
                            ),
                          ),
                          title: Text(
                            k["nama"]!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                k["email"]!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 14,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    k["telepon"]!,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    "Role: ${k['role']}",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(width: 8),
                                  _statusBadge(k["status"]!),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) => v == "edit"
                                ? _showForm(dataAwal: k, editIndex: i)
                                : _hapusKaryawan(i),
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: "edit", child: Text("Edit")),
                              PopupMenuItem(
                                value: "hapus",
                                child: Text("Hapus"),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}
