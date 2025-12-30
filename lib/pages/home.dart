import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'etos/etos_page.dart';
import '../export/exprt_page.dart';
import 'dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  String roleUser = "Karyawan";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  // ================= LOAD ROLE =================
  Future<void> _loadRole() async {
    try {
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        roleUser = doc.data()?['role'] ?? "Karyawan";
      }
    } catch (_) {
      roleUser = "Karyawan";
    }

    if (mounted) setState(() => isLoading = false);
  }

  // ================= LOGOUT =================
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // ================= FORMAT TANGGAL =================
  String _today() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _timeNow() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  // ================= ABSEN =================
  Future<void> _absen(String status) async {
    final today = _today();

    final cek = await firestore
        .collection('absensi')
        .where('uid', isEqualTo: user.uid)
        .where('tanggal', isEqualTo: today)
        .where('status', isEqualTo: status)
        .get();

    if (cek.docs.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sudah absen $status hari ini")));
      return;
    }

    if (status == "Keluar") {
      final masuk = await firestore
          .collection('absensi')
          .where('uid', isEqualTo: user.uid)
          .where('tanggal', isEqualTo: today)
          .where('status', isEqualTo: "Masuk")
          .get();

      if (masuk.docs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Belum absen masuk")));
        return;
      }
    }

    await firestore.collection('absensi').add({
      "uid": user.uid,
      "email": user.email ?? "-",
      "tanggal": today,
      "waktu": _timeNow(),
      "status": status,
      "createdAt": Timestamp.now(),
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          roleUser == "Admin" ? "Dashboard Admin" : "Dashboard Karyawan",
        ),
        backgroundColor: const Color(0xFF00ABB6),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: roleUser == "Admin" ? _adminDashboard() : _karyawanDashboard(),
    );
  }

  // ================= DASHBOARD KARYAWAN =================
  Widget _karyawanDashboard() {
    return Column(
      children: [
        const SizedBox(height: 12),

        // BUTTON ABSEN
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _absen("Masuk"),
              icon: const Icon(Icons.login),
              label: const Text("Masuk"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(140, 48),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _absen("Keluar"),
              icon: const Icon(Icons.logout),
              label: const Text("Keluar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(140, 48),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // MENU TAMBAHAN
        Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DashboardPage()),
                  );
                },
                child: Card(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.analytics, size: 32, color: Color(0xFF00ABB6)),
                        SizedBox(height: 8),
                        Text("Analitik Kinerja", textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EtosPage(roleUser: roleUser),
                    ),
                  );
                },
                child: Card(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.star, size: 32, color: Color(0xFF00ABB6)),
                        SizedBox(height: 8),
                        Text("Etos Kerja", textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(),

        // RIWAYAT ABSEN
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('absensi')
                .where('uid', isEqualTo: user.uid)
                .snapshots(),

            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Belum ada data absensi"));
              }

              return ListView(
                padding: const EdgeInsets.all(12),
                children: snapshot.data!.docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        d['status'] == "Masuk" ? Icons.login : Icons.logout,
                        color: d['status'] == "Masuk"
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(d['email']),
                      subtitle: Text("${d['tanggal']} • ${d['waktu']}"),
                      trailing: Text(d['status']),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= DASHBOARD ADMIN =================
  Widget _adminDashboard() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DashboardPage()),
                  );
                },
                child: Card(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.analytics, size: 32, color: Color(0xFF00ABB6)),
                        SizedBox(height: 8),
                        Text("Analitik Kinerja", textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EtosPage(roleUser: roleUser),
                    ),
                  );
                },
                child: Card(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.star, size: 32, color: Color(0xFF00ABB6)),
                        SizedBox(height: 8),
                        Text("Etos Kerja", textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
              _menu(Icons.picture_as_pdf, "Export PDF", '/export-pdf'),
              _menu(Icons.table_chart, "Export Excel", '/export-excel'),
            ],
          ),
        ),

        const Divider(),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('absensi').snapshots(),

            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("Belum ada data absensi karyawan"),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(12),
                children: snapshot.data!.docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        d['status'] == "Masuk" ? Icons.login : Icons.logout,
                        color: d['status'] == "Masuk"
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(d['email']),
                      subtitle: Text("${d['tanggal']} • ${d['waktu']}"),
                      trailing: Text(d['status']),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _menu(IconData icon, String title, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: const Color(0xFF00ABB6)),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
