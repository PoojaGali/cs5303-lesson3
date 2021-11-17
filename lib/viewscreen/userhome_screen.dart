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
import 'package:lesson3/viewscreen/myprofile_screen.dart';
import 'package:lesson3/viewscreen/sharedwith_screen.dart';
import 'package:lesson3/viewscreen/user_profiles.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/userHomeScreen';
  final User user;
  late final String displayName;
  late final String email;
  final List<PhotoMemo> photoMemoList;
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
  String progMessage = '';
  bool liked = false;
  List<PhotoMemo> photoMemoList = [];
  List<PhotoComment> photoCommentList = [];
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
              onPressed: () => con.viewMyProfile(user),
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
                leading: Icon(Icons.emoji_people),
                title: Text('All Users'),
                onTap: con.viewAllProfiles,
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
                itemCount: photoMemoList.length,
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
                      trailing: Container(
                        child: Column(
                          children: [
                            (con.photoMemoList[index].newComment == 'true')
                                ? Icon(
                                    Icons.notifications,
                                    color: Colors.green,
                                  )
                                : Icon(Icons.arrow_right)
                          ],
                        ),
                      ),
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
                      onTap: () {
                        con.onTap(index);

                        con.photoMemoList[index].newComment =
                            (con.photoMemoList[index].newComment == 'true')
                                ? 'false'
                                : 'false';
                      },
                      onLongPress: () => con.onLongPress(index),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// class DetailScreen extends StatelessWidget {
//   final PhotoMemo? memo;
//   final _Controller? con;
//   final List<PhotoComment>? photoCommentList;

