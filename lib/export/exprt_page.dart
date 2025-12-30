import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  // 🔐 CONVERTER AMAN
  String s(dynamic v) => v == null ? '' : v.toString();

  Future<void> _exportAll(BuildContext context) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final excel = Excel.createExcel();

      // ================= ABSENSI =================
      final absensiSheet = excel['Absensi'];
      absensiSheet.appendRow(['Email', 'Tanggal', 'Waktu', 'Status']);

      final absensiSnap = await firestore.collection('absensi').get();
      for (var doc in absensiSnap.docs) {
        final d = doc.data();
        absensiSheet.appendRow([
          s(d['email']),
          s(d['tanggal']),
          s(d['waktu']),
          s(d['status']),
        ]);
      }

      // ================= ETOS =================
      final etosSheet = excel['Etos Kerja'];
      etosSheet.appendRow([
        'Nama',
        'Disiplin',
        'Inisiatif',
        'Kerja Sama',
        'Tanggung Jawab',
        'Rata-rata',
        'Periode',
        'Catatan',
      ]);

      final etosSnap = await firestore.collection('etos_kerja').get();
      for (var doc in etosSnap.docs) {
        final d = doc.data();

        final avg = (
          (d['disiplin'] ?? 0) +
          (d['inisiatif'] ?? 0) +
          (d['kerjasama'] ?? 0) +
          (d['tanggungjawab'] ?? 0)
        ) / 4;

        etosSheet.appendRow([
          s(d['nama']),
          s(d['disiplin']),
          s(d['inisiatif']),
          s(d['kerjasama']),
          s(d['tanggungjawab']),
          avg.toStringAsFixed(2),
          s(d['periode']),
          s(d['catatan']),
        ]);
      }

      // ================= JOBDESK =================
      final jobdeskSheet = excel['Jobdesk'];
      jobdeskSheet.appendRow(['Judul', 'Deskripsi', 'Deadline', 'Status']);

      final jobdeskSnap = await firestore.collection('jobdesk').get();
      for (var doc in jobdeskSnap.docs) {
        final d = doc.data();
        jobdeskSheet.appendRow([
          s(d['judul']),
          s(d['deskripsi']),
          s(d['deadline']),
          s(d['status']),
        ]);
      }

      // ================= PENGGAJIAN =================
      final gajiSheet = excel['Penggajian'];
      gajiSheet.appendRow(['Nama', 'Tanggal', 'Gaji Pokok']);

      final gajiSnap = await firestore.collection('penggajian').get();
      for (var doc in gajiSnap.docs) {
        final d = doc.data();
        gajiSheet.appendRow([
          s(d['nama']),
          s(d['tanggal']),
          s(d['gaji_pokok']), // STRING AMAN
        ]);
      }

      // ================= USERS =================
      final userSheet = excel['Karyawan'];
      userSheet.appendRow(['Nama', 'Email', 'Role', 'Status']);

      final usersSnap = await firestore.collection('users').get();
      for (var doc in usersSnap.docs) {
        final d = doc.data();
        userSheet.appendRow([
          s(d['nama']),
          s(d['email']),
          s(d['role']),
          s(d['status']),
        ]);
      }

      // ================= SAVE =================
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/laporan_sistem.xlsx');
      file.writeAsBytesSync(excel.encode()!);

      await OpenFile.open(file.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Export berhasil")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal export: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Export Laporan Excel"),
        backgroundColor: const Color(0xFF00ABB6),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text("Export Semua Laporan"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(240, 50),
          ),
          onPressed: () => _exportAll(context),
        ),
      ),
    );
  }
}
