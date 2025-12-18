import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import 'absensi.dart';
import 'data_karyawan.dart';
import 'jobdesk_page.dart';
import 'profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Etos Kerja - Data Jobdesk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00ABB6)),
        useMaterial3: true,
      ),
      home: const JobdeskPage(),
    );
  }
}

class JobdeskPage extends StatefulWidget {
  const JobdeskPage({super.key});

  @override
  State<JobdeskPage> createState() => _JobdeskPageState();
}

class _JobdeskPageState extends State<JobdeskPage> {
  int currentIndex = 0;
  List<Map<String, String>> dataJobdesk = [
    {
      "id": "J001",
      "nama_jobdesk": "Desainer UI/UX",
      "tugas_utama": "Mendesain tampilan dan pengalaman pengguna aplikasi.",
      "nama_karyawan": "John Doe",
    },
    {
      "id": "J002",
      "nama_jobdesk": "Backend Developer",
      "tugas_utama": "Mengembangkan dan memelihara API serta database server.",
      "nama_karyawan": "Jane Smith",
    },
  ];

  void tambahJobdesk(Map<String, String> data) {
    setState(() => dataJobdesk.add(data));
  }

  void editJobdesk(int index, Map<String, String> dataBaru) {
    setState(() => dataJobdesk[index] = dataBaru);
  }

  void hapusJobdesk(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin ingin menghapus jobdesk ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => dataJobdesk.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // === Tambahan Search Box ===
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
        hintText: "Ketik nama jobdesk...",
        prefixIcon: Icon(Icons.search, color: Colors.black),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    ),
  );

  // === Form tambah/edit jobdesk ===
  void showFormJobdesk({Map<String, String>? dataAwal, int? editIndex}) {
    final isEdit = dataAwal != null;
    final formKey = GlobalKey<FormState>();
    final idController = TextEditingController(text: dataAwal?['id'] ?? '');
    final namaJobdeskController = TextEditingController(
      text: dataAwal?['nama_jobdesk'] ?? '',
    );
    final tugasController = TextEditingController(
      text: dataAwal?['tugas_utama'] ?? '',
    );
    final namaKaryawanController = TextEditingController(
      text: dataAwal?['nama_karyawan'] ?? '',
    );

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                  isEdit ? "Edit Jobdesk" : "Tambah Jobdesk Baru",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00ABB6),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: idController,
                  readOnly: isEdit,
                  decoration: const InputDecoration(
                    labelText: "ID Jobdesk",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: namaJobdeskController,
                  decoration: const InputDecoration(
                    labelText: "Nama Jobdesk",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: tugasController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Tugas Utama",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: namaKaryawanController,
                  decoration: const InputDecoration(
                    labelText: "Nama Karyawan",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(isEdit ? Icons.save : Icons.add),
                  label: Text(isEdit ? "Simpan Perubahan" : "Tambah"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF00ABB6),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newData = {
                        "id": idController.text,
                        "nama_jobdesk": namaJobdeskController.text,
                        "tugas_utama": tugasController.text,
                        "nama_karyawan": namaKaryawanController.text.isEmpty
                            ? "-"
                            : namaKaryawanController.text,
                      };
                      Navigator.pop(context);
                      if (isEdit && editIndex != null) {
                        editJobdesk(editIndex, newData);
                      } else {
                        tambahJobdesk(newData);
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

  // === Form penugasan ===
  void showFormTambahPenugasan() {
    final formKey = GlobalKey<FormState>();
    String? selectedJobdesk;
    final namaKaryawanController = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                const Text(
                  "Tambah Penugasan Karyawan",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00ABB6),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedJobdesk,
                  decoration: const InputDecoration(
                    labelText: "Pilih Jobdesk",
                    border: OutlineInputBorder(),
                  ),
                  items: dataJobdesk
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e["nama_jobdesk"],
                          child: Text(e["nama_jobdesk"] ?? ""),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => selectedJobdesk = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Wajib dipilih" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: namaKaryawanController,
                  decoration: const InputDecoration(
                    labelText: "Nama Karyawan",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text("Tambahkan"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF00ABB6),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final index = dataJobdesk.indexWhere(
                        (e) => e["nama_jobdesk"] == selectedJobdesk,
                      );
                      if (index != -1) {
                        setState(() {
                          dataJobdesk[index]["nama_karyawan"] =
                              namaKaryawanController.text;
                        });
                      }
                      Navigator.pop(context);
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

  void showPilihanTambah() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xfff3f3f8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Pilih Jenis Tambah",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.assignment_add,
                color: Colors.blueAccent,
              ),
              title: const Text("Tambah Jobdesk Baru"),
              onTap: () {
                Navigator.pop(context);
                showFormJobdesk();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1, color: Colors.green),
              title: const Text("Tambah Penugasan Karyawan"),
              onTap: () {
                Navigator.pop(context);
                showFormTambahPenugasan();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text(
          "Data Jobdesk",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF00ABB6),
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: showPilihanTambah,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Tambah", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cari Data Jobdesk",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00ABB6),
              ),
            ),
            const SizedBox(height: 8),
            _searchBox(),
            const SizedBox(height: 16),
            const Text(
              "Data Jobdesk",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00ABB6),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: dataJobdesk.isEmpty
                  ? const Center(child: Text("Belum ada data jobdesk"))
                  : ListView.builder(
                      itemCount: dataJobdesk.length,
                      itemBuilder: (context, index) {
                        final j = dataJobdesk[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: const Color(
                                    0xFF00ABB6,
                                  ).withOpacity(0.1),
                                  child: const Icon(
                                    Icons.assignment,
                                    color: Color(0xFF00ABB6),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        j["nama_jobdesk"] ?? "",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Tugas: ${j['tugas_utama']}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person,
                                            size: 14,
                                            color: Colors.black54,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            j["nama_karyawan"] ?? "-",
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == "edit") {
                                      showFormJobdesk(
                                        dataAwal: j,
                                        editIndex: index,
                                      );
                                    } else if (value == "hapus") {
                                      hapusJobdesk(index);
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
      // 🔵 BOTTOM NAVIGATION
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.fingerprint),
                color: currentIndex == 0 ? Colors.teal : Colors.black54,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DataAbsensiPage(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.groups),
                color: currentIndex == 1 ? Colors.teal : Colors.black54,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DataKaryawanPage(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 30),
              IconButton(
                icon: const Icon(Icons.assignment),
                color: currentIndex == 3 ? Colors.teal : Colors.black54,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JobdeskPage(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person),
                color: currentIndex == 4 ? Colors.teal : Colors.black54,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // 🔵 HOME FLOATING BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.home, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
