import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracking_app/authentication/screens/login_page.dart';
import 'package:tracking_app/home/screens/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);
  static const String pageName = '/splashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Widget afterSplash() {
    print('splash');
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Navigator.of(context).pushReplacementNamed(HomePage.pageName);
          return HomePage();
        } else {
          Navigator.of(context).pushReplacementNamed(LoginPage.pageName);
          return LoginPage();
        }
      },
    );
  }

  @override
  void initState() {
    Timer(const Duration(seconds: 2), () {
      Navigator.pushNamed(context, LoginPage.pageName);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset('assets/images/splash.jpeg'),
    );
  }
}
