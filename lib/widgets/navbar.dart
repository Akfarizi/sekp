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
            /// DATA KARYAWAN (index 1)
            IconButton(
              icon: Icon(
                Icons.groups,
                color: currentIndex == 1 ? active : inactive,
              ),
              onPressed: () => onTap(1),
            ),

            /// JOBDESK (index 2)
            IconButton(
              icon: Icon(
                Icons.assignment,
                color: currentIndex == 2 ? active : inactive,
              ),
              onPressed: () => onTap(2),
            ),

            /// SPACE FAB
            const SizedBox(width: 40),

            /// PENGGAJIAN (index 3)
            IconButton(
              icon: Icon(
                Icons.payments,
                color: currentIndex == 3 ? active : inactive,
              ),
              onPressed: () => onTap(3),
            ),

            /// PROFILE (index 4)
            IconButton(
              icon: Icon(
                Icons.person,
                color: currentIndex == 4 ? active : inactive,
              ),
              onPressed: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}
