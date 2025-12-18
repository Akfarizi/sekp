import 'package:flutter/material.dart';
import 'home.dart';
import 'absensi.dart';
import 'data_karyawan.dart';
import 'jobdesk_page.dart';
import 'profile_page.dart';
import '../widgets/navbar.dart';
import '../widgets/floating_home.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int index = 0;

  final pages = const [
    HomePage(),
    DataKaryawanPage(),
    JobdeskPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),

      bottomNavigationBar: GlobalNavbar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00ABB6),
        child: const Icon(Icons.home),
        onPressed: () => setState(() => index = 0), // ⬅️ HOME TANPA PUSH
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
