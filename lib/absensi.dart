import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import 'data_karyawan.dart';
import 'jobdesk_page.dart';
import 'profile_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sistem Etos Kerja - Absensi',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00ABB6)),
      useMaterial3: true,
    ),
    home: const DataAbsensiPage(),
  );
}

class DataAbsensiPage extends StatefulWidget {
  const DataAbsensiPage({super.key});

  @override
  State<DataAbsensiPage> createState() => _DataAbsensiPageState();
}

class _DataAbsensiPageState extends State<DataAbsensiPage> {
  int currentIndex = 0;

  List<Map<String, String>> dataAbsensi = [
    {
      "id": "001",
      "nama": "John Doe",
      "email": "john@example.com",
      "tanggal": "2025-10-28",
      "waktu": "07:58",
      "status": "Masuk",
    },
    {
      "id": "002",
      "nama": "Jane Smith",
      "email": "jane@example.com",
      "tanggal": "2025-10-28",
      "waktu": "16:45",
      "status": "Keluar",
    },
  ];

  final TextEditingController searchController = TextEditingController();
  List<Map<String, String>> filteredAbsensi = [];

  @override
  void initState() {
    super.initState();
    filteredAbsensi = List.from(dataAbsensi);

    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      setState(() {
        filteredAbsensi = dataAbsensi
            .where((a) => a["nama"]!.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  /// ─────────────────────────────────────────────────────────────
  /// 🔵 Tambah Data Absensi
  /// ─────────────────────────────────────────────────────────────
  void _tambahAbsensi(String status) {
    final now = DateTime.now();
    final tanggal = DateFormat('yyyy-MM-dd').format(now);
    final waktu = DateFormat('HH:mm').format(now);

    final dataBaru = {
      "id": (dataAbsensi.length + 1).toString().padLeft(3, '0'),
      "nama": "Karyawan ${dataAbsensi.length + 1}",
      "email": "karyawan${dataAbsensi.length + 1}@example.com",
      "tanggal": tanggal,
      "waktu": waktu,
      "status": status,
    };

    setState(() {
      dataAbsensi.add(dataBaru);
      filteredAbsensi = List.from(dataAbsensi);
    });
  }

  Widget _searchBox() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
      ],
    ),
    child: TextField(
      controller: searchController,
      decoration: const InputDecoration(
        hintText: "Cari nama karyawan...",
        prefixIcon: Icon(Icons.search, color: Colors.black),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    ),
  );

  Widget _statusBadge(String status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: status == "Masuk" ? Colors.green[100] : Colors.red[100],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: status == "Masuk" ? Colors.green[800] : Colors.red[800],
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
  );

  /// ─────────────────────────────────────────────────────────────
  /// BUILD UI UTAMA
  /// ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfff5f7fa),

    // 🔵 APPBAR
    appBar: AppBar(
      title: const Text(
        "Absensi",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: const Color(0xFF00ABB6),
      foregroundColor: Colors.white,
    ),

    // 🔵 BODY
    body: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cari Data Absensi",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00ABB6),
            ),
          ),
          const SizedBox(height: 8),

          /// =================================================================
          /// 🔵 SEARCH BAR + TOMBOL MASUK/KELUAR
          /// =================================================================
          Row(
            children: [
              Expanded(child: _searchBox()),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _tambahAbsensi("Masuk"),
                icon: const Icon(Icons.login),
                label: const Text("Masuk"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(40, 50),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _tambahAbsensi("Keluar"),
                icon: const Icon(Icons.logout),
                label: const Text("Keluar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(40, 50),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text(
            "Data Absensi",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00ABB6),
            ),
          ),
          const SizedBox(height: 4),

          /// =================================================================
          /// 🔵 LIST ABSENSI
          /// =================================================================
          Expanded(
            child: filteredAbsensi.isEmpty
                ? const Center(child: Text("Belum ada data absensi"))
                : ListView.builder(
                    itemCount: filteredAbsensi.length,
                    itemBuilder: (_, i) {
                      final a = filteredAbsensi[i];
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
                              a["status"] == "Masuk"
                                  ? Icons.login
                                  : Icons.logout,
                              color: a["status"] == "Masuk"
                                  ? Colors.green
                                  : Colors.redAccent,
                            ),
                          ),
                          title: Text(
                            a["nama"]!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a["email"]!),
                              const SizedBox(height: 4),
                              Text("Tanggal: ${a["tanggal"]!}"),
                              Text("Waktu: ${a["waktu"]!}"),
                            ],
                          ),
                          trailing: _statusBadge(a["status"]!),
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
                  MaterialPageRoute(builder: (context) => const DataAbsensiPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.groups),
              color: currentIndex == 1 ? Colors.teal : Colors.black54,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DataKaryawanPage()),
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
                  MaterialPageRoute(builder: (context) => const JobdeskPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              color: currentIndex == 4 ? Colors.teal : Colors.black54,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
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
