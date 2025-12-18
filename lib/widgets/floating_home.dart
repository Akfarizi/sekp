import 'package:flutter/material.dart';
import '../pages/home.dart';

class FloatingHomeButton extends StatelessWidget {
  const FloatingHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF00ABB6),
      elevation: 6,
      child: const Icon(Icons.home, size: 28),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (_) => false,
        );
      },
    );
  }
}
