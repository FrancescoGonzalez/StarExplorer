import 'package:flutter/material.dart';
import 'package:star_explorer/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Star Explorer'),
      toolbarHeight: 30,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: nightSkyColor,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}