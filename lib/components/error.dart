import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Error extends StatelessWidget implements PreferredSizeWidget {
  final String message;

  const Error(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      child: Center(
        child: Text(message),
      ),
    );
  }

  void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
