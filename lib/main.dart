import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/profile.dart';
import 'package:lesson3/viewscreen/addnewphotomemo_screen.dart';
import 'package:lesson3/viewscreen/detailedview_screen.dart';
import 'package:lesson3/viewscreen/detailshared_screen.dart';
import 'package:lesson3/viewscreen/internalerror_screen.dart';
import 'package:lesson3/viewscreen/myprofile_screen.dart';
import 'package:lesson3/viewscreen/profile_screen.dart';
import 'package:lesson3/viewscreen/sharedwith_screen.dart';
import 'package:lesson3/viewscreen/signin_screen.dart';
import 'package:lesson3/viewscreen/signup_screen.dart';
import 'package:lesson3/viewscreen/user_profiles.dart';
import 'package:lesson3/viewscreen/userhome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Lesson3App());
}

class Lesson3App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: Constant.DEV,
        theme: ThemeData(
          brightness: Constant.DARKMODE ? Brightness.dark : Brightness.light,
          primaryColor: Colors.blueAccent,
        ),
        initialRoute: SignInScreen.routeName,
        routes: {
          SignInScreen.routeName: (context) => SignInScreen(),
          UserHomeScreen.routeName: (context) {
            Object? args = ModalRoute.of(context)?.settings.arguments;
            if (args == null) {
              return InternalErrorScreen('args is null at UserHomeScreen');
            } else {
              var argument = args as Map;
              var user = argument[ARGS.USER];
              var photoMemoList = argument[ARGS.PhotoMemoList];
              return UserHomeScreen(user: user, photoMemoList: photoMemoList);
            }
          },
          SharedWithScreen.routeName: (context) {
            Object? args = ModalRoute.of(context)?.settings.arguments;
            if (args == null) {
              return InternalErrorScreen('args is null at UserHomeScreen');
            } else {
              var argument = args as Map;
              var user = argument[ARGS.USER];
              var photoMemoList = argument[ARGS.PhotoMemoList];
              return SharedWithScreen(
                photoMemoList: photoMemoList,
                user: user,
              );
            }
          },
          AddNewPhotoMemoScreen.routeName: (context) {
            Object? args = ModalRoute.of(context)?.settings.arguments;
            if (args == null) {
              return InternalErrorScreen('args is null at UserHomeScreen');
            } else {
              var argument = args as Map;
              var user = argument[ARGS.USER];
              var photoMemoList = argument[ARGS.PhotoMemoList];
              return AddNewPhotoMemoScreen(
                user: user,
                photoMemoList: photoMemoList,
              );
            }
          },
          DetailedViewScreen.routeName: (context) {
            Object? args = ModalRoute.of(context)?.settings.arguments;
            if (args == null) {
              return InternalErrorScreen(
                  'args is null at Detailed View Screen');
            } else {
              var argument = args as Map;
              var user = argument[ARGS.USER];
              var photoMemo = argument[ARGS.OnePhotoMemo];
              var photoCommentList = argument[Constant.ARG_PHOTOCOMMENTLIST];
              return DetailedViewScreen(
                user: user,
                photoMemo: photoMemo,
                photoCommentList: photoCommentList,
              );
            }
          },
          DetailSharedScreen.routeName: (context) {
            Object? args = ModalRoute.of(context)?.settings.arguments;
            if (args == null) {
              return InternalErrorScreen(
                  'args is null at Detailed View Screen');
            } else {
              var argument = args as Map;
              var user = argument[ARGS.USER];
              var photoMemo = argument[ARGS.OnePhotoMemo];
              var photoCommentList = argument[Constant.ARG_PHOTOCOMMENTLIST];
              return DetailSharedScreen(
                user: user,
                photoMemo: photoMemo,
                photoCommentList: photoCommentList,
              );
            }
          },
          SignUpScreen.routeName: (context) => SignUpScreen(),
          ProfileScreen.routeName: (context) => ProfileScreen(),
          MyProfileScreen.routeName: (context) {
            Object? args = ModalRoute.of(context)?.settings.arguments;
            if (args == null) {
              return InternalErrorScreen('args is null at MyProfileScreen');
            } else {
              var argument = args as Map;
              var profile = argument[Constant.ARG_ONE_PROFILE];
              var user = argument[ARGS.USER];
              return MyProfileScreen(
                user: user,
                profile: profile,
              );
            }
          },
          UserProfileScreen.routeName: (context) => UserProfileScreen(),
        });
  }
}
