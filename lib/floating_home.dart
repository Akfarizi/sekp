import 'package:flutter/material.dart';

class FloatingHomeButton extends StatelessWidget {
  final Function() onPressed;

  const FloatingHomeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.home),
      onPressed: onPressed,
    );
  }
}
