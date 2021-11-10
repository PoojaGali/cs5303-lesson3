import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/profile.dart';
import 'package:lesson3/viewscreen/profile_screen.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class UserProfileScreen extends StatefulWidget {
  static const routeName = '/viewAllProfilesScreen';
  @override
  State<StatefulWidget> createState() {
    return _UserProfileState();
  }
}

class _UserProfileState extends State<UserProfileScreen> {
  late _Controller con;
  String? progMessage;
  List<Profile>? profileList;
  int index = 0;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    profileList = args[Constant.PROFILE];
    return Scaffold(
      appBar: AppBar(
        title: Text('View All Users'),
      ),
      body: ListView.builder(
        itemCount: profileList!.length,
        itemBuilder: (context, index) => GestureDetector(
          child: ListTile(
            leading:
                WebImage(url: profileList![index].photoURL, context: context),
            trailing: Icon(Icons.keyboard_arrow_right),
            title: Text(
              '${profileList![index].email}',
              style: Theme.of(context).textTheme.headline6,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Signed Up On: ${profileList![index].signUpDate}'),
              ],
            ),
            onTap: () => con.onTap(profileList![index]),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _Controller(this.state);
  _UserProfileState state;
  late String email;

  void onTap(Profile profile) async {
    await Navigator.pushNamed(
      state.context,
      ProfileScreen.routeName,
      arguments: {
        Constant.ARG_ONE_PROFILE: profile,
      },
    );
    state.render(() {});
  }
}
