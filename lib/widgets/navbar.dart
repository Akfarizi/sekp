import 'package:flutter/material.dart';

class GlobalNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlobalNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color active = Color(0xFF00ABB6);
  static const Color inactive = Colors.grey;

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
            /// ABSENSI
            IconButton(
              icon: Icon(
                Icons.fingerprint,
                color: currentIndex == 0 ? active : inactive,
              ),
              onPressed: () => onTap(0),
            ),

            /// DATA KARYAWAN
            IconButton(
              icon: Icon(
                Icons.groups,
                color: currentIndex == 1 ? active : inactive,
              ),
              onPressed: () => onTap(1),
            ),

            /// SPACE FAB
            const SizedBox(width: 40),

            /// JOBDESK
            IconButton(
              icon: Icon(
                Icons.assignment,
                color: currentIndex == 2 ? active : inactive,
              ),
              onPressed: () => onTap(2),
            ),

            /// PROFILE
            IconButton(
              icon: Icon(
                Icons.person,
                color: currentIndex == 3 ? active : inactive,
              ),
              onPressed: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}
