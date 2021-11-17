import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photocomment.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class DetailSharedScreen extends StatefulWidget {
  static const routeName = '/detailSharedScreen';

  late PhotoMemo photoMemo;

  final List<PhotoComment> photoCommentList;
  final User user;

  DetailSharedScreen({
    required this.user,
    required this.photoMemo,
    required this.photoCommentList,
  });

  @override
  State<StatefulWidget> createState() {
    return _DetailSharedState();
  }
}

class _DetailSharedState extends State<DetailSharedScreen> {
  late _Controller con;
  List<PhotoMemo> photoMemoList = [];
  List<PhotoComment> photoCommentList = [];
  String progMessage = '';
  late PhotoMemo photoMemo;

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
    // photoMemoList = args[ARGS.PhotoMemoList];
    photoMemo = args[ARGS.OnePhotoMemo];
    List<PhotoComment> photoCommentList = args[Constant.ARG_PHOTOCOMMENTLIST];

    return Scaffold(
      appBar: AppBar(
        title: Text('Shared With ${widget.user.email}'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: WebImage(
                      url: con.tempMemo.photoURL,
                      context: context,
                    ),
                  ),
                  SizedBox(
                    height: 1.0,
                  ),
                ],
              ),
              Text(
                con.tempMemo.title,
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(con.tempMemo.memo),
              Text('Created by: ${con.tempMemo.createdBy}'),
              Text('Created at: ${con.tempMemo.timestamp}'),
              Text('Shared With: ${con.tempMemo.sharedWith}'),
              Text('Image Labels: ${con.tempMemo.imageLabels}'),
              Text('Text Labels: ${con.tempMemo.readText}'),
              SizedBox(
                height: 5.0,
              ),
              Container(
                color: Colors.blueAccent,
                child: Row(
                  children: [
                    Text(
                      'Comments',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              photoCommentList.length == 0
                  ? Text('No Comments Found',
                      style: Theme.of(context).textTheme.headline5)
                  : ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: photoCommentList.length,
                      itemBuilder: (BuildContext context, int index) =>
                          Container(
                        color: Colors.blue[50],
                        child: ListTile(
                          title: Text(photoCommentList[index].createdBy,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black,
                              )),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Created On: ${photoCommentList[index].timestamp}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                photoCommentList[index].content,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Write a Comment...',
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                onSaved: con.saveComment,
              ),
              ElevatedButton(
                onPressed: con.createComment,
                child: Text(
                  'Send',
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _DetailSharedState state;
  late List<PhotoComment> photoCommentList;
  late List<PhotoMemo> photoMemoList;

  late PhotoMemo tempMemo;
  File? photo;
  PhotoComment tempComment = PhotoComment();
  String memo = '';
  String originalPoster = '';
  String content = '';
  String createdBy = '';
  var timestamp;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  _Controller(this.state) {
    tempMemo = PhotoMemo.clone(state.widget.photoMemo);
  }

  void saveComment(String? value) {
    tempComment.content = value!;
  }

  void createComment() async {
    FormState? currentState = state.formKey.currentState;
    Map<String, dynamic> updateInfo = {};

    if (currentState == null || !currentState.validate()) return;
    currentState.save();
    MyDialog.circularProgressStart(state.context);

    try {
      state.render(() => state.progMessage = "Uploading Comment!");
      tempMemo.newComment = 'true';
      tempComment.timestamp = DateTime.now();
      tempComment.originalPoster = tempMemo.createdBy;
      tempComment.createdBy = state.user.email!;
      tempComment.memoId = tempMemo.docId.toString();

      String docId = await FirestoreController.addPhotoComment(tempComment);
      tempComment.docId = docId;
      updateInfo[PhotoMemo.NEW_COMMENT] = tempMemo.newComment;
      await FirestoreController.updatePhotoMemo(
        docId: tempMemo.docId!,
        updateInfo: updateInfo,
      );

      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context,
          title: 'Save PhotoComment error',
          content: '$e');
    }
  }
}
