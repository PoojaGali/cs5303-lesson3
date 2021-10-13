import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebaseauth_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/viewscreen/userhome_screen.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/signInScreen';
  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignInScreen> {
  late _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
        title: Text('Sign In'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Sign In, Please!',
                style: Theme.of(context).textTheme.headline5,
              ),
              TextFormField(
                decoration: InputDecoration(
                    icon: Icon(Icons.email), hintText: 'Enter Email'),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: con.validateEmail,
                onSaved: con.saveEmail,
              ),
              TextFormField(
                decoration: InputDecoration(
                    icon: Icon(Icons.lock), hintText: 'Enter Password'),
                obscureText: true,
                autocorrect: false,
                validator: con.validatePassword,
                onSaved: con.savePassword,
              ),
              ElevatedButton(
                onPressed: con.signIn,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _SignInState state;
  _Controller(this.state);

  String? email;
  String? password;

  void signIn() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();
    User? user;
    try {
      if (email == null || password == null) {
        throw 'email or password is null';
      }
      user = await FirebaseAuthController.signIn(
          email: email!, password: password!);
      print('=====${user?.email}');
      Navigator.pushNamed(
        state.context,
        UserHomeScreen.routeName,
        arguments: {
          ARGS.USER: user,
        },
      );
    } catch (e) {
      if (Constant.DEV) print('====signIn Error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Sign In Error: $e',
        seconds: 30,
      );
    }
  }

  String? validateEmail(String? value) {
    if (value == null || !(value.contains('@') && value.contains('.')))
      return 'Invalid Email address';
    else
      return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6)
      return 'Invalid Password';
    else
      return null;
  }

  void saveEmail(String? value) {
    if (value != null) email = value;
  }

  void savePassword(String? value) {
    if (value != null) password = value;
  }
}
