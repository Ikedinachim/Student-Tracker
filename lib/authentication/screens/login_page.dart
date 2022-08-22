import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tracking_app/authentication/screens/lecturer_signup_page.dart';
import 'package:tracking_app/authentication/screens/signup_page.dart';
import 'package:tracking_app/home/screens/home_page.dart';

class LoginPage extends StatefulWidget {
  static const pageName = '/loginPage';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = new GlobalKey<FormState>();
  String _userEmail;
  String _userPassword;
  String _initialEmail;
  String _initialPassword;
  void setInitialEmailAndPassword() {
    final userInfo = Hive.box('userInfo').get('details');
    if (userInfo != null) {
      _initialEmail = userInfo['userEmail'];
      _initialPassword = userInfo['password'];
    } else {
      _initialEmail = '';
      _initialPassword = '';
    }
  }

  bool isLoading = false;

  _loginUser() async {
    isLoading = true;
    print('user login');
    setInitialEmailAndPassword();
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        final auth = FirebaseAuth.instance;
        final user = await auth.signInWithEmailAndPassword(
            email: _userEmail, password: _userPassword);

        // _userId = userCredential.user.uid;
        //await Hive.openBox('userInfo');
        isLoading = false;
        Navigator.of(context).pushReplacementNamed(HomePage.pageName);
      } on FirebaseAuthException catch (error) {
        if (error.message.contains(
            'There is no user record corresponding to this identifier. The user may have been deleted.')) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        if (error.message.contains(
            'A network error (such as timeout, interrupted connection or unreachable host) has occurred.')) {
          ScaffoldMessenger.of(context).showSnackBar(noInternetSnackBar);
        }
        print('platform exception: $error');
      } on PlatformException catch (error) {
        print('platform error is $error');
        ScaffoldMessenger.of(context).showSnackBar(noInternetSnackBar);
      } catch (error) {
        print('other error: $error');
      }
    }
  }

  Widget snackBar = SnackBar(content: Text('YOU ARE NOT A REGISTERED USER!'));
  Widget noInternetSnackBar =
      SnackBar(content: Text('CONNECT TO THE INTERNET!'));
  @override
  void initState() {
    setInitialEmailAndPassword();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 60,
            ),
            Container(
              height: 150,
              width: double.infinity,
              //  color: Colors.red,
              child: Center(
                child: Text(
                  'Log In',
                  style: GoogleFonts.chivo(
                      color: Colors.blueGrey,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              height: deviceHeight * 0.4,
              width: deviceWidth * 0.8,
              padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
              decoration: BoxDecoration(
                  //    color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 2,
                  )),
              child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _initialEmail,
                          decoration: InputDecoration(hintText: 'Email'),
                          validator: (input) {
                            if (input.isEmpty || input == null) {
                              return 'Email is Required!';
                            }
                            if (!input.contains('@')) {
                              return 'Valid Email is Required!';
                            }
                            return null;
                          },
                          onSaved: (input) => _userEmail = input,
                        ),
                        TextFormField(
                          initialValue: _initialPassword,
                          validator: (input) {
                            if (input.isEmpty) {
                              return 'Password is Required!';
                            }
                            if (input.length < 7) {
                              return 'Password must be at least 7 characters long';
                            }
                            return null;
                          },
                          onSaved: (input) => _userPassword = input,
                          obscureText: true,
                          decoration: InputDecoration(hintText: 'Password'),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        GestureDetector(
                          child: Text('Not yet Registered? Sign Up'),
                          onTap: () => Navigator.of(context)
                              .pushNamed(SignUpPage.pageName),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        isLoading
                            ? CircularProgressIndicator.adaptive()
                            : GestureDetector(
                                onTap: () {
                                  _loginUser();
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 2, color: Colors.black)),
                                  child: Icon(Icons.arrow_forward),
                                ),
                              )
                      ],
                    ),
                  )),
            ),
            SizedBox(
              height: 60,
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, LecturerSignUpPage.pageName);
              },
              child: Text('SIGN UP AS A LECTURER'),
            )
          ],
        ),
      ),
    );
  }
}