//   DetailScreen(
//       {Key? key,
//       @required this.memo,
//       @required this.con,
//       @required this.photoCommentList})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     int index = 0;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(memo!.title),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           // child: Text(memo.),
//           child: Card(
//             elevation: 7.0,
//             child: Column(
//               children: [
//                 Center(
//                   child: Container(
//                     height: MediaQuery.of(context).size.height * .4,
//                     child: WebImage(
//                       url: memo!.photoURL,
//                       context: context,
//                     ),
//                   ),
//                 ),
//                 Text(
//                   'Title: ${memo!.title}',
//                   style: Theme.of(context).textTheme.headline6,
//                 ),
//                 Text('Memo: ${memo!.memo}'),
//                 Text('Created By: ${memo!.createdBy}'),
//                 Text('Updated At: ${memo!.timestamp}'),
//                 Text('Shared With: ${memo!.sharedWith}'),
//                 SizedBox(
//                   height: 20.0,
//                 ),
//                 Container(
//                   color: Colors.blueAccent,
//                   child: Row(
//                     children: [
//                       Text(
//                         'Comments',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 20,
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () {
//                           con!.addComment(
//                               memo!.docId.toString(), memo!.createdBy);
//                         },
//                         icon: Icon(
//                           Icons.add_comment,
//                         ),
//                         alignment: Alignment.centerRight,
//                         color: Colors.pinkAccent,
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   height: 5.0,
//                 ),
//                 photoCommentList!.length == 0
//                     ? Text('No Comments Found',
//                         style: Theme.of(context).textTheme.headline5)
//                     : ListView.builder(
//                         scrollDirection: Axis.vertical,
//                         shrinkWrap: true,
//                         itemCount: photoCommentList!.length,
//                         itemBuilder: (BuildContext context, index) => Container(
//                           color: index == 0 || index % 2 == 0
//                               ? Colors.purple[200]
//                               : Colors.indigo[200],
//                           child: ListTile(
//                             title: Text(photoCommentList![index].createdBy,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 20,
//                                   color: Colors.black,
//                                 )),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Created On: ${photoCommentList![index].timestamp}',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 15,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 Text(
//                                   photoCommentList![index].content,
//                                   style: TextStyle(
//                                     fontSize: 35,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.indigo[900],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class _Controller {
  late _UserHomeState state;

  late List<PhotoMemo> photoMemoList;
  late List<PhotoComment> photoCommentList;
  List<Profile> profileList = [];

  String? searchKeyString;
  List<int> delIndexes = [];

  _Controller(this.state) {
    photoMemoList = state.widget.photoMemoList;
  }

  String memo = '';
  String originalPoster = '';
  String content = '';
  String createdBy = '';
  var timestamp;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // List<PhotoComment> tempComment;
  PhotoComment tempComment = PhotoComment();

  void viewMyProfile(User user) async {
    List<Profile> myProfile =
        await FirestoreController.getOneProfile(user.email!);

    Navigator.pushNamed(
      state.context,
      MyProfileScreen.routeName,
      arguments: {
        ARGS.USER: user,
        Constant.ARG_ONE_PROFILE: myProfile[0],
      },
    );
    state.render(() {});
  }

  // void createComment() async {
  //   if (!formKey.currentState!.validate()) return;
  //   formKey.currentState!.save();
  //   MyDialog.circularProgressStart(state.context);

  //   try {
  //     state.render(() => state.progMessage = "Uploading Comment!");

  //     tempComment.timestamp = DateTime.now();
  //     tempComment.originalPoster = originalPoster;
  //     tempComment.createdBy = state.user.email!;
  //     tempComment.memoId = memo;

  //     String docId = await FirestoreController.addPhotoComment(tempComment);
  //     tempComment.docId = docId;

  //     MyDialog.circularProgressStop(state.context);
  //     Navigator.pop(state.context);
  //   } catch (e) {
  //     MyDialog.circularProgressStop(state.context);
  //     MyDialog.info(
  //         context: state.context,
  //         title: 'Save PhotoComment error',
  //         content: '$e');
  //   }
  // }

  // void saveComment(String? value) {
  //   tempComment.content = value!;
  // }

  // void addComment(String value, String namevalue) {
  //   memo = value;
  //   originalPoster = namevalue;

  //   showDialog(
  //       context: state.context,
  //       builder: (BuildContext context) {
  //         return Scaffold(
  //           appBar: AppBar(
  //             title: Text('Create an account'),
  //           ),
  //           body: Padding(
  //             padding: const EdgeInsets.only(
  //               top: 15.0,
  //               left: 15.0,
  //               right: 15.0,
  //             ),
  //             child: Form(
  //               key: formKey,
  //               child: SingleChildScrollView(
  //                 child: Column(
  //                   children: [
  //                     Text('Create a Comment',
  //                         style: Theme.of(context).textTheme.headline5),
  //                     TextFormField(
  //                       decoration: InputDecoration(
  //                         hintText: 'Enter Comment',
  //                       ),
  //                       keyboardType: TextInputType.emailAddress,
  //                       autocorrect: false,
  //                       onSaved: saveComment,
  //                     ),
  //                     ElevatedButton(
  //                       onPressed: createComment,
  //                       child: Text(
  //                         'Add',
  //                         style: Theme.of(context).textTheme.button,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         );
  //       });
  // }

  void sharedWith() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FirestoreController.getPhotoMemoListSharedWith(
              email: state.widget.email);
      await Navigator.pushNamed(state.context, SharedWithScreen.routeName,
          arguments: {
            ARGS.PhotoMemoList: photoMemoList,
            ARGS.USER: state.widget.user,
          });
      Navigator.of(state.context).pop(); // Close the drawer

    } catch (e) {
      if (Constant.DEV) print('====sharedWith Error: $e');
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
    Map<String, dynamic> updateInfo = {};

    try {
      photoCommentList = await FirestoreController.getPhotoCommentList(
          originalPoster: state.photoMemoList[index].createdBy,
          memoId: state.photoMemoList[index].docId);
      updateInfo[PhotoMemo.NEW_COMMENT] = photoMemoList[index].newComment;
      await FirestoreController.updatePhotoMemo(
        docId: photoMemoList[index].docId!,
        updateInfo: updateInfo,
      );
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context,
          title: 'getPhotoCommentList error',
          content: '$e');
    }
    if (delIndexes.isNotEmpty) {
      onLongPress(index);
      return;
    }
    await Navigator.pushNamed(state.context, DetailedViewScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.OnePhotoMemo: photoMemoList[index],
          Constant.ARG_PHOTOCOMMENTLIST: photoCommentList,
        });
    state.render(() {
      photoMemoList.sort((a, b) {
        if (a.timestamp!.isBefore(b.timestamp!))
          return 1; //descending order
        else if (a.timestamp!.isAfter(b.timestamp!))
          return -1;
        else
          return 0;
      });
    });
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
