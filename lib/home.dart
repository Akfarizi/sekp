import 'package:flutter/material.dart';
import 'navbar.dart';
import 'floating_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    final pages = [
      Center(child: Text("Halaman 1 (Left 1)", style: TextStyle(fontSize: 25))),
      Center(child: Text("Halaman 2 (Left 2)", style: TextStyle(fontSize: 25))),

      // =============================
      // HOME PAGE DENGAN CARD
      // =============================
      SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // STATUS BULAT DI POJOK KANAN
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green, // ganti red jika nonaktif
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SizedBox(height: 10),

            // CARD STATISTIK KINERJA BULAN INI
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      "Statistik Kinerja Bulan Ini",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "95%",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Kehadiran"),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "87%",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Tugas Selesai"),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "3x",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Terlambat"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // CARD INFORMASI KARYAWAN (POSISI DI TENGAH)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Informasi Karyawan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Jam Kerja", style: TextStyle(fontSize: 16)),
                        Text(
                          "168 Jam",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tugas Bulan Ini", style: TextStyle(fontSize: 16)),
                        Text(
                          "22 Tugas",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Project Aktif", style: TextStyle(fontSize: 16)),
                        Text(
                          "3 Project",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // CARD PEKERJAAN HARI INI
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pekerjaan Hari Ini",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),

                    Text("• Menyusun laporan harian"),
                    Text("• Meeting Project 'Sistem Absensi' pukul 14:00"),
                    Text("• Update fitur jobdesk karyawan"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      Center(
        child: Text("Halaman 4 (Right 1)", style: TextStyle(fontSize: 25)),
      ),
      Center(
        child: Text("Halaman 5 (Right 2)", style: TextStyle(fontSize: 25)),
      ),
    ];

    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: GlobalNavbar(
        currentIndex: currentIndex,
        onTabSelected: (index) => setState(() => currentIndex = index),
      ),

      floatingActionButton: FloatingHomeButton(
        onPressed: () => setState(() => currentIndex = 2),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
