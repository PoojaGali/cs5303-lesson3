//import 'dart:html';

import 'dart:io';
//import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/controller/googleML_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photocomment.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class DetailedViewScreen extends StatefulWidget {
  static const routeName = '/detailedViewScreen';

  late User user;
  late PhotoMemo photoMemo;
  final List<PhotoComment> photoCommentList;

  DetailedViewScreen({
    required this.user,
    required this.photoMemo,
    required this.photoCommentList,
  });

  @override
  State<StatefulWidget> createState() {
    return _DetailedViewState();
  }
}

class _DetailedViewState extends State<DetailedViewScreen> {
  late _Controller con;
  late User user;
  late PhotoMemo onePhotoMemoOriginal;
  late PhotoMemo onePhotoMemoTemp;
  // late List<PhotoComment> photoCommentList;
  bool editMode = false;
  String progMessage = '';

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? progressMessage;
  String? dropdownValue;

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
    List<PhotoComment> photoCommentList = args[Constant.ARG_PHOTOCOMMENTLIST];
    onePhotoMemoOriginal = args[ARGS.OnePhotoMemo];
    onePhotoMemoTemp = PhotoMemo.clone(onePhotoMemoOriginal);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detailed View',
        ),
        actions: [
          editMode
              ? IconButton(onPressed: con.update, icon: Icon(Icons.check))
              : IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: con.edit,
                )
        ],
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
                    child: con.photo == null
                        ? WebImage(
                            url: con.tempMemo.photoURL,
                            context: context,
                          )
                        : Image.file(con.photo!),
                  ),
                  editMode
                      ? Positioned(
                          right: 0.0,
                          bottom: 0.0,
                          child: Container(
                            color: Colors.blue,
                            child: PopupMenuButton(
                              onSelected: con.getPhoto,
                              itemBuilder: (context) => [
                                for (var source in PhotoSource.values)
                                  PopupMenuItem<PhotoSource>(
                                    value: source,
                                    child: Text(
                                        '${source.toString().split('.')[1]}'),
                                  )
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 1.0,
                        ),
                ],
              ),
              progressMessage == null
                  ? SizedBox(
                      height: 1.0,
                    )
                  : Text(
                      progressMessage!,
                      style: Theme.of(context).textTheme.headline6,
                    ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.headline6,
                decoration: InputDecoration(
                  hintText: 'Enter Title',
                ),
                initialValue: con.tempMemo.title,
                autocorrect: true,
                validator: PhotoMemo.validateTitle,
                onSaved: con.saveTitle,
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: InputDecoration(
                  hintText: 'Enter Memo',
                ),
                initialValue: con.tempMemo.memo,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                autocorrect: true,
                validator: PhotoMemo.validateMemo,
                onSaved: con.saveMemo,
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: InputDecoration(
                  hintText: 'Enter sharedWith email list',
                ),
                initialValue: con.tempMemo.sharedWith.join(','),
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                autocorrect: false,
                validator: PhotoMemo.validateSharedWith,
                onSaved: con.saveSharedWith,
              ),
              DropdownButton<String>(
                value: dropdownValue,
                hint: Text('ML'),
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: <String>[
                  'Image',
                  'Text',
                  'Both',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              Constant.DEV
                  ? Text('Image Labels by ML\n${con.tempMemo.outputlabels}')
                  : SizedBox(
                      height: 1.0,
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
                  hintText: 'Write a comment...',
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
  late _DetailedViewState state;
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

  void getPhoto(PhotoSource source) async {
    try {
      var imageSource = source == PhotoSource.CAMERA
          ? ImageSource.camera
          : ImageSource.gallery;
      XFile? image = await ImagePicker().pickImage(source: imageSource);
      if (image == null) return; //canceled by camera or gallery.
      state.render(() => photo = File(image.path));
    } catch (e) {
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Failed to get a picture: $e',
      );
    }
  }

  void update() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();
    MyDialog.circularProgressStart(state.context);
    try {
      Map<String, dynamic> updateInfo = {};
      if (photo != null) {
        Map photoInfo = await CloudStorageController.uploadPhotoFile(
          photo: photo!,
          uid: state.widget.user.uid,
          filename: tempMemo.photoFilename,
          listener: (int progress) {
            state.render(() {
              state.progressMessage =
                  progress == 100 ? null : 'Uploading: $progress %';
            });
          },
        );
        //generate image lables by Ml
        if (state.dropdownValue == 'Image') {
          List<String> recognitions =
              await GoogleMLController.getImageLabels(photo: photo!);
          tempMemo.imageLabels = recognitions;
          tempMemo.outputlabels = tempMemo.imageLabels;
          updateInfo[PhotoMemo.IMAGE_LABELS] = tempMemo.imageLabels;
        }
        if (state.dropdownValue == 'Text') {
          List<String> recognitions =
              await GoogleMLController.readText(photo: photo!);
          tempMemo.textLabels = recognitions;
          tempMemo.outputlabels = tempMemo.textLabels;
          updateInfo[PhotoMemo.TEXT_LABELS] = tempMemo.textLabels;
        }
        tempMemo.photoURL = photoInfo[ARGS.DownloadURL];
        updateInfo[PhotoMemo.PHOTO_URL] = tempMemo.photoURL;
        // updateInfo[PhotoMemo.IMAGE_LABELS] = tempMemo.imageLabels;
      }
      if (photo == null) {
        if (state.dropdownValue == 'Image') {
          tempMemo.outputlabels = state.widget.photoMemo.imageLabels;
        }
        if (state.dropdownValue == 'Text') {
          tempMemo.outputlabels = state.widget.photoMemo.textLabels;
        }
        updateInfo[PhotoMemo.OUTPUT_LABELS] = tempMemo.outputlabels;
      }
      //update Firestore doc
      if (tempMemo.title != state.widget.photoMemo.title)
        updateInfo[PhotoMemo.TITLE] = tempMemo.title;
      if (tempMemo.memo != state.widget.photoMemo.memo)
        updateInfo[PhotoMemo.MEMO] = tempMemo.memo;
      if (!listEquals(tempMemo.sharedWith, state.widget.photoMemo.sharedWith))
        updateInfo[PhotoMemo.SHARED_WITH] = tempMemo.sharedWith;

      if (updateInfo.isNotEmpty) {
        //changes have been made
        tempMemo.timestamp = DateTime.now();
        updateInfo[PhotoMemo.TIMESTAMP] = tempMemo.timestamp;
        await FirestoreController.updatePhotoMemo(
          docId: tempMemo.docId!,
          updateInfo: updateInfo,
        );
        state.widget.photoMemo.assign(tempMemo);
      }
      MyDialog.circularProgressStop(state.context);
      state.render(() => state.editMode = false);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      if (Constant.DEV) print('========= update photomemo error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Update Photomemo error. $e',
      );
    }
    // state.render(() => state.editMode = false);
  }

  void edit() {
    state.render(() => state.editMode = true);
  }

  void saveTitle(String? value) {
    if (value != null) tempMemo.title = value;
  }

  void saveMemo(String? value) {
    if (value != null) tempMemo.memo = value;
  }

  void saveSharedWith(String? value) {
    if (value != null && value.trim().length != 0) {
      tempMemo.sharedWith.clear();
      tempMemo.sharedWith.addAll(value.trim().split(RegExp('{, |}+')));
    }
  }
}
