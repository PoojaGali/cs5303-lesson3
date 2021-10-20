import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/photomemo.dart';

class SharedWithScreen extends StatefulWidget {
  static const routeName = '/sharedWithScreen';
  final List<PhotoMemo> photoMemoList; // shared with me
  final User user;

  SharedWithScreen({required this.photoMemoList, required this.user});
  @override
  State<StatefulWidget> createState() {
    return _SharedWithState();
  }
}

class _SharedWithState extends State<SharedWithScreen> {
  late _Controller con;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shared With me'),
      ),
      body: Text('Shared With. ${widget.photoMemoList.length}'),
    );
  }
}

class _Controller {
  late _SharedWithState state;
  _Controller(this.state);
}
