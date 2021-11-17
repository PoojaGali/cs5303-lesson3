import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photocomment.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/detailshared_screen.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class SharedWithScreen extends StatefulWidget {
  static const routeName = '/sharedWithScreen';

  final List<PhotoMemo> photoMemoList; //shared with me
  final User user;

  SharedWithScreen({required this.photoMemoList, required this.user});

  @override
  State<StatefulWidget> createState() {
    return _SharedWithState();
  }
}

class _SharedWithState extends State<SharedWithScreen> {
  late _Controller con;
  List<PhotoMemo> photoMemoList = [];
  List<PhotoComment> photoCommentList = [];
  String progMessage = '';

  late User user;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    user = args[ARGS.USER];
    photoMemoList = args[ARGS.PhotoMemoList];

    return Scaffold(
      appBar: AppBar(
        title: Text('Shared With ${widget.user.email}'),
      ),
      body: widget.photoMemoList.isEmpty
          ? Text(
              'No PhotoMemos shared with me',
              style: Theme.of(context).textTheme.headline6,
            )
          : ListView.builder(
              itemCount: photoMemoList.length,
              itemBuilder: (context, index) {
                return Container(
                  child: ListTile(
                    leading: WebImage(
                      url: photoMemoList[index].photoURL,
                      context: context,
                      height: MediaQuery.of(context).size.height * 0.35,
                    ),
                    title: Text(photoMemoList[index].title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          con.photoMemoList[index].memo.length >= 40
                              ? con.photoMemoList[index].memo.substring(
                                    0,
                                    40,
                                  ) +
                                  '...'
                              : con.photoMemoList[index].memo,
                        ),
                        Text(
                            'Created by:${con.photoMemoList[index].createdBy}'),
                        Text('Timestamp:${con.photoMemoList[index].timestamp}'),
                      ],
                    ),
                    onTap: () => con.onTap(index),
                  ),
                );
              },
            ),
    );
  }
}

class _Controller {
  late _SharedWithState state;
  late List<PhotoComment> photoCommentList;
  late List<PhotoMemo> photoMemoList;

  _Controller(this.state) {
    photoMemoList = state.widget.photoMemoList;
  }

  void onTap(int index) async {
    try {
      photoCommentList = await FirestoreController.getPhotoCommentList(
          originalPoster: state.photoMemoList[index].createdBy,
          memoId: state.photoMemoList[index].docId);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context,
          title: 'getPhotoCommentList error',
          content: '$e');
    }

    await Navigator.pushNamed(state.context, DetailSharedScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.OnePhotoMemo: photoMemoList[index],
          Constant.ARG_PHOTOCOMMENTLIST: photoCommentList,
        });
  }
}
