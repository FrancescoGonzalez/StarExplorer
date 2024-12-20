import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Star Explorer'),
      titleTextStyle: TextStyle(
        color: const Color.fromARGB(225, 22, 106, 151),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Color.fromARGB(255, 5, 14, 57),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}