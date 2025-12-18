import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  String error = "";

  Future<void> login() async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? "Login gagal";
      });
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> register() async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? "Register gagal";
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      body: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "LOGIN",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00ABB6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailC,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Email wajib diisi" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passC,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.length < 6 ? "Minimal 6 karakter" : null,
                  ),
                  const SizedBox(height: 12),
                  if (error.isNotEmpty)
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size(double.infinity, 48),
                      backgroundColor:
                          const Color(0xFF00ABB6),
                    ),
                    onPressed: loading
                        ? null
                        : () {
                            if (formKey.currentState!.validate()) {
                              login();
                            }
                          },
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : const Text("Login"),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                            if (formKey.currentState!.validate()) {
                              register();
                            }
                          },
                    child: const Text("Daftar Akun Baru"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
