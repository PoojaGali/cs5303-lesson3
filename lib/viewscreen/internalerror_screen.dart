import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InternalErrorScreen extends StatelessWidget {
  static const routeName = '/InternalErrorScreen';
  late final String message;
  InternalErrorScreen(this.message);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Internal Error'),
      ),
      body: Text(
        'Internal error has occured\nRelaunch the app\n$message',
        style: TextStyle(color: Colors.red, fontSize: 18.0),
      ),
    );
  }
}
