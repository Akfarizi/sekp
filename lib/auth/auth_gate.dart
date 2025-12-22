import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/root_page.dart';
import '../auth/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ BELUM LOGIN
        if (!authSnap.hasData) {
          return const LoginPage();
        }

        final user = authSnap.data!;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // ❌ DATA USER TIDAK ADA
            if (!userSnap.hasData || !userSnap.data!.exists) {
              FirebaseAuth.instance.signOut();
              return const LoginPage();
            }

            final data =
                userSnap.data!.data() as Map<String, dynamic>;

            // 🚫 NONAKTIF
            if (data['status'] == 'Nonaktif') {
              FirebaseAuth.instance.signOut();
              return const Scaffold(
                body: Center(
                  child: Text(
                    "Akun Anda telah dinonaktifkan",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }

            // ✅ AKTIF
            return const RootPage();
          },
        );
      },
    );
  }
}
