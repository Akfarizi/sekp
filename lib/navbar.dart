import 'package:flutter/material.dart';
import 'absensi.dart';
import 'data_karyawan.dart';
import 'jobdesk_page.dart';
import 'profile_page.dart';

class GlobalNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const GlobalNavbar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // kiri
            IconButton(
              icon: const Icon(Icons.fingerprint),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DataKaryawanPage(),
                  ),
                );
              },
            ),

            const SizedBox(width: 30), // jarak tengah
            // kanan
            IconButton(
              icon: const Icon(Icons.assignment),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JobdeskPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
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
    );
  }
}
