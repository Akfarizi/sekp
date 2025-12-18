import 'package:flutter/material.dart';
import '../widgets/navbar.dart';

class DataAbsensiPage extends StatelessWidget {
  const DataAbsensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Absensi"),
        backgroundColor: const Color(0xFF00ABB6),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: const Center(child: Text("DATA ABSENSI")),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

    );
  }
}
