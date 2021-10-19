import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebaseauth_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/addnewphotomemo_screen.dart';
import 'package:lesson3/viewscreen/detailedview_screen.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/UserHomeScreen';

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
  late _Controller con;
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false), //disable android system back
      child: Scaffold(
          appBar: AppBar(
            //title: Text('User Home'),
            actions: [
              Form(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
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
              ),
              IconButton(onPressed: con.search, icon: Icon(Icons.search)),
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
                  'No PhotoMemo found!',
                  style: Theme.of(context).textTheme.headline6,
                )
              : ListView.builder(
                  itemCount: con.photoMemoList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: WebImage(
                        url: con.photoMemoList[index].photoURL,
                        context: context,
                      ),
                      title: Text(con.photoMemoList[index].title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            con.photoMemoList[index].memo.length >= 40
                                ? con.photoMemoList[index].memo
                                        .substring(0, 40) +
                                    '....'
                                : con.photoMemoList[index].memo,
                          ),
                          Text(
                              'Created By : ${con.photoMemoList[index].createdBy}'),
                          Text(
                              'SharedWith : ${con.photoMemoList[index].sharedWith}'),
                          Text(
                              'Timestamp : ${con.photoMemoList[index].timestamp}'),
                        ],
                      ),
                      onTap: () => con.onTap(index),
                    );
                  })),
    );
  }
}

class _Controller {
  late _UserHomeState state;
  String? searchKeyString;
  late List<PhotoMemo> photoMemoList;
  _Controller(this.state) {
    photoMemoList = state.widget.photoMemoList;
  }

  void saveSearchKey(String? value) {
    searchKeyString = value;
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
    try {
      late List<PhotoMemo> results;
      if (keys.isEmpty) {
        // read all photo memos
        results = await FirestoreController.getPhotoMemoList(
            email: state.widget.email);
      } else {
        results = await FirestoreController.searchImages(
          createdBy: state.widget.email,
          searchLabels: keys,
        );
      }
      state.render(() => photoMemoList = results);
    } catch (e) {
      if (Constant.DEV) print('=== search error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'search error: $e',
      );
    }
  }

  void onTap(int index) async {
    await Navigator.pushNamed(state.context, DetailedViewScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.OnePhotoMemo: photoMemoList[index],
        });
    // rerender home screen
    state.render(() {
      // reorder based on the updated timestamp
      photoMemoList.sort((a, b) {
        if (a.timestamp!.isBefore(b.timestamp!))
          return 1; // descending order
        else if (a.timestamp!.isAfter(b.timestamp!))
          return -1;
        else
          return 0;
      });
    });
  }

  void addButton() async {
    //navigate to AddNewPhotoMemo

    await Navigator.pushNamed(state.context, AddNewPhotoMemoScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.PhotoMemoList: photoMemoList,
        });
    state.render(() {}); // render the home screen if new photomemo is added
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuthController.signOut();
    } catch (e) {
      if (Constant.DEV) print('======sign out error: $e');
    }
    Navigator.of(state.context).pop(); //close the drawer
    Navigator.of(state.context).pop(); //pop from UserHome
  }
}
