//import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firebaseauth_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photocomment.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/model/profile.dart';
import 'package:lesson3/viewscreen/addnewphotomemo_screen.dart';
import 'package:lesson3/viewscreen/detailedview_screen.dart';
import 'package:lesson3/viewscreen/profile_screen.dart';
import 'package:lesson3/viewscreen/sharedwith_screen.dart';
import 'package:lesson3/viewscreen/user_profiles.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/userHomeScreen';
  final User user;
  late final String displayName;
  late final String email;
  List<PhotoMemo> photoMemoList;
  UserHomeScreen({required this.user, required this.photoMemoList}) {
    displayName = user.displayName ?? 'N/A';
    email = user.email ?? 'no email';
  }
  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  @override
  late _Controller con;
  List<PhotoMemo>? photoMemoList;
  late User user;
  int index = 0;
  GlobalKey<FormState> formKey = GlobalKey();
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
    return WillPopScope(
      onWillPop: () =>
          Future.value(false), //disable Android sysytem back button
      child: Scaffold(
          appBar: AppBar(
            //title: Text('User Home'),
            actions: [
              con.delIndexes.isEmpty
                  ? Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Search (empty for all)',
                              fillColor: Theme.of(context).backgroundColor,
                              filled: true,
                            ),
                            autocorrect: true,
                            onSaved: con.saveSearchKey,
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: con.cancelDelete,
                    ),
              con.delIndexes.isEmpty
                  ? IconButton(
                      onPressed: con.search,
                      icon: Icon(Icons.search),
                    )
                  : IconButton(
                      onPressed: con.delete,
                      icon: Icon(
                        Icons.delete,
                      )),
              IconButton(
                onPressed: con.viewAllProfiles,
                icon: Icon(
                  Icons.person,
                ),
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(widget.displayName),
                  accountEmail: Text(widget.email),
                ),
                ListTile(
                  leading: Icon(Icons.people),
                  title: Text('Shared with'),
                  onTap: con.sharedWith,
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Sign Out'),
                  onTap: con.signOut,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: con.addButton,
          ),
          body: con.photoMemoList.isEmpty
              ? Text(
                  'No Photo Memo Found',
                  style: Theme.of(context).textTheme.headline6,
                )
              : ListView.builder(
                  itemCount: con.photoMemoList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      color: con.delIndexes.contains(index)
                          ? Theme.of(context).highlightColor
                          : Theme.of(context).scaffoldBackgroundColor,
                      child: ListTile(
                        leading: WebImage(
                          url: con.photoMemoList[index].photoURL,
                          context: context,
                        ),
                        trailing: Icon(Icons.arrow_right),
                        title: Text(con.photoMemoList[index].title),
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
                            Text(
                                'SharedWith:${con.photoMemoList[index].sharedWith}'),
                            Text(
                                'Timestamp:${con.photoMemoList[index].timestamp}'),
                          ],
                        ),
                        onTap: () => con.onTap(index),
                        onLongPress: () => con.onLongPress(index),
                      ),
                    );
                  },
                )),
    );
  }
}

class _Controller {
  late _UserHomeState state;

  List<PhotoMemo> photoMemoList = [];
  List<PhotoComment> photoCommentList = [];
  List<Profile> profileList = [];

  String? searchKeyString;
  List<int> delIndexes = [];

  _Controller(this.state);

  void viewMyProfile(User user) async {
    List<Profile> myProfile =
        await FirestoreController.getOneProfile(user.email!);

    Navigator.pushNamed(
      state.context,
      ProfileScreen.routeName,
      arguments: {
        Constant.ARG_ONE_PROFILE: myProfile[1],
      },
    );
    state.render(() {});
  }

