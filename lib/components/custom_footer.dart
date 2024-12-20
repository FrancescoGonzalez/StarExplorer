import 'package:flutter/material.dart';

class CustomFooter extends StatelessWidget implements PreferredSizeWidget {

  final String direction;
  final String degrees;

  const CustomFooter(this.direction, this.degrees);


  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color.fromARGB(255, 5, 14, 57),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Facing $direction ($degrees)",
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}