import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/controller/googleML_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/profile.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class MyProfileScreen extends StatefulWidget {
  static const routeName = './myprofileScreen';
  late User user;
  late Profile profile;

  MyProfileScreen({required this.user, required this.profile});

  @override
  State<StatefulWidget> createState() {
    return _MyProfileState();
  }
}

class _MyProfileState extends State<MyProfileScreen> {
  late _Controller con;
  late User user;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late String progressMessage;
  bool editMode = false;
  late Profile profile;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    profile = args[Constant.ARG_ONE_PROFILE];
    user = args[ARGS.USER];

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
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
          child: Card(
            elevation: 7.0,
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * .4,
                    child: con.photo == null
                        ? WebImage(
                            url: con.profile.photoURL,
                            context: context,
                          )
                        : Image.file(con.photo!),
                  ),
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
                Container(
                  color: Colors.pinkAccent,
                  child: Row(
                    children: [
                      Text(
                        'E-mail',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${profile.email}',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                SizedBox(
                  height: 1.0,
                ),
                Container(
                  color: Colors.pinkAccent,
                  child: Row(
                    children: [
                      Text(
                        'Name',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  enabled: editMode,
                  style: Theme.of(context).textTheme.subtitle1,
                  decoration: InputDecoration(
                    hintText: 'Enter Name',
                  ),
                  initialValue: con.profile.name,
                  autocorrect: true,
                  onSaved: con.saveName,
                ),
                SizedBox(
                  height: 1.0,
                ),
                Container(
                  color: Colors.pinkAccent,
                  child: Row(
                    children: [
                      Text(
                        'Bio',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  enabled: editMode,
                  style: Theme.of(context).textTheme.subtitle1,
                  decoration: InputDecoration(
                    hintText: 'Enter bio',
                  ),
                  initialValue: con.profile.description,
                  autocorrect: true,
                  onSaved: con.saveDescription,
                ),
                Container(
                  color: Colors.pinkAccent,
                  child: Row(
                    children: [
                      Text(
                        'Joined On',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${profile.signUpDate}',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _MyProfileState state;
  File? photo;
  late Profile profile;
  _Controller(this.state) {
    profile = Profile.clone(state.widget.profile);
  }

  void update() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();
    MyDialog.circularProgressStart(state.context);
    try {
      Map<String, dynamic> updateInfo = {};
      if (photo != null) {
        Map photoInfo = await CloudStorageController.uploadProfilePic(
          photo: photo!,
          // filename: profile.photoFilename,
          uid: state.widget.user.uid,
          listener: (int progress) {
            state.render(() {
              state.progressMessage =
                  (progress == 100 ? null : 'Uploading: $progress %')!;
            });
          },
        );

        profile.photoURL = photoInfo[ARGS.DownloadURL];
        updateInfo[Profile.PHOTO_URL] = profile.photoURL;
      }
      //update Firestore doc
      if (profile.name != state.widget.profile.name)
        updateInfo[Profile.NAME] = profile.name;
      if (profile.description != state.widget.profile.description)
        updateInfo[Profile.DESCRIPTION] = profile.description;

      if (updateInfo.isNotEmpty) {
        //changes have been made
        await FirestoreController.updateProfile(
          docId: profile.docId!,
          updateInfo: updateInfo,
        );
        state.widget.profile.assign(profile);
      }
      MyDialog.circularProgressStop(state.context);
      state.render(() => state.editMode = false);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      if (Constant.DEV) print('========= update profile error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Update Profile error. $e',
      );
    }
  }

  void edit() {
    state.render(() => state.editMode = true);
  }

  void saveName(String? value) {
    if (value != null) profile.name = value;
  }

  void saveDescription(String? value) {
    if (value != null) profile.description = value;
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
}