  void sharedWith() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FirestoreController.getPhotoMemoListSharedWith(
              email: state.widget.email);
      await Navigator.pushNamed(state.context, SharedWithScreen.routeName,
          arguments: {
            ARGS.PhotoMemoList: photoMemoList,
            ARGS.USER: state.widget.user,
            Constant.ARG_PHOTOCOMMENTLIST: photoCommentList,
          });
      Navigator.of(state.context).pop(); //close the drawer
    } catch (e) {
      if (Constant.DEV) print('========= sharedWith error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Failed to get sharedWith list: $e',
      );
    }
  }

  void delete() async {
    MyDialog.circularProgressStart(state.context);
    delIndexes.sort(); //ascending order
    for (int i = delIndexes.length - 1; i >= 0; i--) {
      try {
        PhotoMemo p = photoMemoList[delIndexes[i]];
        await FirestoreController.deletePhotoMemo(photoMemo: p);
        await CloudStorageController.deletePhotoFile(photoMemo: p);
        state.render(() {
          photoMemoList.removeAt(delIndexes[i]);
        });
        //photoMemoList.removeAt(delIndexes[i]);
      } catch (e) {
        if (Constant.DEV) print('======== failed to delete photomemo: $e');
        MyDialog.showSnackBar(
          context: state.context,
          message: 'Failed to delete Photomemo: $e',
        );
        break; //quit further processing
      }
    }
    MyDialog.circularProgressStop(state.context);
    state.render(() => delIndexes.clear());
  }

  void cancelDelete() {
    state.render(() {
      delIndexes.clear();
    });
  }

  void onLongPress(int index) {
    state.render(() {
      if (delIndexes.contains(index))
        delIndexes.remove(index);
      else
        delIndexes.add(index);
    });
    //print('========= delIndexes: $delIndexes');
  }

  void saveSearchKey(String? value) {
    searchKeyString = value;
  }

  void viewAllProfiles() async {
    try {
      profileList = await FirestoreController.getProfileList();
      await Navigator.pushNamed(state.context, UserProfileScreen.routeName,
          arguments: {
            Constant.PROFILE: profileList,
          });
      Navigator.pop(state.context); //closes drawer
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context, title: 'getProfileList error', content: '$e');
    }
  }

  void search() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    currentState.save();
    List<String> keys = [];
    if (searchKeyString != null) {
      var tokens = searchKeyString!.split(RegExp('(,| )+')).toList();
      for (var t in tokens) {
        if (t.trim().isNotEmpty) keys.add(t.trim().toLowerCase());
      }
    }

    MyDialog.circularProgressStart(state.context);

    try {
      late List<PhotoMemo> results;
      if (keys.isEmpty) {
        //read all photomemos
        results = await FirestoreController.getPhotoMemoList(
            email: state.widget.email);
      } else {
        results = await FirestoreController.searchImages(
          createdBy: state.widget.email,
          searchLabels: keys,
        );
      }
      MyDialog.circularProgressStop(state.context);
      state.render(() => photoMemoList = results);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      if (Constant.DEV) print('search error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Search error: $e',
      );
    }
  }

  void onTap(int index) async {
    try {
      photoCommentList = await FirestoreController.getPhotoCommentList(
          originalPoster: state.photoMemoList![index].createdBy,
          memoId: state.photoMemoList![index].docId);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context,
          title: 'getPhotoCommentList error',
          content: '$e');
    }
    if (delIndexes != null) return;
    await Navigator.pushNamed(state.context, DetailedViewScreen.routeName,
        arguments: {
          ARGS.USER: state.user,
          ARGS.OnePhotoMemo: state.photoMemoList![index],
          Constant.ARG_PHOTOCOMMENTLIST: photoCommentList,
        });
    state.render(() {});
  }

  void addButton() async {
    //navigate to AddNewPhotoMemo Screen
    await Navigator.pushNamed(state.context, AddNewPhotoMemoScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.PhotoMemoList: photoMemoList,
        });
    state.render(() {});
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuthController.signOut();
    } catch (e) {
      if (Constant.DEV) print('========= sign out error: $e');
    }
    Navigator.of(state.context).pop(); //close the drawer
    Navigator.of(state.context).pop(); //pop from the user
  }
}
