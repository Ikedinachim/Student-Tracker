import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_app/authentication/screens/attendance_page.dart';
import 'package:tracking_app/authentication/screens/lecturer_signup_page.dart';
import 'package:tracking_app/authentication/screens/splash_screen.dart';
import 'package:tracking_app/home/providers/chat_provider.dart';
import 'package:tracking_app/home/screens/about_page.dart';
import 'package:tracking_app/home/screens/chat_page.dart';
import 'package:tracking_app/home/screens/home_page.dart';
import 'package:tracking_app/home/screens/profile_page.dart';

import 'authentication/screens/login_page.dart';
import 'authentication/screens/signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  //instantiate hive

  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  await Hive.openBox('userInfo');
  sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp());
}

SharedPreferences sharedPreferences;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>(
      create: (_) {
        return ChatProvider(
            firebaseFirestore: FirebaseFirestore.instance,
            prefs: sharedPreferences,
            firebaseStorage: FirebaseStorage.instance);
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tracking App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ChangeNotifierProvider<ChatProvider>(
            create: (_) {
              return ChatProvider(
                  firebaseFirestore: FirebaseFirestore.instance,
                  prefs: sharedPreferences,
                  firebaseStorage: FirebaseStorage.instance);
            },
            child: LoginPage()),
        routes: {
          LoginPage.pageName: (ctx) => LoginPage(),
          SignUpPage.pageName: (ctx) => SignUpPage(),
          HomePage.pageName: (ctx) => HomePage(),
          SplashScreen.pageName: (ctx) => SplashScreen(),
          ProfilePage.pageName: (ctx) => ProfilePage(),
          AboutPage.pageName: (ctx) => AboutPage(),
          LecturerSignUpPage.pageName: (ctx) => LecturerSignUpPage(),
          AttandacePage.pageName: (ctx) => AttandacePage(),
        },
      ),
    );
  }
}
