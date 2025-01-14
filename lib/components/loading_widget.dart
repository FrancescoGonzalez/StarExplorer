import 'package:flutter/material.dart';

import 'custom_app_bar.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        color: Color.fromARGB(255, 5, 14, 57),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Loading  ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'This may take a while',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
