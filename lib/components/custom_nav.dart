import 'package:flutter/material.dart';

class CustomNav extends StatelessWidget implements PreferredSizeWidget {
  final String objectName;
  final String altDSO;
  final String azDSO;
  final ElevatedButton elevatedButton;
  final TextEditingController controller;

  const CustomNav(this.objectName, this.altDSO, this.azDSO, this.controller,
      this.elevatedButton);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 5, 14, 57),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 120,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: "Insert DSO",
                        labelStyle: TextStyle(
                            color: const Color.fromARGB(255, 223, 222, 255)),
                      ),
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  elevatedButton,
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$objectName \nAz: $azDSO \nAlt: $altDSO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
