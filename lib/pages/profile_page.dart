import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final usersRef = FirebaseFirestore.instance.collection('users');

  final formKey = GlobalKey<FormState>();
  bool isEditing = false;
  bool loading = false;

  late TextEditingController namaC;
  late TextEditingController emailC;
  late TextEditingController teleponC;
  late TextEditingController roleC;
  late TextEditingController statusC;

  String? photoUrl;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController();
    emailC = TextEditingController(text: user.email);
    teleponC = TextEditingController();
    roleC = TextEditingController();
    statusC = TextEditingController();

    _loadUser();
  }

  Future<void> _loadUser() async {
    final doc = await usersRef.doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      namaC.text = data['nama'] ?? user.displayName ?? '';
      teleponC.text = data['telepon'] ?? '';
      roleC.text = data['role'] ?? 'Karyawan';
      statusC.text = data['status'] ?? 'Aktif';
      photoUrl = data['photoUrl'];
    } else {
      await usersRef.doc(user.uid).set({
        "nama": user.displayName ?? "",
        "telepon": "",
        "role": "Karyawan",
        "status": "Aktif",
        "photoUrl": null,
      });
    }

    setState(() {});
  }

  /// ================= FOTO CAMERA =================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  /// ================= UPLOAD FOTO =================
  Future<String?> _uploadImage() async {
    if (imageFile == null) return photoUrl;

    final ref = FirebaseStorage.instance
        .ref('profile/${user.uid}.jpg');

    await ref.putFile(imageFile!);
    return await ref.getDownloadURL();
  }

  /// ================= SIMPAN =================
  Future<void> _saveProfile() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final url = await _uploadImage();

    await usersRef.doc(user.uid).update({
      "nama": namaC.text,
      "telepon": teleponC.text,
      "photoUrl": url,
    });

    await user.updateDisplayName(namaC.text);

    setState(() {
      loading = false;
      isEditing = false;
      photoUrl = url;
      imageFile = null;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil berhasil diperbarui")),
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f7fb),
      appBar: AppBar(
        title: const Text("Profil Saya"),
        backgroundColor: const Color(0xFF00ABB6),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    /// FOTO
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundImage: imageFile != null
                              ? FileImage(imageFile!)
                              : (photoUrl != null
                                  ? NetworkImage(photoUrl!)
                                  : null) as ImageProvider?,
                          child: photoUrl == null && imageFile == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        if (isEditing)
                          InkWell(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF00ABB6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _field(namaC, "Nama", !isEditing),
                    _field(emailC, "Email", true),
                    _field(teleponC, "Telepon", !isEditing),
                    _field(roleC, "Role", true),
                    _field(statusC, "Status", true),

                    const SizedBox(height: 32),

                    isEditing
                        ? Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      setState(() => isEditing = false),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: const Text("Batal"),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF00ABB6)),
                                  child: const Text("Simpan"),
                                ),
                              ),
                            ],
                          )
                        : ElevatedButton.icon(
                            onPressed: () =>
                                setState(() => isEditing = true),
                            icon: const Icon(Icons.edit),
                            label: const Text("Edit Profil"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00ABB6),
                              minimumSize:
                                  const Size.fromHeight(48),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    bool readOnly,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: readOnly ? Colors.grey[200] : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (v) =>
            v == null || v.isEmpty ? "$label wajib diisi" : null,
      ),
    );
  }
}
