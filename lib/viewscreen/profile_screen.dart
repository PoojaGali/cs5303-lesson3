import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/profile.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = './profileScreen';
  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<ProfileScreen> {
  late Profile profile;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late String progressMessage;

  @override
  void initState() {
    super.initState();
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    profile = args[Constant.ARG_ONE_PROFILE];

    return Scaffold(
      appBar: AppBar(
        title: Text('${profile.email}'),
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
                    child: Image.asset('images/profilepic.png'),
                  ),
                ),
                Text(
                  'Title: ${profile.email}',
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text('Name: ${profile.name}'),
                Text('Member Since: ${profile.signUpDate}'),
                Text('About Me: ${profile.description}'),
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
